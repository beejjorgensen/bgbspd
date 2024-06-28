#TITLE="Beej's Guide to Network Concepts"
#SUBTITLE=""
#AUTHOR='Brian “Beej Jorgensen” Hall'
#VERSION_DATE="v1.0.21, Copyright © March 4, 2024"

#GUIDE_ID=bgnet0

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
	-H $(BGBSPD_BUILD_DIR)/latex/header_index.latex \
	-H $(BGBSPD_BUILD_DIR)/latex/header_bullets.latex \
	-A $(BGBSPD_BUILD_DIR)/latex/after_index.latex \
	--pdf-engine=xelatex \
	--variable mainfont=$(PDF_MAINFONT) \
	--variable sansfont=$(PDF_SANSFONT) \
	--variable monofont=$(PDF_MONOFONT) \
	--variable geometry:"top=1in,bottom=1in" \
	-V documentclass=book \
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
BLANKLAST=-A $(BGBSPD_BUILD_DIR)/latex/after_blank.latex # add a blank last page
BW=--no-highlight  # black and white options
COLOR=--highlight-style=tango   # color options

all: $(HTML) split/index.html split-wide/index.html $(BOOKS)

bg-css.html: $(BGBSPD_BUILD_DIR)/html/common-css-src.html
	cat $^ > $@

bg-css-wide.html: $(BGBSPD_BUILD_DIR)/html/common-css-src.html $(BGBSPD_BUILD_DIR)/html/widescreen-css-src.html
	cat $^ > $@

$(GUIDE_ID).html: $(GUIDE_MD) bg-css.html
	$(PREPROC) $(GUIDE_MD) $(PREPROC_TEMP_PREFIX)_html.md
	pandoc $(HTML_OPTS) -s $(PREPROC_TEMP_PREFIX)_html.md -o $@ -H bg-css.html
	sed 's/src="\(.*\)\.pdf"/src="\1.svg"/g' $@ > $(TEMP_PREFIX)_html.html # use svg images
	mv $(TEMP_PREFIX)_html.html $@
	rm -f $(TEMP_PREFIX)*_html.* texput.log

$(GUIDE_ID)-wide.html: $(GUIDE_MD) bg-css-wide.html
	$(PREPROC) $(GUIDE_MD) $(PREPROC_TEMP_PREFIX)_html_wide.md
	pandoc $(HTML_OPTS) -s $(PREPROC_TEMP_PREFIX)_html_wide.md -o $@ -H bg-css-wide.html
	sed 's/src="\(.*\)\.pdf"/src="\1.svg"/g' $@ > $(TEMP_PREFIX)_html_wide.html # use svg images
	mv $(TEMP_PREFIX)_html_wide.html $@
	rm -f $(TEMP_PREFIX)*_html_wide.* texput.log

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

$(GUIDE_ID).epub: $(GUIDE_MD)
	$(PREPROC) $^ $(PREPROC_TEMP_PREFIX)_epub.md
	pandoc $(COMMON_OPTS) --webtex --metadata author=$(AUTHOR) --metadata title=$(TITLE) -o $@ $(PREPROC_TEMP_PREFIX)_epub.md

$(GUIDE_ID)_quick.pdf: $(GUIDE_MD)
	$(PREPROC) $^ $(PREPROC_TEMP_PREFIX)_quick.md
	pandoc $(PDF_OPTS) $(USLETTER) $(ONESIDE) $(COLOR) -o $(TEMP_PREFIX)_quick.tex $(PREPROC_TEMP_PREFIX)_quick.md
	xelatex $(TEMP_PREFIX)_quick.tex
	mv $(TEMP_PREFIX)_quick.pdf $@
	rm -f $(TEMP_PREFIX)*_quick.* texput.log

$(GUIDE_ID)_usl_c_1.pdf: $(GUIDE_MD)
	$(PREPROC) $^ $(PREPROC_TEMP_PREFIX)_usl_c_1.md
	pandoc $(PDF_OPTS) $(USLETTER) $(ONESIDE) $(COLOR) -o $(TEMP_PREFIX)_usl_c_1.tex $(PREPROC_TEMP_PREFIX)_usl_c_1.md
	xelatex $(TEMP_PREFIX)_usl_c_1.tex
	makeindex $(TEMP_PREFIX)_usl_c_1.idx
	xelatex $(TEMP_PREFIX)_usl_c_1.tex
	xelatex $(TEMP_PREFIX)_usl_c_1.tex
	mv $(TEMP_PREFIX)_usl_c_1.pdf $@
	rm -f $(TEMP_PREFIX)*_usl_c_1.* texput.log

