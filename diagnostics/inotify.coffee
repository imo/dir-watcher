inotifyFactory = require 'inotify-plusplus'
path = require 'path'
util = require 'util'

inotify = inotifyFactory.create true

inotify.watch
	all_events: (e) ->
		util.log path.resolve(e.watch, e.name) + ' - ' + e.masks
, '.', { all_events_is_catchall: true }