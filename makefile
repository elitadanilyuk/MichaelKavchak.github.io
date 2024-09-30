clean:
	rm -rf ukr/_posts/*
	rm -rf latin_25/_posts/*
	rm -rf eng/_posts/*
	rm -rf _site/*

build:
	ruby _tools/convert_txt_to_poems.rb

serve:
	bundle exec jekyll serve --host=0.0.0.0 --livereload --open-url --watch

serve-network:
	bundle exec jekyll serve --host=192.168.0.55 --livereload --open-url --watch

combine-poem-txt:
	for file in _poem_txt_files/*; do cat "$file"; echo -e "\n\n"; done > _tools/combined.txt