dwh = require './dir-watcher-helper'
fs = require 'fs'
inotifyFactory = require 'inotify-plusplus'
path = require 'path'
util = require 'util'

# globals
inotify = undefined

# private functions
getPath = (e) -> path.resolve(e.watch, e.name)

unwatchDirectories = (e, watchedDirectories) ->
	# if a directory was moved or deleted and it contained subdirectories, then those subdirectories need to be cleared from the list as well
	entry = getPath e
	entryEndPos = entry.length - 1
	for key, value of watchedDirectories
		if key[0..entryEndPos] == entry
			watchedDirectories[key]() # this unwatches the directory
			delete watchedDirectories[key]

# public functions
exports.create = (fileChangedCallback) ->
	watchedDirectories = []

	addDirectory = (dir) ->
		# path.resolve normalises the argument to an absolute path minus the ending forward slash
		dir = path.resolve(dir)
		dwh.walkDirectoryTree dir, (dirEntry, isDir) ->
			if isDir and dirEntry not in watchedDirectories
				watchedDirectories[dirEntry] = inotify.watch
					close_write: (e) ->
						entry = getPath e
						fileChangedCallback entry
					create: (e) ->
						entry = getPath e
						dwh.isDirectory entry, (isDir) ->
							addDirectory entry if isDir
					delete: (e) ->
						unwatchDirectories e, watchedDirectories
					moved_from: (e) ->
						unwatchDirectories e, watchedDirectories
					moved_to: (e) ->
						entry = getPath e
						dwh.isDirectory entry, (isDir) ->
							if isDir
								addDirectory entry
							else
								fileChangedCallback entry
				, dirEntry
	
	return {
		get: ->
			key for key, value of watchedDirectories
		watchDirectoryTree: (dir) ->
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