$(GUIDE_ID)_usl_c_2.pdf: $(GUIDE_MD)
	$(PREPROC) $^ $(PREPROC_TEMP_PREFIX)_usl_c_2.md
	pandoc $(PDF_OPTS) $(USLETTER) $(TWOSIDE) $(COLOR) -o $(TEMP_PREFIX)_usl_c_2.tex $(PREPROC_TEMP_PREFIX)_usl_c_2.md
	xelatex $(TEMP_PREFIX)_usl_c_2.tex
	makeindex $(TEMP_PREFIX)_usl_c_2.idx
	xelatex $(TEMP_PREFIX)_usl_c_2.tex
	xelatex $(TEMP_PREFIX)_usl_c_2.tex
	mv $(TEMP_PREFIX)_usl_c_2.pdf $@
	rm -f $(TEMP_PREFIX)*_usl_c_2.* texput.log

$(GUIDE_ID)_a4_c_1.pdf: $(GUIDE_MD)
	$(PREPROC) $^ $(PREPROC_TEMP_PREFIX)_a4_c_1.md
	pandoc $(PDF_OPTS) $(A4) $(ONESIDE) $(COLOR) -o $(TEMP_PREFIX)_a4_c_1.tex $(PREPROC_TEMP_PREFIX)_a4_c_1.md
	xelatex $(TEMP_PREFIX)_a4_c_1.tex
	makeindex $(TEMP_PREFIX)_a4_c_1.idx
	xelatex $(TEMP_PREFIX)_a4_c_1.tex
	xelatex $(TEMP_PREFIX)_a4_c_1.tex
	mv $(TEMP_PREFIX)_a4_c_1.pdf $@
	rm -f $(TEMP_PREFIX)*_a4_c_1.* texput.log

$(GUIDE_ID)_a4_c_2.pdf: $(GUIDE_MD)
	$(PREPROC) $^ $(PREPROC_TEMP_PREFIX)_a4_c_2.md
	pandoc $(PDF_OPTS) $(A4) $(TWOSIDE) $(COLOR) -o $(TEMP_PREFIX)_a4_c_2.tex $(PREPROC_TEMP_PREFIX)_a4_c_2.md
	xelatex $(TEMP_PREFIX)_a4_c_2.tex
	makeindex $(TEMP_PREFIX)_a4_c_2.idx
	xelatex $(TEMP_PREFIX)_a4_c_2.tex
	xelatex $(TEMP_PREFIX)_a4_c_2.tex
	mv $(TEMP_PREFIX)_a4_c_2.pdf $@
	rm -f $(TEMP_PREFIX)*_a4_c_2.* texput.log

$(GUIDE_ID)_usl_bw_1.pdf: $(GUIDE_MD)
	$(PREPROC) $^ $(PREPROC_TEMP_PREFIX)_usl_bw_1.md
	pandoc $(PDF_OPTS) $(USLETTER) $(ONESIDE) $(BW) -o $(TEMP_PREFIX)_usl_bw_1.tex $(PREPROC_TEMP_PREFIX)_usl_bw_1.md
	xelatex $(TEMP_PREFIX)_usl_bw_1.tex
	makeindex $(TEMP_PREFIX)_usl_bw_1.idx
	xelatex $(TEMP_PREFIX)_usl_bw_1.tex
	xelatex $(TEMP_PREFIX)_usl_bw_1.tex
	mv $(TEMP_PREFIX)_usl_bw_1.pdf $@
	rm -f $(TEMP_PREFIX)*_usl_bw_1.* texput.log

