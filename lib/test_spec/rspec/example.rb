require "test_spec/rspec/problem"

class Example
  attr_reader :run_time, :status, :duration, :exception, :description,
    :full_description, :example_group, :failed_screenshot,
    :screenshots, :screenrecord, :file_path, :metadata, :spec

  # rubocop:disable Metrics/AbcSize
  def initialize(example)
    @execution_result = example.execution_result
    @run_time = @execution_result.run_time.round(5)
    @status = @execution_result.status.to_s
    @example_group = example.example_group.to_s
    @description = example.description
    @full_description = example.full_description
    @metadata = example.metadata
    @duration = @execution_result.run_time.to_s(:rounded, precision: 5)
    @screenrecord = @metadata[:screenrecord]
    @screenshots = @metadata[:screenshots]
    @spec = nil
    @file_path = @metadata[:file_path]
    @exception = Problem.new(example, @file_path)
    @failed_screenshot = @metadata[:failed_screenshot]
  end
  # rubocop:enable Metrics/AbcSize

  def example_title
    title_arr = @example_group.to_s.split('::') - %w[RSpec ExampleGroups]
    title_arr.push @description
    title_arr.join(' → ')
  end

  def has_spec?
    !@spec.nil?
  end

  def has_screenrecord?
    !@screenrecord.nil?
  end

  def has_screenshots?
    !@screenshots.nil? && !@screenshots.empty?
  end

  def has_failed_screenshot?
    !@failed_screenshot.nil?
  end

  def has_exception?
    !@exception.klass.nil?
  end

  def klass(prefix = 'label-')
    class_map = {
      passed: "#{prefix}success",
      failed: "#{prefix}danger",
      pending: "#{prefix}warning"
    }

    class_map[@status.to_sym]
  end

  def create_spec_line(spec_text)
    formatter = Rouge::Formatters::HTML.new(css_class: 'highlight')
    lexer = Rouge::Lexers::Gherkin.new
    @spec = formatter.format(lexer.lex(spec_text.gsub('#->', '')))
  end

  # rubocop:disable Metrics/LineLength
  # rubocop:disable Metrics/AbcSize
  def self.load_spec_comments!(examples)
    examples.group_by(&:file_path).each do |file_path, file_examples|
      lines = File.readlines(file_path)

      file_examples.zip(file_examples.rotate).each do |ex, next_ex|
        lexically_next = next_ex &&
                         next_ex.file_path == ex.file_path &&
                         next_ex.metadata[:line_number] > ex.metadata[:line_number]
        start_line_idx = ex.metadata[:line_number] - 1
        next_start_idx = (lexically_next ? next_ex.metadata[:line_number] : lines.size) - 1
        spec_lines = lines[start_line_idx...next_start_idx].select { |l| l.match(/#->/) }
        ex.create_spec_line(spec_lines.join) unless spec_lines.empty?
      end
    end
  end
  # rubocop:enable Metrics/LineLength
  # rubocop:enable Metrics/AbcSize
end
