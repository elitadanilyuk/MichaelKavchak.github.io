require 'debug'
require 'aws-sdk-translate'
require 'date'

## COMBINE FILES SCRIPT
# for file in poems_new_txt/*; do cat "$file"; echo -e "\n\n"; done > combined.txt

Poem = Struct.new(:text, :number, :edits)

TODAY = Date.today.strftime("%Y-%m-%d")

def match_pattern(string)
  pattern = /^\d+-\d+$/i
  string.match?(pattern)
end

def write_ukr(poem)
  cleaned_number = poem.number.gsub('?', '')
  cleaned_edits = poem.edits.gsub('?', '')

  File.open("ukr/_posts/#{TODAY}-#{cleaned_number}-ukr.md", 'w') do |file|
    file.puts("---")
    file.puts("layout: post")
    file.puts("number: #{cleaned_number}")
    file.puts("edits: #{cleaned_edits}")
    file.puts("categories: poems ukr")
    file.puts("---")
    file.puts("\n")

    file.puts(poem.text)
  end
end

def write_latin_25(poem)
  cleaned_number = poem.number.gsub('?', '')
  cleaned_edits = poem.edits.gsub('?', '')

  File.open("latin_25/_posts/#{TODAY}-#{cleaned_number}-latin_25.md", 'w') do |file|
    file.puts("---")
    file.puts("layout: post")
    file.puts("number: #{cleaned_number}")
    file.puts("edits: #{cleaned_edits}")
    file.puts("categories: poems latin_25")
    file.puts("---")
    file.puts("\n")

    replacements = {
      'А' => 'A',
      'а' => 'a',
      'Б' => 'B',
      'б' => 'b',
      'В' => 'V',
      'в' => 'v',
      'Г' => 'Q',
      'г' => 'q',
      'Ґ' => 'G',
      'ґ' => 'g',
      'Д' => 'D',
      'д' => 'd',
      'Е' => 'E',
      'е' => 'e',
      'Є' => 'JE',
      'є' => 'je',
      'Ж' => 'X',
      'ж' => 'x',
      'З' => 'Z',
      'з' => 'z',
      'И' => 'Y',
      'и' => 'y',
      'І' => 'I',
      'і' => 'i',
      'Ї' => 'JI',
      'ї' => 'ji',
      'Й' => 'J',
      'й' => 'j',
      'К' => 'K',
      'к' => 'k',
      'Л' => 'L',
      'л' => 'l',
      'М' => 'M',
      'м' => 'm',
      'Н' => 'N',
      'н' => 'n',
      'О' => 'O',
      'о' => 'o',
      'П' => 'P',
      'п' => 'p',
      'Р' => 'R',
      'р' => 'r',
      'С' => 'S',
      'с' => 's',
      'Т' => 'T',
      'т' => 't',
      'У' => 'U',
      'у' => 'u',
      'Ф' => 'F',
      'ф' => 'f',
      'Х' => 'H',
      'х' => 'h',
      'Ц' => 'TS',
      'ц' => 'ts',
      'Ч' => 'TC',
      'ч' => 'tc',
      'Ш' => 'C',
      'ш' => 'c',
      'Щ' => 'CTC',
      'щ' => 'ctc',
      'Ю' => 'JU',
      'ю' => 'ju',
      'Я' => 'JA',
      'я' => 'ja',
      'Ь' => 'J',
      'ь' => 'j'
    }

    # Perform the substitutions
    latin_25_text = poem.text.chars.map do |char|
      replacements[char] || char
    end.join

    file.puts(latin_25_text)
  end
end

def write_eng(poem)
  cleaned_number = poem.number.gsub('?', '')
  cleaned_edits = poem.edits.gsub('?', '')

  today = Date.today.strftime("%Y-%m-%d")


  File.open("eng/_posts/#{TODAY}-#{cleaned_number}-eng.md", 'w') do |file|
    file.puts("---")
    file.puts("layout: post")
    file.puts("number: #{cleaned_number}")
    file.puts("edits: #{cleaned_edits}")
    file.puts("categories: poems eng")
    file.puts("---")
    file.puts("\n")

    client = Aws::Translate::Client.new(region: 'us-east-1') # Adjust the region as needed
    resp = client.translate_text({
      text: poem.text,
      source_language_code: 'uk',
      target_language_code: 'en-US'
    })

    file.puts(resp.translated_text)
  end
end


def process_file(file_path)
  # Read the file contents
  file_contents = File.readlines(file_path)
  poems = []

  # Split the file contents into lines
  current_poem = Poem.new
  current_poem.text = ''

  file_contents.each do |line|
    stripped_line = line.gsub(/[[:space:]]/, '')

    if ((stripped_line == "@@") || (stripped_line.empty? && current_poem.text.empty?))
      next
    elsif (match_pattern(stripped_line))
      current_poem.number = stripped_line.split('-')[0]
      current_poem.edits = stripped_line.split('-')[1] || '0'
      current_poem.text = current_poem.text.strip.gsub(/[\n\u00A0]+\z/, '')
      poems.push(current_poem)
      current_poem = Poem.new
      current_poem.text = ''
    else
      current_poem.text += line
    end
  end

  poem_size = poems.size

  poems.each_with_index do |poem, index|
    puts "Processing poem #{poem.number} of #{poem_size}..."
    begin
      write_ukr(poem)
      write_latin_25(poem)
      write_eng(poem)
    rescue
      puts "!!!!!!!POEM ERROR!!!!!!!"
      puts poem
      next
    end
  end
end


process_file('_tools/combined.txt')
