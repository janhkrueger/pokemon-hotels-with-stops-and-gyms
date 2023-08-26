# Source: https://computableverse.com/blog/create-website-using-pandoc-make-file
# Edited to conform to:
# - <https://gist.github.com/MyriaCore/75729707404cba1c0de89cc03b7a6adf>

SHELL := /bin/bash
PATH := $(shell yarn global bin):$(PATH)

# Find all markdown files
MARKDOWN=$(shell find . -iname "*.md")

# Form all 'html' counterparts
HTML=$(MARKDOWN:.md=.html)

# Use the neutral mermaid theme, blacklist mermaid in kroki filter
export MERMAID_THEME = 'neutral'
export KROKI_DIAGRAM_BLACKLIST = mermaid

.PHONY = all tar test clean
all: clean $(HTML)


# EXPERIMENTAL: Standalone Doc
notes.pdf: $(MARKDOWN)
	pandoc --from markdown --to latex \
	  --standalone \
	  --filter pandoc-plantuml \
	  --filter pandoc-mermaid \
	  --lua-filter gitlab-math.lua \
	  --lua-filter fix-links.lua \
	  --katex=https://cdn.jsdelivr.net/npm/katex@latest/dist/ \
	  --template=eisvogel \
	  -o notes.pdf $(MARKDOWN)

# EXPERIMENTAL: Standalone Doc
notes.html: $(MARKDOWN)
	pandoc --from markdown --to html5 \
	  --standalone \
	  --filter pandoc-kroki \
	  --filter pandoc-mermaid \
	  --lua-filter gitlab-math.lua \
	  --lua-filter fix-links.lua \
	  --katex=https://cdn.jsdelivr.net/npm/katex@latest/dist/ \
	  --template=GitHub.html5  \
	  -o notes.html $(MARKDOWN)

# Multiple documents
%.html: %.md
	cd $(dir $<); \
	pandoc --from markdown --to html5 \
	  --standalone \
	  --filter pandoc-kroki \
	  --filter pandoc-mermaid \
	  --lua-filter gitlab-math.lua \
	  --lua-filter fix-links.lua \
	  --katex=https://cdn.jsdelivr.net/npm/katex@latest/dist/ \
	  --template=GitHub.html5  \
	  -o $(notdir $@) $(notdir $<)

# Zip of multiple documents
tar: $(HTML)
	tar --exclude-vcs-ignores \
	  --exclude=notes.tar.gz \
	  --exclude=.git \
	  --exclude=.gitmodules \
	  --exclude=.gitlab-ci.yml \
	  --exclude=.puppeteer-config.json \
	  --exclude=*.md \
	  -czvf ../notes.tar.gz ./
	mv ../notes.tar.gz notes.tar.gz

clean:
	rm -f $(HTML)
	rm -f notes.tar.gz
	rm -f notes.pdf notes.html
	rm -rf ./mermaid-images ./plantuml-images
	rm -rf ./**/mermaid-images ./**/plantuml-images