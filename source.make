# Example Makefile that includes this file:
#
#    TITLE="Beej's Guide to Git"
#    SUBTITLE=""
#    AUTHOR='Brian “Beej Jorgensen” Hall'
#    VERSION_DATE="v0.0.3, Copyright © July 8, 2024"
#
#    GUIDE_ID=bggit
#    BGBSPD_BUILD_DIR?=../../bgbspd
#
#    WEB_IMAGES=$(wildcard img_*svg)
#    EPUB_SVGS=$(wildcard img_*svg)
#
#    include $(BGBSPD_BUILD_DIR)/source.make

# HALF_LETTER conversion to booklet:
#
# pdfjam input.pdf \
#     --booklet true \
#     --paper letter \
#     --landscape \
#     --longedge \
#     --outfile booklet.pdf
#
# If you don't have a two-sided printer:
#
# pdftk A=booklet.pdf cat Aodd output odd.pdf
# pdftk A=booklet.pdf cat Aeven output even.pdf
#
# If you reverse the odds and evens before printing, I think that saves
# you recollating them.
#
# pdftk A=odd.pdf cat end-1 output oddr.pdf
# pdftk A=even.pdf cat end-1 output evenr.pdf
#
# 20 pages max per signature, really. More is hard to staple, fold, and
# handle.
#
# Consider trimming the thumb edge.

export GUIDE_ID

PDF_MAINFONT="Liberation Serif"
PDF_SANSFONT="Liberation Sans"
PDF_MONOFONT="Liberation Mono"
#PDF_MAINFONT="DejaVu Serif"
#PDF_SANSFONT="DejaVu Sans"
#PDF_MONOFONT="DejaVu Sans Mono"

USLETTER_COLOR=$(GUIDE_ID)_usl_c_1.pdf $(GUIDE_ID)_usl_c_2.pdf
USLETTER_BW=$(GUIDE_ID)_usl_bw_1.pdf $(GUIDE_ID)_usl_bw_2.pdf
A4_COLOR=$(GUIDE_ID)_a4_c_1.pdf $(GUIDE_ID)_a4_c_2.pdf
A4_BW=$(GUIDE_ID)_a4_bw_1.pdf $(GUIDE_ID)_a4_bw_2.pdf
BOOKS=$(USLETTER_BW) $(USLETTER_COLOR) $(A4_BW) $(A4_COLOR)

HTML=$(GUIDE_ID).html $(GUIDE_ID)-wide.html
SPLIT_DIRS=split split-wide
GUIDE_MD=$(sort $(wildcard $(GUIDE_ID)_part_*.md))

PREPROC=$(BGBSPD_BUILD_DIR)/bin/preproc

TEMP_PREFIX=$(GUIDE_ID)_temp
PREPROC_TEMP_PREFIX=$(TEMP_PREFIX)_preproc

SPLIT=$(BGBSPD_BUILD_DIR)/bin/bgsplit.py

COMMON_OPTS= \
	--variable title:$(TITLE) \
	--variable subtitle:$(SUBTITLE) \
	--variable author:$(AUTHOR) \
	--variable date:$(VERSION_DATE) \
	--number-sections \
	--toc \
	--wrap=none

PDF_OPTS= \
	-H $(BGBSPD_BUILD_DIR)/latex/header_general.latex \
	-A $(BGBSPD_BUILD_DIR)/latex/after_index.latex \
	--pdf-engine=xelatex \
	--variable mainfont=$(PDF_MAINFONT) \
	--variable sansfont=$(PDF_SANSFONT) \
	--variable monofont=$(PDF_MONOFONT) \
	--variable geometry:"top=1in,bottom=1in" \
	-V documentclass=book \
	--lua-filter $(BGBSPD_BUILD_DIR)/lua/latex_filters.lua \
	$(COMMON_OPTS)
	#	-o $(GUIDE_ID)_temp.tex \
	# -H $(BGBSPD_BUILD_DIR)/latex/header_codebox.latex \
	#-V indent \

HTML_OPTS=$(COMMON_OPTS) \
	--metadata title:$(TITLE) \
	--mathjax

