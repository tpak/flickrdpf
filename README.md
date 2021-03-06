# flickrDPF

## Author
Chris Tirpak

## Other

This utility will fetch photos from flickr.

It requires API key and shared secret from flickr - they are free.

It will fetch pictures for a flickr username
 - can narrow down by tags(s)
 - will get pictures for username with any of those tags

You may specify the max number of pics for a username that you want
 - will also get rid of older photos

You can specify fetching favorites
	- if you do, it ignores username and fetches pics from the username that authorized the picture frame initially
	
So for example:
	- we have users mom, sue, and dave
	- mom sets up the picture frame
	- mom gets an api key from flickr
	- mom runs the initial set up
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

flickrDPF is released under the very permissive [MIT license](LICENSE)
	