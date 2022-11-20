## User interface, just set the main filename and it will do everything for you
# If you have any extra code or images included list them in EXTRA_FILES
# This should work as long as you have all the .tex, .sty and .bib files in
# the same folder.
MAINFILE = main

## Inner workings
OBJECTS = $(wildcard *.tex body/*.tex)
STYLES = $(wildcard *.sty)
BIB = $(wildcard *.bib)
DRAWS = $(wildcard drawio/*.drawio)

EXTRA_FILES := $(wildcard images/*)
DRAWS_FILES := $(addsuffix .drawpic, $(basename $(DRAWS)))

OBJECTS_TEST = $(addsuffix .t, $(basename $(OBJECTS)))
STYLES_TEST = $(addsuffix .s, $(basename $(STYLES)))
BIB_TEST = bib
TESTS = $(addprefix make/, $(OBJECTS_TEST) $(STYLES_TEST) $(BIB_TEST))
TEMP2 := $(shell mkdir -p make/body 2>/dev/null)

LATEX 	?= pdflatex
BIBTEX 	?= bibtex
DRAWIO  ?= drawio

LATEX_FLAGS = -synctex=1 -shell-escape -interaction=nonstopmode -file-line-error
DRAWIO_FLAGS = -f pdf -x --crop

.PHONY: all
all: $(MAINFILE).dvi $(MAINFILE).pdf
	/bin/bash xdg-open $(MAINFILE).pdf

$(MAINFILE).dvi: $(DRAWS_FILES) $(TESTS) $(EXTRA_FILES)
	$(LATEX) $(LATEX_FLAGS) $(MAINFILE)
	$(LATEX) $(LATEX_FLAGS) $(MAINFILE)

$(MAINFILE).pdf: $(DRAWS_FILES) $(TESTS) $(EXTRA_FILES)
	$(LATEX) $(LATEX_FLAGS) $(MAINFILE)
	$(LATEX) $(LATEX_FLAGS) $(MAINFILE)
	
make/%.t: %.tex
	@touch $@

make/%.s: %.sty
	@touch $@

make/bib: $(BIB)
	$(LATEX) $(LATEX_FLAGS) $(MAINFILE)
	$(BIBTEX) $(MAINFILE)
	@touch $@

%.drawpic: %.drawio
	$(DRAWIO) $(DRAWIO_FLAGS) $< -o $@
	mv $@ $(addsuffix .pdf, $(basename $<))

.PHONY: clean
clean:
	-rm -f *.aux body/*.aux
	-rm -f *.log body/*.log
	-rm -f *.toc body/*.toc
	-rm -f *.bbl body/*.bbl
	-rm -f *.blg body/*.blg
	-rm -f *.out body/*.out
	-rm -f *.drawpic drawio/*.pdf
	-rm -f make/bib

.PHONY: distclean
distclean: clean
	-rm -f *.pdf
	-rm -f *.ps
	-rm -f *.dvi
	-rm -f *.synctex.gz
	-rm -rf make
