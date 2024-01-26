DOCSDIR ?= docs

docs: $(DOCSDIR)/index.html

$(DOCSDIR)/index.html: $(DOCSDIR)
	mkdocs build --site-dir $<

$(DOCSDIR):
	mkdir -p $@
