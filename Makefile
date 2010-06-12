.PHONY: \
	crank \
	clean

BUILD=build
SOURCE=s

default: crank

crank:
	podium clean build
	cp -R static/* $(BUILD)/

clean:
	podium clean

test: crank
	prove t/html.t

# This is only useful for Andy
rsync:
	rsync -azu -e ssh --delete --verbose \
	    $(BUILD)/ andy@huggy.petdance.com:/srv/p101
