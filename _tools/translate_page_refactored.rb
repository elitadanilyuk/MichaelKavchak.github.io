require 'aws-sdk-translate'
require 'fileutils'

class TextTranslator
  DEFAULT_REGION = 'us-east-1'.freeze
  OUTPUT_DIR = 'Translated-Texts'.freeze

  def initialize
    @client = Aws::Translate::Client.new(region: DEFAULT_REGION)
  end

  def process_directory(input_dir)
    Dir.glob("#{input_dir}/*.txt").each do |file_path|
      process_file(file_path)
    rescue StandardError => e
      puts "Error processing #{file_path}: #{e.message}"
    end
  end

  private

  def process_file(file_path)
    content = read_file(file_path)
    translated = translate(content, 'uk', 'en-US')
    output_path = save_translation(File.basename(file_path), translated)
    puts "Translation saved to #{output_path}"
  end

  def read_file(path)
    content = File.read(path)
    content.gsub(/@+\n/) { |match| "#{match}\n" }
  end

  def translate(text, source_lang, target_lang)
    @client.translate_text({
      text: text,
      source_language_code: source_lang,
      target_language_code: target_lang
    }).translated_text
  rescue Aws::Translate::Errors::ServiceError => e
    raise "Translation failed: #{e.message}"
  end

  def save_translation(original_name, content)
    FileUtils.mkdir_p(OUTPUT_DIR)
    output_name = original_name.gsub(/\.txt$/, '-Translated.txt')
    output_path = File.join(OUTPUT_DIR, output_name)

    File.write(output_path, content)
    output_path
  end
end

# Main execution
if ARGV.empty?
  puts "Usage: ruby script.rb <input_directory>"
  exit 1
end

translator = TextTranslator.new
translator.process_directory(ARGV[0])
