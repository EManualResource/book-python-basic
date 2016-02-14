MAKEFILE_VERSION=2

SOURCE=./source
SOURCE_CONFIG_FILE=$(SOURCE)/book.json
TMP_BOOK=./book
DEST=./dist
IGNORE=.git
EXT_LICENSE=./_license
EXT_CONFIG=./_config
EXT_CONFIG_FILES=$(EXT_CONFIG)/*.json

default: main
	-@echo "=================="
	-@echo "  Build Success!  "
	-@echo "=================="

init:
	-rm -rf dist

pre-build:
	cp -r $(SOURCE) $(TMP_BOOK)
	rm -rf $(TMP_BOOK)/$(IGNORE)

	# create book.json
	gitbook-ext jsonmerge $(SOURCE_CONFIG_FILE) $(EXT_CONFIG_FILES) > $(TMP_BOOK)/book.json

build:
	gitbook build $(TMP_BOOK) $(DEST)/book
	gitbook-ext minify --verbose $(DEST)/book

package:
	cp $(TMP_BOOK)/book.json $(DEST)/book
	cp -rf $(EXT_LICENSE) $(DEST)/book/_license
	cd $(DEST) && zip -vr book.zip book/ 

	# post package
	md5 $(DEST)/book.zip > $(DEST)/md5

finish: 	
	# clean up
	rm -rf $(TMP_BOOK)
	
main: init pre-build build package finish
	

deploy:
	git push origin gh-pages

update-source:
	git submodule update --remote $(SOURCE)

serve:
	@echo "serve on ~> http://localhost:8000"
	cd $(DEST)/book && python -m SimpleHTTPServer 8000
	
.PHONY: default main init pre-build build package finish
