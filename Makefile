.PHONY: \
	crank \
	clean

default: crank

crank:
	rm -fr 101/*.html
	mkdir 101/ || true > /dev/null 2>&1
	perl crank 101.pod
	rsync -azu --delete \
		--exclude=.svn --exclude='*~' \
		static/ 101/static/
	rsync -azu --delete \
		--exclude=.svn --exclude='*~' \
		s/ 101/s/

clean:
	rm -fr 101/

# This is only useful for Andy
rsync:
	rsync -azu -e ssh --delete \
	    101/ petdance@midhae.pair.com:~/p/
