require "test_spec/rspec/example"
require "erb"
require "rouge"
require "fileutils"
require "active_support"
require "active_support/inflector"
require "active_support/core_ext/numeric"
require "rspec/core/formatters/documentation_formatter"

module RSpec
  module TestSpec
    # rubocop:disable Metrics/ClassLength
    class Formatter < ::RSpec::Core::Formatters::DocumentationFormatter
      ::RSpec::Core::Formatters.register(
        self,
        :example_started, :example_passed, :example_step_passed,
        :example_step_pending, :example_pending, :example_step_failed,
        :example_group_finished, :example_group_started
      )

      DEFAULT_REPORT_PATH = File.join(
        '.', 'reports', Time.now.strftime('%Y%m%d-%H%M%S')
      )

      REPORT_PATH = ENV['REPORT_PATH'] || DEFAULT_REPORT_PATH
      SCREENRECORD_DIR = File.join(REPORT_PATH, 'screenrecords')
      SCREENSHOT_DIR   = File.join(REPORT_PATH, 'screenshots')

      def initialize(_output)
        super
        create_report_directory
        create_screenshots_directory
        create_screenrecords_directory
        provide_resources

        @all_groups = {}

        # REPEATED FROM THE SUPER
        # @group_level = 0
      end

      # rubocop:disable Metrics/LineLength
      def example_started(notification)
        return unless notification.example.metadata[:with_steps]

        full_message = "#{current_indentation}#{notification.example.description}"
        output.puts Core::Formatters::ConsoleCodes.wrap(full_message, :default)

        # For reporter
        @group_example_count += 1
      end

      # This comes from the DocumentationFormatter.
      def example_passed(notification)
        super unless notification.example.metadata[:with_steps]

        # For reporter
        @group_example_success_count += 1
        @examples << Example.new(notification.example)
      end

      # This comes from the DocumentationFormatter.
      def example_failed(notification)
        @group_example_failure_count += 1
        @examples << Example.new(notification.example)
      end

      # This comes from the DocumentationFormatter.
      # Needed for Reporter.
      def example_pending(notification)
        @group_example_pending_count += 1
        @examples << Example.new(notification.example)
      end

      def example_step_passed(notification)
        full_message = "#{current_indentation}  #{notification.type.to_s.capitalize} #{notification.message}"
        output.puts Core::Formatters::ConsoleCodes.wrap(full_message, :success)
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Style/ConditionalAssignment
      def example_step_pending(notification)
        full_message = "#{current_indentation}  #{notification.type.to_s.capitalize} #{notification.message}"

        if notification.options[:pending] &&
           notification.options[:pending] != true
          full_message << " (PENDING: #{notification.options[:pending]})"
        else
          full_message << " (PENDING)"
        end

        output.puts Core::Formatters::ConsoleCodes.wrap(full_message, :pending)
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Style/ConditionalAssignment

      def example_step_failed(notification)
        full_message = "#{current_indentation}  #{notification.type.to_s.capitalize} #{notification.message} (FAILED)"
        output.puts Core::Formatters::ConsoleCodes.wrap(full_message, :failure)
      end
      # rubocop:enable Metrics/LineLength

      # ADDED FOR REPORTING

      def example_group_started(_notification)
        if @group_level.zero?
          @examples = []
          @group_example_count = 0
          @group_example_success_count = 0
          @group_example_failure_count = 0
          @group_example_pending_count = 0
        end

        super

        # REPEATED FROM THE SUPER
        # @group_level += 1
      end

      # rubocop:disable Metrics/LineLength
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def example_group_finished(notification)
        super

        return unless @group_level.zero?

        # rubocop:disable Metrics/BlockLength
        File.open("#{REPORT_PATH}/#{notification.group.description.parameterize}.html", "w") do |f|
          @passed = @group_example_success_count
          @failed = @group_example_failure_count
          @pending = @group_example_pending_count

          duration_values = @examples.map(&:run_time)
          duration_keys = duration_values.size.times.to_a

          if duration_values.size < 2 && !duration_values.empty?
            duration_values.unshift(duration_values.first)
            duration_keys = duration_keys << 1
          end

          @title = notification.group.description
          @durations = duration_keys.zip(duration_values)
          @summary_duration = duration_values.inject(0) { |sum, i| sum + i }.to_s(:rounded, precision: 5)

          Example.load_spec_comments!(@examples)

          class_map = {
            passed: 'success',
            failed: 'danger',
            pending: 'warning'
          }

          statuses = @examples.map(&:status)

          status =
            if statuses.include?('failed')
              'failed'
            elsif statuses.include?('passed')
              'passed'
            else
              'pending'
            end

          @all_groups[notification.group.description.parameterize] = {
            group: notification.group.description,
            examples: @examples.size,
            status: status,
            klass: class_map[status.to_sym],
            passed: statuses.select { |s| s == 'passed' },
            failed: statuses.select { |s| s == 'failed' },
            pending: statuses.select { |s| s == 'pending' },
            duration: @summary_duration
          }

          template_file = File.read(
            File.dirname(__FILE__) + "/../../../templates/report.erb"
          )

          f.puts ERB.new(template_file).result(binding)
        end
        # rubocop:enable Metrics/BlockLength

        # THIS ONE IS FROM THE SUPER
        # @group_level -= 1 if @group_level > 0
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize

      # This is from BaseTextFormatter.
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def close(notification)
        File.open("#{REPORT_PATH}/overview.html", "w") do |f|
          @overview = @all_groups

          @passed = @overview.values.map { |g| g[:passed].size }.inject(0) { |sum, i| sum + i }
          @failed = @overview.values.map { |g| g[:failed].size }.inject(0) { |sum, i| sum + i }
          @pending = @overview.values.map { |g| g[:pending].size }.inject(0) { |sum, i| sum + i }

          duration_values = @overview.values.map { |e| e[:duration] }
          duration_keys = duration_values.size.times.to_a

          if duration_values.size < 2
            duration_values.unshift(duration_values.first)
            duration_keys = duration_keys << 1
          end

          @durations = duration_keys.zip(duration_values.map { |d| d.to_f.round(5) })
          @summary_duration = duration_values.map { |d| d.to_f.round(5) }.inject(0) { |sum, i| sum + i }.to_s(:rounded, precision: 5)
          @total_examples = @passed + @failed + @pending

          template_file = File.read(
            File.dirname(__FILE__) + "/../../../templates/overview.erb"
          )

          f.puts ERB.new(template_file).result(binding)
        end

        super
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/LineLength

      private

      def create_report_directory
        FileUtils.rm_rf(REPORT_PATH) if File.exist?(REPORT_PATH)
        FileUtils.mkpath(REPORT_PATH)
      end

      def create_screenshots_directory
        FileUtils.mkdir_p SCREENSHOT_DIR unless File.exist?(SCREENSHOT_DIR)
      end

      def create_screenrecords_directory
        FileUtils.mkdir_p SCREENRECORD_DIR unless File.exist?(SCREENRECORD_DIR)
      end

      def provide_resources
        FileUtils.cp_r(
          File.dirname(__FILE__) + "/../../../resources", REPORT_PATH
        )
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
