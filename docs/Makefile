DOCSDIR ?= site

docs: $(DOCSDIR)/index.html

$(DOCSDIR)/index.html:
	mkdocs build --site-dir $<
