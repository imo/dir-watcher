fs = require 'fs'
inotifyFactory = require 'inotify-plusplus'
path = require 'path'
util = require 'util'

# globals
inotify = undefined

# private functions

getPath = (e) -> path.resolve(e.watch, e.name)

# isDirectorySync needs to be a synchronous call because directories could be moved/deleted after the flag is set during an asynchronous call.
isDirectorySync = (dir) ->
	if path.existsSync(dir)
		fs.statSync(dir).isDirectory()
	else
		false

# isFileSync needs to be a synchronous call because files could be moved/deleted after the flag is set during an asynchronous call.
isFileSync = (file) ->
	if path.existsSync(file)
		fs.statSync(file).isFile()
	else
		false

unwatchDirectories = (e, watchedDirectories) ->
	# if a directory was moved and it contained subdirectories, then those subdirectories need to be cleared from the list as well (they will be added back by addDirectoryToWatchList)
	entry = getPath e
	entryEndPos = entry.length - 1
	for key, value of watchedDirectories
		if key[0..entryEndPos] == entry
			watchedDirectories[key]() # this unwatches the directory
			delete watchedDirectories[key]

# walkDirectoryTree needs to be a synchronous call because it ensures the directory structure remains static while the system is iterating through all the subdirectories to watch.   Many problems used to occur when it was an asynchronous call because the directory structure could change at any time, as evidenced in the unit tests.
walkDirectoryTreeSync = (dir) ->
	pathList = []
	addPathToList = (entry) ->
		pathList.push entry
		if isDirectorySync entry
			addPathToList path.resolve(entry, subEntry) for subEntry in fs.readdirSync(entry)
	# path.resolve normalises to an absolute path
	addPathToList path.resolve(dir)
	pathList

# public functions

exports.rmRecursiveSync = (dir) ->
	traverseDirToRemove = (removePath) ->
		for entry in fs.readdirSync(removePath)
			entryPath = path.resolve(removePath, entry)
			if isDirectorySync(entryPath)
				traverseDirToRemove entryPath
				fs.rmdirSync entryPath
			else
				fs.unlinkSync entryPath
	traverseDirToRemove path.resolve(dir)

exports.create = (fileChangedCallback) ->
	watchedDirectories = []

	addDirectoryToWatchList = (dir) ->
		# path.resolve normalises the argument to an absolute path minus the ending forward slash
		dir = path.resolve(dir)

		dirTree = walkDirectoryTreeSync(dir)

		dirTree = walkDirectoryTreeSync dir
		for dirEntry in dirTree
			if isDirectorySync(dirEntry) and dirEntry not in watchedDirectories
				watchedDirectories[dirEntry] = inotify.watch
					close_write: (e) ->
						entry = getPath e
						fileChangedCallback entry
					create: (e) ->
						entry = getPath e
						addDirectoryToWatchList entry if isDirectorySync(entry)
					delete: (e) ->
						unwatchDirectories e, watchedDirectories
					moved_from: (e) ->
						unwatchDirectories e, watchedDirectories
					moved_to: (e) ->
						entry = getPath e
						if isDirectorySync(entry)
							addDirectoryToWatchList entry
						else
							fileChangedCallback entry
				, dirEntry

	return {
		get: ->
			key for key, value of watchedDirectories
		watchDirectoryTreeSync: (dir) ->
			addDirectoryToWatchList dir
	}

exports.getMirrorPath = (baseDirectoryPath, filePath, oldDirectoryName, newDirectoryName) ->
	# generate lib filename from src filename

	# init
	oldPathPrefix = path.resolve baseDirectoryPath, oldDirectoryName
	startPos = oldPathPrefix.length

	# validate
	throw 'getMirrorPath Error: baseDirectoryPath + oldDirectoryName should be shorter than filePath.' if startPos > filePath.length
	throw 'getMirrorPath Error: The prefix of filePath should match baseDirectoryPath + oldDirectoryName.' if filePath[0..startPos - 1] != oldPathPrefix

	# transform
	pathSuffix = filePath[startPos + 1..filePath.length]
	path.resolve baseDirectoryPath, newDirectoryName, pathSuffix

exports.getRelativePath = (basePath, longPath) ->
	basePath += '/' if basePath[basePath.length - 1] != '/'

	# validate
	throw 'getPathSuffix Error: basePath should be shorter than or equal to longPath.' if basePath.length > longPath.length
	throw 'getPathSuffix Error: The prefix of longPath should match basePath.' if longPath[0..basePath.length - 1] != basePath

	longPath.slice(basePath.length)

exports.isDirectorySync = isDirectorySync

exports.isFileSync = isFileSync

exports.setup = (persist) ->
	inotify = inotifyFactory.create persist

exports.walkDirectoryTreeSync = walkDirectoryTreeSync