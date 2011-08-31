fs = require 'fs'
path = require 'path'

# private functions
isDirectory = (dir, callback) ->
	fs.stat dir, (err, stats) ->
		throw err if err?
		callback stats.isDirectory()

isFile = (file, callback) ->
	fs.stat file, (err, stats) ->
		throw err if err?
		callback stats.isFile()

iterateDirectory = (dir, iterator) ->
	fs.readdir dir, (err, entries) ->
		for entry in entries
			iterator path.resolve(dir, entry)

iterateFilesOnly = (dir, iterator) ->
	fs.readdir dir, (err, entries) ->
		for entry in entries
			file = path.resolve(dir, entry)
			isFile file, (isFileBoolean) ->
				iterator file if isFileBoolean

walkDirectory = (dir, iterator) ->
	isDirectory dir, (isDir) ->
		if isDir
			iterator dir
			iterateDirectory dir, (entry) ->
				walkDirectory entry, iterator 

# public functions
exports.isDirectory = isDirectory

exports.isFile = isFile

exports.iterateDirectory = iterateDirectory

exports.iterateFilesOnly = iterateFilesOnly

exports.walkDirectory = walkDirectory