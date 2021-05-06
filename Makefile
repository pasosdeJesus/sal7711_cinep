
valida: valida-js valida-ruby

valida-js:
	for i in `find app/assets/javascripts/ -name "*coffee"; find app/assets/javascripts/ -name "*coffee.erb"`; do \
	coffee -o /tmp/ $$i; \
	done

valida-ruby:
	find . -name "*\.rb" -exec ruby -w -W2 -c {} ';'

erd:
	bundle exec erd
	mv erd.pdf doc/
	convert doc/erd.pdf doc/erd.png

gen-rdoc:
	rdoc -x node_modules --op rdoc
