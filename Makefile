# 'Makefile'
MARKDOWN = pandoc --from markdown --to html --standalone 
all: $(subst :,\:,$(patsubst %.md,%.pdf,$(wildcard *.md))) Makefile

%.html: %.md
	$(MARKDOWN) $< --output $@

%.pdf: %.html
	/Applications/wkhtmltopdf.app/Contents/MacOS/wkhtmltopdf $< $@
