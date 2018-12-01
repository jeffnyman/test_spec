require "erb"
require "rbconfig"

class Problem
  attr_reader :klass, :explanation, :backtrace, :backtrace_message,
    :message, :highlighted_source

  def initialize(example, file_path)
    @example = example
    @exception = @example.exception
    @file_path = file_path

    return if @exception.nil?

    @klass = @exception.class
    @message = @exception.message.encode("utf-8")
    @backtrace = @exception.backtrace
    @backtrace_message = format_backtrace
    @highlighted_source = process_source
    @explanation = process_message
  end

  private

  def os
    @os ||= begin
      host_os = RbConfig::CONFIG['host_os']

      case host_os
        when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
          :windows
        when /darwin|mac os/
          :macosx
        when /linux/
          :linux
        when /solaris|bsd/
          :unix
        else
          raise Exception, "unknown os: #{host_os.inspect}"
      end
    end
  end

  def format_backtrace
    formatted_backtrace(@example, @exception).map do |entry|
      ERB::Util.html_escape(entry)
    end
  end

  def formatted_backtrace(example, exception)
    # This logic is in place to avoid an error in format_backtrace. The
    # probelm is RSpec versions below 3.5 will throw an exception.
    return [] unless example

    formatter = RSpec.configuration.backtrace_formatter
    formatter.format_backtrace(exception.backtrace, example.metadata)
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def process_source
    return '' if @backtrace_message.empty?

    data = @backtrace_message.first.split(':')

    return if data.empty?

    if os == :windows
      file_path = data[0] + ':' + data[1]
      line_number = data[2].to_i
    else
      file_path = data.first
      line_number = data[1].to_i
    end

    lines = File.readlines(file_path)
    start_line = line_number - 2
    end_line = line_number + 3
    source = lines[start_line..end_line]
             .join("")
             .sub(
               lines[line_number - 1]
               .chomp, "--->#{lines[line_number - 1].chomp}"
             )

    formatter = Rouge::Formatters::HTML.new(
      css_class: 'highlight', line_numbers: true, start_line: start_line + 1
    )

    lexer = Rouge::Lexers::Ruby.new
    formatter.format(lexer.lex(source.encode('utf-8')))
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def process_message
    formatter = Rouge::Formatters::HTML.new(css_class: 'highlight')
    lexer = Rouge::Lexers::Ruby.new
    formatter.format(lexer.lex(@message))
  end
end