$(GUIDE_ID)_usl_bw_2.pdf: $(GUIDE_MD)
	$(PREPROC) $^ $(PREPROC_TEMP_PREFIX)_usl_bw_2.md
	pandoc $(PDF_OPTS) $(USLETTER) $(TWOSIDE) $(BW) -o $(TEMP_PREFIX)_usl_bw_2.tex $(PREPROC_TEMP_PREFIX)_usl_bw_2.md
	xelatex $(TEMP_PREFIX)_usl_bw_2.tex
	makeindex $(TEMP_PREFIX)_usl_bw_2.idx
	xelatex $(TEMP_PREFIX)_usl_bw_2.tex
	xelatex $(TEMP_PREFIX)_usl_bw_2.tex
	mv $(TEMP_PREFIX)_usl_bw_2.pdf $@
	rm -f $(TEMP_PREFIX)*_usl_bw_2.* texput.log

$(GUIDE_ID)_a4_bw_1.pdf: $(GUIDE_MD)
	$(PREPROC) $^ $(PREPROC_TEMP_PREFIX)_a4_bw_1.md
	pandoc $(PDF_OPTS) $(A4) $(ONESIDE) $(BW) -o $(TEMP_PREFIX)_a4_bw_1.tex $(PREPROC_TEMP_PREFIX)_a4_bw_1.md
	xelatex $(TEMP_PREFIX)_a4_bw_1.tex
	makeindex $(TEMP_PREFIX)_a4_bw_1.idx
	xelatex $(TEMP_PREFIX)_a4_bw_1.tex
	xelatex $(TEMP_PREFIX)_a4_bw_1.tex
	mv $(TEMP_PREFIX)_a4_bw_1.pdf $@
	rm -f $(TEMP_PREFIX)*_a4_bw_1.* texput.log

$(GUIDE_ID)_a4_bw_2.pdf: $(GUIDE_MD)
	$(PREPROC) $^ $(PREPROC_TEMP_PREFIX)_a4_bw_2.md
	pandoc $(PDF_OPTS) $(A4) $(TWOSIDE) $(BW) -o $(TEMP_PREFIX)_a4_bw_2.tex $(PREPROC_TEMP_PREFIX)_a4_bw_2.md
	xelatex $(TEMP_PREFIX)_a4_bw_2.tex
	makeindex $(TEMP_PREFIX)_a4_bw_2.idx
	xelatex $(TEMP_PREFIX)_a4_bw_2.tex
	xelatex $(TEMP_PREFIX)_a4_bw_2.tex
	mv $(TEMP_PREFIX)_a4_bw_2.pdf $@
	rm -f $(TEMP_PREFIX)*_a4_bw_2.* texput.log

$(GUIDE_ID)_lulu.md: $(GUIDE_MD)
	$(PREPROC) $^ $@

$(GUIDE_ID)_lulu.pdf: $(GUIDE_ID)_lulu.md
	pandoc $(PDF_OPTS) $(TWOSIDE) $(CROWNQUARTO) $(BLANKLAST) $(COLOR) -o $(TEMP_PREFIX)_lulu.tex $<
	xelatex $(TEMP_PREFIX)_lulu.tex
	makeindex $(TEMP_PREFIX)_lulu.idx
	xelatex $(TEMP_PREFIX)_lulu.tex
	xelatex $(TEMP_PREFIX)_lulu.tex
	mv $(TEMP_PREFIX)_lulu.pdf $@
	rm -f $(TEMP_PREFIX)*_lulu.* texput.log

$(GUIDE_ID)_amazon.md: $(GUIDE_MD)
	$(PREPROC) $^ $@

$(GUIDE_ID)_amazon.pdf: $(GUIDE_ID)_amazon.md
	pandoc $(PDF_OPTS) $(TWOSIDE) $(SIZE_75x925_AMAZON) $(BLANKLAST) $(COLOR) -o $(TEMP_PREFIX)_amazon.tex $<
	xelatex $(TEMP_PREFIX)_amazon.tex
	makeindex $(TEMP_PREFIX)_amazon.idx
	xelatex $(TEMP_PREFIX)_amazon.tex
	xelatex $(TEMP_PREFIX)_amazon.tex
	mv $(TEMP_PREFIX)_amazon.pdf $@
	rm -f $(TEMP_PREFIX)*_amazon.* texput.log

clean:
	rm -f $(GUIDE_ID)_temp* $(GUIDE_ID)_quick.pdf bg-css*.html

pristine: clean
	rm -f $(HTML) $(BOOKS)
	rm -rf $(SPLIT_DIRS)

.PHONY: all, html, clean, pristine