ONESIDE=--variable classoption:oneside
TWOSIDE=--variable classoption:twoside
USLETTER=--variable papersize:letter
A4=--variable papersize:a4
CROWNQUARTO=--variable geometry:"paperwidth=7.444in,paperheight=9.681in,top=1in,bottom=1in,left=1in,right=1.5in" # Lulu press
CROWNQUARTO_AMAZON=--variable geometry:"paperwidth=7.444in,paperheight=9.681in,top=1in,bottom=1in,left=1.25in,right=1.25in" # Amazon
#SIZE_75x925_AMAZON=--variable geometry:"paperwidth=7.5in,paperheight=9.25in,top=1in,bottom=1in,left=1.125in,right=1.375in" # Amazon 7.5" x 9.25", margins too far inside
SIZE_75x925_AMAZON=--variable geometry:"paperwidth=7.5in,paperheight=9.25in,top=1in,bottom=1in,left=1.25in,right=1.25in" # Amazon 7.5" x 9.25"
SIZE_HALF_LETTER=--variable geometry:"paperwidth=139.5mm,paperheight=216mm,top=2cm,bottom=2cm,left=1.5cm,right=1.5cm" # Half a US letter
BLANKLAST=-A $(BGBSPD_BUILD_DIR)/latex/after_blank.latex # add a blank last page
BW=--no-highlight  # black and white options
COLOR=--highlight-style=tango   # color options

BOLD=$(shell tput bold)
RESET=$(shell tput sgr0)

EPUB_PNGS=$(EPUB_SVGS:.svg=.png)

help:
	@echo
	@echo "    $(BOLD)all$(RESET)          build everything"
	@echo "    $(BOLD)clean$(RESET)        remove temporary build products"
	@echo "    $(BOLD)pristine$(RESET)     remove all build products"
	@echo
	@echo "  Specific targets:"
	@echo
	@echo "    $(GUIDE_ID).html"
	@echo "    $(GUIDE_ID)-wide.html"
	@echo "    split/index.html"
	@echo "    split-wide/index.html"
	@echo "    $(GUIDE_ID)_usl_c_1.pdf"
	@echo "    $(GUIDE_ID)_usl_c_2.pdf"
	@echo "    $(GUIDE_ID)_usl_bw_1.pdf"
	@echo "    $(GUIDE_ID)_usl_bw_2.pdf"
	@echo "    $(GUIDE_ID)_a4_c_1.pdf"
	@echo "    $(GUIDE_ID)_a4_c_2.pdf"
	@echo "    $(GUIDE_ID)_a4_bw_1.pdf"
	@echo "    $(GUIDE_ID)_a4_bw_2.pdf"
	@echo "    $(GUIDE_ID)_amazon.pdf"
	@echo "    $(GUIDE_ID)_lulu.pdf"
	@echo

all: $(HTML) split/index.html split-wide/index.html $(BOOKS)

bg-css.html: $(BGBSPD_BUILD_DIR)/html/lightdark.html $(BGBSPD_BUILD_DIR)/html/common-css-src.html
	cat $^ > $@

bg-css-wide.html: $(BGBSPD_BUILD_DIR)/html/lightdark.html $(BGBSPD_BUILD_DIR)/html/common-css-src.html $(BGBSPD_BUILD_DIR)/html/widescreen-css-src.html
	cat $^ > $@

$(GUIDE_ID).html: $(GUIDE_MD) bg-css.html
	$(PREPROC) $(GUIDE_MD) $(PREPROC_TEMP_PREFIX)_html.md
	pandoc $(HTML_OPTS) -s $(PREPROC_TEMP_PREFIX)_html.md -o $@ -H bg-css.html
    # use svg images and strip out polyfill.io
	sed 's/src="\(.*\)\.pdf"/src="\1.svg"/g' $@ | \
        sed '/\/polyfill.io\//d' > $(TEMP_PREFIX)_html.html
	mv $(TEMP_PREFIX)_html.html $@
	#rm -f $(TEMP_PREFIX)*_html.* texput.log

