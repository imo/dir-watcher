fs = require 'fs'
path = require 'path'

# private functions
isDirectory = (dir, callback) ->
	fs.stat dir, (err, stats) ->
		throw err if err?
		callback stats.isDirectory()

isDirectorySync = (dir) ->
	fs.statSync(dir).isDirectory()

isFile = (file, callback) ->
	fs.stat file, (err, stats) ->
		throw err if err?
		callback stats.isFile()

iterateDirectory = (dir, iterator) ->
	fs.readdir dir, (err, entries) ->
		throw err if err?
		for entry in entries
			iterator path.resolve(dir, entry)

walkDirectory = (dir, iterator) ->
	isDirectory dir, (isDir) ->
		if isDir
			iterator dir
			iterateDirectory dir, (entry) ->
				walkDirectory entry, iterator 

walkDirectoryListSync = (dir) ->
	list = []
	addDir = (base) ->
		if isDirectorySync base
			list.push base
			addDir path.resolve(base, entry) for entry in fs.readdirSync(base)
	addDir dir
	list

# public functions
exports.isDirectory = isDirectory

exports.isFile = isFile

exports.iterateDirectory = iterateDirectory

exports.walkDirectory = walkDirectory

exports.walkDirectoryListSync = walkDirectoryListSync