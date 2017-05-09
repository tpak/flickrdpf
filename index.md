# Author
Chris Tirpak

# Description

This script will fetch photos from flickr - it requires you to have and API key and shared secret from flickr before you can use it.

# How it works:
It will fetch pictures for a given flickr username two different ways

* It will get the specified users favorites
* It will get pictures for any username username with a specified tag. This could be the same authenticated user or any other user on flickt that the authenticated user is allowed to get pictures from.

You specify the max number of pics for a username that you want. It will also get rid of older photos.
	
so for example:
	- we have flickr users mom, sue, and dave
	- mom sets up the picture frame
	- mom gets an api key from flickr
	- mom runs the initial set up - she is given an oauth link on setup that she authorizes so the app can act on her behalf
	- mom adds 4 lines to cron job
		1) fetchFlickrPics.rb -g -m 25
			-- this will get the 25 most recent of mom's favs
			-- getfaves ignores any tags you pass in
		2) fetchFlickrPics.rb -m 25 -u mom -t cats,thekids
		 	-- gets 25 most recent pictures from moms flickr account that are tagged cats or thekids
		3) fetchFlickrPics.rb -m 25 -u sue -t "4mom"
			-- gets pictures that sue took and have the tag for "4mom"
		4) fetchFlickrPics.rb -m 25 -u dave -t "4mom"
	- so now mom's picture frame has:
		- her 25 favs 
		- her 25 most recent from her account tagged cat or thekids
		- 25 most recent from sue sue and dave's accounts tagged 4mom
	- 100 pics total
	- each time someone adds pics it will download them and bump the old ones off of the back
	  - in other words its FIFO (first in, first out)
	