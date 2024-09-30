require 'aws-sdk-translate'
require 'fileutils'

# Function to read text from a .txt file
def read_text_from_file(file_path)
  file_contents = File.read(file_path)
  file_contents.gsub!(/@\n/, "@\n\n")
  file_contents.gsub!(/@@\n/, "@@\n\n")
end

# Function to translate text using Amazon Translate
def translate_text(text, source_lang, target_lang)
  client = Aws::Translate::Client.new(region: 'us-east-1') # Adjust the region as needed
  resp = client.translate_text({
    text: text,
    source_language_code: source_lang,
    target_language_code: target_lang
  })
  resp.translated_text
end

# Function to save translated text to a file
def save_translated_text(output_path, file_name, translated_text)
  FileUtils.mkdir_p(output_path) unless Dir.exist?(output_path)
  output_file_path = File.join(output_path, file_name)
  File.open(output_file_path, 'w') { |file| file.write(translated_text) }
end

# Main program
input_directory = ARGV[0]
output_directory = 'Translated-Texts'

Dir.glob("#{input_directory}/*.txt").each do |txt_file_path|
  file_name = File.basename(txt_file_path, ".txt") + "-Translated.txt"
  ukrainian_text = read_text_from_file(txt_file_path)
  english_text = translate_text(ukrainian_text, 'uk', 'en-US') # Using 'en-US' for US English
  save_translated_text(output_directory, file_name, english_text)

  puts "Translation saved to #{File.join(output_directory, file_name)}"
end
