dwh = require './dir-watcher-helper'
fs = require 'fs'
inotifyFactory = require 'inotify-plusplus'
path = require 'path'
util = require 'util'

# globals
inotify = undefined

# public functions
exports.create = (fileChangedCallback) ->
	watchedDirectories = []

	addDirectory = (dir) ->
		# path.resolve normalises the argument to an absolute path minus the ending forward slash
		dir = path.resolve(dir)
		dwh.walkDirectoryTree dir, (entry, isDir) ->
			if isDir and entry not in watchedDirectories
				watchedDirectories[entry] = inotify.watch
					close_write: (e) ->
						fileChangedCallback path.resolve(e.watch, e.name)
					create: (e) ->
						addDirectory path.resolve(e.watch, e.name)
					moved_to: (e) ->
						# check that it's a file first
						file = path.resolve(e.watch, e.name)
						dwh.isFile file, (isFile) ->
							fileChangedCallback path.resolve(e.watch, e.name) if isFile
				, entry
	
	return {
		get: ->
			key for key, value of watchedDirectories
		watch: (dir) ->
			addDirectory dir
	}

exports.setup = (persist) ->
	inotify = inotifyFactory.create persist

exports.isDirectory = dwh.isDirectory

exports.isDirectorySync = dwh.isDirectorySync

exports.isFile = dwh.isFile

exports.isFileSync = dwh.isFileSync

exports.iterateDirectory = dwh.iterateDirectory

exports.walkDirectoryTree = dwh.walkDirectoryTree

exports.walkDirectoryTreeSync = dwh.walkDirectoryTreeSync