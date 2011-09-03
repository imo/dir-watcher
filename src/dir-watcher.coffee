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
	# note: will return true for directory symbolic links
	if path.existsSync(dir)
		fs.statSync(dir).isDirectory()
	else
		false

# isFileSync needs to be a synchronous call because files could be moved/deleted after the flag is set during an asynchronous call.
isFileSync = (file) ->
	# note: will return true for file links (both hard & symbolic)
	if path.existsSync(file)
		fs.statSync(file).isFile()
	else
		false

unwatchDirectories = (dir, watchedDirectories) ->
	# if a directory was moved and it contained subdirectories, then those subdirectories need to be cleared from the list as well (they will be added back by addDirectoryToWatchList)
	if not isDirectorySync dir
		throw 'unwatchDirectories only accepts a directory as the first parameter.'

	dirTree = walkDirectoryTreeSync pathToUnwatch, true
	for entry in dirTree
		if entry in watchedDirectories
			watchedDirectories[entry]() # this unwatches the directory
			delete watchedDirectories[entry]

# walkDirectoryTreeSync will return a list of all directories & files recursively in the specified directory (including itself).
walkDirectoryTreeSync = (dir, directoriesOnly = false) ->
	# note: walkDirectoryTree needs to be a synchronous call because it ensures the directory structure remains static while the system is iterating through all the subdirectories to watch.   Many problems used to occur when it was an asynchronous call because the directory structure could change at any time, as evidenced during testing.
	if not isDirectorySync dir
		throw 'walkDirectoryTreeSync only accepts a directory as the first parameter.'

	pathList = []
	addPathToList = (entry) ->
		if path.existsSync entry
			if directoriesOnly == false then pathList.push entry
			stat = fs.statSync entry
			if stat.isDirectory()
				if directoriesOnly == true then pathList.push entry
				for subEntry in fs.readdirSync entry
					addPathToList path.resolve(entry, subEntry)
	# path.resolve normalises to an absolute path
	addPathToList path.resolve(dir)
	pathList

# public functions

exports.rmRecursiveSync = (dir) ->
	traverseDirToRemove = (removePath) ->
		for entry in fs.readdirSync(removePath)
			entryPath = path.resolve removePath, entry

			lstat = fs.lstatSync entryPath
			if lstat.isFile() or lstat.isSymbolicLink()
				# hard links come here to be deleted due to isFile()
				fs.unlinkSync entryPath
			else if lstat.isDirectory()
				traverseDirToRemove entryPath
				fs.rmdirSync entryPath
			else
				throw "rmRecursiveSync: Came across #{removePath} while removing #{dir} - it's neither a file, symlink or directory so I'm not sure what to do with it"
	traverseDirToRemove path.resolve(dir)

exports.create = (fileChangedCallback) ->
	watchedDirectories = []

	addDirectoryToWatchList = (dir) ->
		# path.resolve normalises to an absolute path minus the last forward slash
		dirTree = walkDirectoryTreeSync path.resolve(dir), true

		for dirEntry in dirTree
			if dirEntry not in watchedDirectories
				watchedDirectories[dirEntry] = inotify.watch
					close_write: (e) ->
						entry = getPath e
						fileChangedCallback entry
					create: (e) ->
						entry = getPath e
						if isDirectorySync entry
							addDirectoryToWatchList entry
					delete: (e) ->
						entry = getPath e
						if isDirectorySync entry
							unwatchDirectories entry, watchedDirectories
					moved_from: (e) ->
						entry = getPath e
						if isDirectorySync entry
							unwatchDirectories entry, watchedDirectories
					moved_to: (e) ->
						entry = getPath e
						if path.existsSync(entry)
							if fs.statSync(entry).isDirectory()
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

exports.isDirectorySync = isDirectorySync

exports.isFileSync = isFileSync

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

exports.setup = (persist) ->
	inotify = inotifyFactory.create persist

exports.walkDirectoryTreeSync = walkDirectoryTreeSync