$(GUIDE_ID)-wide.html: $(GUIDE_MD) bg-css-wide.html
	$(PREPROC) $(GUIDE_MD) $(PREPROC_TEMP_PREFIX)_html_wide.md
	pandoc $(HTML_OPTS) -s $(PREPROC_TEMP_PREFIX)_html_wide.md -o $@ -H bg-css-wide.html
    # use svg images and strip out polyfill.io
	sed 's/src="\(.*\)\.pdf"/src="\1.svg"/g' $@ | \
        sed '/\/polyfill.io\//d' > $(TEMP_PREFIX)_html_wide.html
	mv $(TEMP_PREFIX)_html_wide.html $@
	#rm -f $(TEMP_PREFIX)*_html_wide.* texput.log

split/index.html: $(GUIDE_ID).html
	$(SPLIT) $< split
ifdef WEB_IMAGES
	cp -v $(WEB_IMAGES) split
endif

split-wide/index.html: $(GUIDE_ID)-wide.html
	$(SPLIT) $< split-wide
ifdef WEB_IMAGES
	cp -v $(WEB_IMAGES) split-wide
endif

$(GUIDE_ID).epub: $(GUIDE_MD) $(EPUB_PNGS)
	$(PREPROC) --epub $(GUIDE_MD) $(PREPROC_TEMP_PREFIX)_epub.md
	sed 's/\(!\[.*\](.*\.\)pdf/\1png/' $(PREPROC_TEMP_PREFIX)_epub.md > $(PREPROC_TEMP_PREFIX)_epub_png.md
	pandoc $(COMMON_OPTS) $(BW) --css $(BGBSPD_BUILD_DIR)/epub/epub.css --webtex --metadata author=$(AUTHOR) --metadata title=$(TITLE) -o $@ $(PREPROC_TEMP_PREFIX)_epub_png.md

$(GUIDE_ID)_quick.pdf: $(GUIDE_MD)
	$(PREPROC) $^ $(PREPROC_TEMP_PREFIX)_quick.md
	pandoc $(PDF_OPTS) $(USLETTER) $(ONESIDE) $(COLOR) -o $(TEMP_PREFIX)_quick.tex $(PREPROC_TEMP_PREFIX)_quick.md
	xelatex $(TEMP_PREFIX)_quick.tex
	mv $(TEMP_PREFIX)_quick.pdf $@
	#rm -f $(TEMP_PREFIX)*_quick.* texput.log

$(GUIDE_ID)_usl_c_1.pdf: $(GUIDE_MD)
	$(PREPROC) $^ $(PREPROC_TEMP_PREFIX)_usl_c_1.md
	pandoc $(PDF_OPTS) $(USLETTER) $(ONESIDE) $(COLOR) -o $(TEMP_PREFIX)_usl_c_1.tex $(PREPROC_TEMP_PREFIX)_usl_c_1.md
	xelatex $(TEMP_PREFIX)_usl_c_1.tex
	makeindex $(TEMP_PREFIX)_usl_c_1.idx
	xelatex $(TEMP_PREFIX)_usl_c_1.tex
	xelatex $(TEMP_PREFIX)_usl_c_1.tex
	mv $(TEMP_PREFIX)_usl_c_1.pdf $@
	#rm -f $(TEMP_PREFIX)*_usl_c_1.* texput.log

$(GUIDE_ID)_usl_c_2.pdf: $(GUIDE_MD)
	$(PREPROC) $^ $(PREPROC_TEMP_PREFIX)_usl_c_2.md
	pandoc $(PDF_OPTS) $(USLETTER) $(TWOSIDE) $(COLOR) -o $(TEMP_PREFIX)_usl_c_2.tex $(PREPROC_TEMP_PREFIX)_usl_c_2.md
	xelatex $(TEMP_PREFIX)_usl_c_2.tex
	makeindex $(TEMP_PREFIX)_usl_c_2.idx
	xelatex $(TEMP_PREFIX)_usl_c_2.tex
	xelatex $(TEMP_PREFIX)_usl_c_2.tex
	mv $(TEMP_PREFIX)_usl_c_2.pdf $@
	#rm -f $(TEMP_PREFIX)*_usl_c_2.* texput.log

