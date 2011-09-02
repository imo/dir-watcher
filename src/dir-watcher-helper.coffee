fs = require 'fs'
path = require 'path'

# private functions
isDirectory = (dir, callback) ->
	fs.stat dir, (err, stats) ->
		throw err if err?
		callback stats.isDirectory()

isDirectorySync = (dir, callback) ->
	fs.statSync(dir).isDirectory()

isFile = (file, callback) ->
	fs.stat file, (err, stats) ->
		throw err if err?
		callback stats.isFile()

isFileSync = (file, callback) ->
	fs.statSync(file).isFile()

iterateDirectory = (dir, iterator) ->
	fs.readdir dir, (err, entries) ->
		throw err if err?
		for entry in entries
			iterator path.resolve(dir, entry)

walkDirectoryTree = (dir, iterator) ->
	# path.resolve normalises to an absolute path
	dir = path.resolve(dir)
	isDirectory dir, (isDir) ->
		iterator dir, isDir
		if isDir
			iterateDirectory dir, (entry) ->
				walkDirectoryTree entry, iterator

walkDirectoryTreeSync = (dir) ->
	list = []
	addDir = (base) ->
		list.push base
		if isDirectorySync base
			addDir path.resolve(base, entry) for entry in fs.readdirSync(base)
	# path.resolve normalises to an absolute path
	addDir path.resolve(dir)
	list

# public functions
exports.isDirectory = isDirectory

exports.isDirectorySync = isDirectorySync

exports.isFile = isFile

exports.isFileSync = isFileSync

exports.iterateDirectory = iterateDirectory

exports.walkDirectoryTree = walkDirectoryTree

exports.walkDirectoryTreeSync = walkDirectoryTreeSync