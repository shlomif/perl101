.PHONY: \
	crank \
	clean

BUILD=build
SOURCE=s

default: crank

crank: clean
	mkdir -p $(BUILD)/ || true > /dev/null 2>&1
	perl crank --podpath=$(SOURCE) --buildpath=$(BUILD)
	cp -R static/* $(BUILD)/

clean:
	rm -fr $(BUILD)

# This is only useful for Andy
rsync:
	rsync -azu -e ssh --delete --verbose \
	    $(BUILD)/ andy@huggy.petdance.com:/srv/p101
