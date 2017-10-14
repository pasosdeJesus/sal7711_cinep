
valida: valida-js valida-ruby

valida-js:
	for i in `find app/assets/javascripts/ -name "*coffee"; find app/assets/javascripts/ -name "*coffee.erb"`; do \
	coffee -o /tmp/ $$i; \
	done

valida-ruby:
	find . -name "*\.rb" -exec ruby -w -W2 -c {} ';'
