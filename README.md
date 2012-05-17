Khan Academy Map
================

Map covering the Khan Academy video library

DEVELOPMENT
=============

<code>middleman server</code>
Runs on http://0.0.0.0:4567/ per default.

CHANGELOG
=========

0.1
---
Date: 2012-05-14
Author: Benjamin

Initial release. Yay!

DATA
=========
Changes I did to the data set coming directly out of the Khan Academy API:
* Cleaned all quotes inside strings
* Cleaned all line breaks inside strings
* Removed empty playlists & topics
* Removed talks and interviews
* Removed test preparation
* Removed initial array
* Renamed "items" arrays to "children" array
* Renamed "videos" arrays to "children" array
* Enclosed "playlist" attributes into parent object
* Added name to root object
* Added id to topics

REFERENCES
==========

* Middleman:    http://middlemanapp.com
* Compass:      http://compass-style.org
* CoffeeScript: http://jashkenas.github.com/coffee-script
* D3.js: 				http://d3js.org