$(GUIDE_ID)_a4_c_1.pdf: $(GUIDE_MD)
	$(PREPROC) $^ $(PREPROC_TEMP_PREFIX)_a4_c_1.md
	pandoc $(PDF_OPTS) $(A4) $(ONESIDE) $(COLOR) -o $(TEMP_PREFIX)_a4_c_1.tex $(PREPROC_TEMP_PREFIX)_a4_c_1.md
	xelatex $(TEMP_PREFIX)_a4_c_1.tex
	makeindex $(TEMP_PREFIX)_a4_c_1.idx
	xelatex $(TEMP_PREFIX)_a4_c_1.tex
	xelatex $(TEMP_PREFIX)_a4_c_1.tex
	mv $(TEMP_PREFIX)_a4_c_1.pdf $@
	#rm -f $(TEMP_PREFIX)*_a4_c_1.* texput.log

$(GUIDE_ID)_a4_c_2.pdf: $(GUIDE_MD)
	$(PREPROC) $^ $(PREPROC_TEMP_PREFIX)_a4_c_2.md
	pandoc $(PDF_OPTS) $(A4) $(TWOSIDE) $(COLOR) -o $(TEMP_PREFIX)_a4_c_2.tex $(PREPROC_TEMP_PREFIX)_a4_c_2.md
	xelatex $(TEMP_PREFIX)_a4_c_2.tex
	makeindex $(TEMP_PREFIX)_a4_c_2.idx
	xelatex $(TEMP_PREFIX)_a4_c_2.tex
	xelatex $(TEMP_PREFIX)_a4_c_2.tex
	mv $(TEMP_PREFIX)_a4_c_2.pdf $@
	#rm -f $(TEMP_PREFIX)*_a4_c_2.* texput.log

$(GUIDE_ID)_usl_bw_1.pdf: $(GUIDE_MD)
	$(PREPROC) $^ $(PREPROC_TEMP_PREFIX)_usl_bw_1.md
	pandoc $(PDF_OPTS) $(USLETTER) $(ONESIDE) $(BW) -o $(TEMP_PREFIX)_usl_bw_1.tex $(PREPROC_TEMP_PREFIX)_usl_bw_1.md
	xelatex $(TEMP_PREFIX)_usl_bw_1.tex
	makeindex $(TEMP_PREFIX)_usl_bw_1.idx
	xelatex $(TEMP_PREFIX)_usl_bw_1.tex
	xelatex $(TEMP_PREFIX)_usl_bw_1.tex
	mv $(TEMP_PREFIX)_usl_bw_1.pdf $@
	#rm -f $(TEMP_PREFIX)*_usl_bw_1.* texput.log

$(GUIDE_ID)_usl_bw_2.pdf: $(GUIDE_MD)
	$(PREPROC) $^ $(PREPROC_TEMP_PREFIX)_usl_bw_2.md
	pandoc $(PDF_OPTS) $(USLETTER) $(TWOSIDE) $(BW) -o $(TEMP_PREFIX)_usl_bw_2.tex $(PREPROC_TEMP_PREFIX)_usl_bw_2.md
	xelatex $(TEMP_PREFIX)_usl_bw_2.tex
	makeindex $(TEMP_PREFIX)_usl_bw_2.idx
	xelatex $(TEMP_PREFIX)_usl_bw_2.tex
	xelatex $(TEMP_PREFIX)_usl_bw_2.tex
	mv $(TEMP_PREFIX)_usl_bw_2.pdf $@
	#rm -f $(TEMP_PREFIX)*_usl_bw_2.* texput.log

$(GUIDE_ID)_a4_bw_1.pdf: $(GUIDE_MD)
	$(PREPROC) $^ $(PREPROC_TEMP_PREFIX)_a4_bw_1.md
	pandoc $(PDF_OPTS) $(A4) $(ONESIDE) $(BW) -o $(TEMP_PREFIX)_a4_bw_1.tex $(PREPROC_TEMP_PREFIX)_a4_bw_1.md
	xelatex $(TEMP_PREFIX)_a4_bw_1.tex
	makeindex $(TEMP_PREFIX)_a4_bw_1.idx
	xelatex $(TEMP_PREFIX)_a4_bw_1.tex
	xelatex $(TEMP_PREFIX)_a4_bw_1.tex
	mv $(TEMP_PREFIX)_a4_bw_1.pdf $@
	#rm -f $(TEMP_PREFIX)*_a4_bw_1.* texput.log

