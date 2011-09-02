fs = require 'fs'
path = require 'path'

# private functions
isDirectory = (dir, callback) ->
	fs.stat dir, (err, stats) ->
		if err?
			callback false
		else
			callback stats.isDirectory()

isDirectorySync = (dir, callback) ->
	try
		fs.statSync(dir).isDirectory()
	catch err
		false

isFile = (file, callback) ->
	fs.stat file, (err, stats) ->
		if err?
			callback false
		else
			callback stats.isFile()

isFileSync = (file, callback) ->
	try
		fs.statSync(file).isFile()
	catch err
		false

iterateDirectory = (dir, iterator) ->
	fs.readdir dir, (err, entries) ->
		throw err if err?
		for entry in entries
			iterator path.resolve(dir, entry)

walkDirectoryTree = (dir, iterator) ->
	# path.resolve normalises to an absolute path
	dir = path.resolve dir

	# isDirectory needs to be a synchronous call because directories could be deleted after the isDirectory flag is set to true during an asynchronous call
	isDir = isDirectorySync dir
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