$(GUIDE_ID)_a4_bw_2.pdf: $(GUIDE_MD)
	$(PREPROC) $^ $(PREPROC_TEMP_PREFIX)_a4_bw_2.md
	pandoc $(PDF_OPTS) $(A4) $(TWOSIDE) $(BW) -o $(TEMP_PREFIX)_a4_bw_2.tex $(PREPROC_TEMP_PREFIX)_a4_bw_2.md
	xelatex $(TEMP_PREFIX)_a4_bw_2.tex
	makeindex $(TEMP_PREFIX)_a4_bw_2.idx
	xelatex $(TEMP_PREFIX)_a4_bw_2.tex
	xelatex $(TEMP_PREFIX)_a4_bw_2.tex
	mv $(TEMP_PREFIX)_a4_bw_2.pdf $@
	#rm -f $(TEMP_PREFIX)*_a4_bw_2.* texput.log

$(TEMP_PREFIX)_lulu.md: $(GUIDE_MD)
	$(PREPROC) $^ $@

$(GUIDE_ID)_lulu.pdf: $(TEMP_PREFIX)_lulu.md
	pandoc $(PDF_OPTS) $(TWOSIDE) $(CROWNQUARTO) $(BLANKLAST) $(COLOR) -o $(TEMP_PREFIX)_lulu.tex $<
	xelatex $(TEMP_PREFIX)_lulu.tex
	makeindex $(TEMP_PREFIX)_lulu.idx
	xelatex $(TEMP_PREFIX)_lulu.tex
	xelatex $(TEMP_PREFIX)_lulu.tex
	mv $(TEMP_PREFIX)_lulu.pdf $@
	#rm -f $(TEMP_PREFIX)*_lulu.* texput.log

$(TEMP_PREFIX)_amazon.md: $(GUIDE_MD)
	$(PREPROC) $^ $@

$(GUIDE_ID)_amazon.pdf: $(TEMP_PREFIX)_amazon.md
	pandoc $(PDF_OPTS) $(TWOSIDE) $(SIZE_75x925_AMAZON) $(BLANKLAST) $(COLOR) -o $(TEMP_PREFIX)_amazon.tex $<
	xelatex $(TEMP_PREFIX)_amazon.tex
	makeindex $(TEMP_PREFIX)_amazon.idx
	xelatex $(TEMP_PREFIX)_amazon.tex
	xelatex $(TEMP_PREFIX)_amazon.tex
	mv $(TEMP_PREFIX)_amazon.pdf $@
	#rm -f $(TEMP_PREFIX)*_amazon.* texput.log

$(TEMP_PREFIX)_halfletter.md: $(GUIDE_MD)
	$(PREPROC) $^ $@

$(GUIDE_ID)_halfletter.pdf: $(TEMP_PREFIX)_halfletter.md
	pandoc $(PDF_OPTS) $(TWOSIDE) $(SIZE_HALF_LETTER) $(BLANKLAST) $(COLOR) -o $(TEMP_PREFIX)_halfletter.tex $<
	xelatex $(TEMP_PREFIX)_halfletter.tex
	makeindex $(TEMP_PREFIX)_halfletter.idx
	xelatex $(TEMP_PREFIX)_halfletter.tex
	xelatex $(TEMP_PREFIX)_halfletter.tex
	mv $(TEMP_PREFIX)_halfletter.pdf $@
	#rm -f $(TEMP_PREFIX)*_halfletter.* texput.log

%.png: %.svg
	magick -density 96 $< $@

clean:
	rm -f $(GUIDE_ID)_temp* $(GUIDE_ID)_quick.pdf bg-css*.html

pristine: clean
	rm -f $(HTML) $(BOOKS)
	rm -f $(EPUB_PNGS) $(GUIDE_ID).epub
	rm -rf $(SPLIT_DIRS)
	rm -f $(GUIDE_ID)_lulu.pdf $(GUIDE_ID)_amazon.pdf

.PHONY: help all html clean pristine
