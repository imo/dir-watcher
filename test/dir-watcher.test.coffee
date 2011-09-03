cp = require 'child_process'
dirWatcher = require '../src/dir-watcher'
fs = require 'fs'
path = require 'path'
should = require 'should'

# private functions

makeDirIfNotExists = (dir) ->
	fs.mkdirSync(dir, 0777) if !path.existsSync(dir)

treeListToRelativePath = (basePath, treeList) ->
	startPos = basePath.length + 1
	(entry.slice(startPos) for entry in treeList)

# init

dirWatcher.setup false
tempDir = path.resolve __dirname, '..', 'temp'
makeDirIfNotExists(tempDir, 0777)

# first test (rm -rf: recursively remove all contents of a directory)
dirWatcher.rmRecursiveSync tempDir
fs.readdirSync(tempDir).length.should.equal 0

# more tests

exports.testGetMirrorPathRoot = ->
	baseDirectoryPath = '/'
	filePath = '/src/file1.txt'
	oldDirectoryName = 'src'
	newDirectoryName = 'lib'
	dirWatcher.getMirrorPath(baseDirectoryPath, filePath, oldDirectoryName, newDirectoryName).should.equal '/lib/file1.txt'

exports.testGetMirrorPathSubdirectory = ->
	baseDirectoryPath = '/home/username/'
	filePath = '/home/username/src/file1.txt'
	oldDirectoryName = 'src'
	newDirectoryName = 'lib'
	dirWatcher.getMirrorPath(baseDirectoryPath, filePath, oldDirectoryName, newDirectoryName).should.equal '/home/username/lib/file1.txt'

exports.testGetMirrorPathFilePathSubdirectory = ->
	baseDirectoryPath = '/var/log/'
	filePath = '/var/log/old/subdir/file.log'
	oldDirectoryName = 'old'
	newDirectoryName = 'new'
	dirWatcher.getMirrorPath(baseDirectoryPath, filePath, oldDirectoryName, newDirectoryName).should.equal '/var/log/new/subdir/file.log'

exports.testGetMirrorPathWithoutTrailingSlash = ->
	baseDirectoryPath = '/var/log'
	filePath = '/var/log/old/file.log'
	oldDirectoryName = 'old'
	newDirectoryName = 'new'
	dirWatcher.getMirrorPath(baseDirectoryPath, filePath, oldDirectoryName, newDirectoryName).should.equal '/var/log/new/file.log'

exports.testGetMirrorPathWithFilenameWithoutExtension = ->
	baseDirectoryPath = '/var/log/'
	filePath = '/var/log/old/sub1/sub2/filename'
	oldDirectoryName = 'old'
	newDirectoryName = 'new'
	dirWatcher.getMirrorPath(baseDirectoryPath, filePath, oldDirectoryName, newDirectoryName).should.equal '/var/log/new/sub1/sub2/filename'

exports.testGetMirrorPathWithBaseDirectoryPathTooLong = ->
	baseDirectoryPath = '/var/log/toolongpath/blahblahblah'
	filePath = '/var/old/file.log'
	oldDirectoryName = 'old'
	newDirectoryName = 'new'
	try
		dirWatcher.getMirrorPath baseDirectoryPath, filePath, oldDirectoryName, newDirectoryName
		throw 'Exception should have been raised for baseDirectoryPath and oldDirectory being too long.'
	catch err
		err.should.equal 'getMirrorPath Error: baseDirectoryPath + oldDirectoryName should be shorter than filePath.'

exports.testGetMirrorPathWithNonMatchingPaths = ->
	baseDirectoryPath = '/var/log/'
	filePath = '/var/log/nonexistent/file.log'
	oldDirectoryName = 'old'
	newDirectoryName = 'new'
	try
		dirWatcher.getMirrorPath baseDirectoryPath, filePath, oldDirectoryName, newDirectoryName
		throw 'Exception should have been raised for the prefix of filePath not matching baseDirectoryPath + oldDirectoryName.'
	catch err
		err.should.equal 'getMirrorPath Error: The prefix of filePath should match baseDirectoryPath + oldDirectoryName.'

exports.testGetRelativePathRoot = ->
	dirWatcher.getRelativePath('/', '/qwerty/apple').should.equal('qwerty/apple')

exports.testGetRelativePathSubdirectory = ->
	dirWatcher.getRelativePath('/test/asdf/', '/test/asdf/qwer').should.equal('qwer')

exports.testGetRelativePathTooLong = ->
	try
		dirWatcher.getRelativePath('/test/asdf/', '/test')
		throw 'Exception should have been raised for basePath being too long.'
	catch err
		err.should.equal 'getPathSuffix Error: basePath should be shorter than or equal to longPath.'

exports.testGetRelativePathNoMatch = ->
	try
		dirWatcher.getRelativePath('/test', '/asdf/qwer')
		throw 'Exception should have been raised for basePath differing to longPath.'
	catch err
		err.should.equal 'getPathSuffix Error: The prefix of longPath should match basePath.'

exports.testIsDirectorySyncTrue = ->
	dirWatcher.isDirectorySync(__dirname).should.be.true

exports.testIsDirectorySyncFalseForFile = ->
	dirWatcher.isDirectorySync(__dirname + '/dir-watcher.test.coffee').should.be.false

exports.testIsFileSyncTrue = ->
	dirWatcher.isFileSync(path.resolve(__dirname, 'dir-watcher.test.coffee')).should.be.true

exports.testIsFileSyncFalseForDirectory = ->
	dirWatcher.isFileSync(__dirname).should.be.false

exports.testWalkDirectoryTreeSync = ->
	startPos = __dirname.length + 1
	treeList = treeListToRelativePath(__dirname, dirWatcher.walkDirectoryTreeSync(__dirname))
	JSON.stringify(treeList).should.equal '["","dir-watcher.test.coffee","folder1","folder1/dummy","folder2","folder2/dummy","folder2/folder4","folder2/folder4/dummy","folder3","folder3/dummy"]'

exports.testWatchWriteAndRenameFile = ->
	testDir = path.resolve tempDir, 'writeAndRenameFile'
	makeDirIfNotExists testDir

	testFile1 = path.resolve testDir, 'testFile1.txt'
	testFile2 = path.resolve testDir, 'testFile2.txt'

	changeCount = 0
	testWatcher = dirWatcher.create (entry) ->
		switch changeCount
			when 0 then entry.should.equal testFile1
			when 1 then entry.should.equal testFile2
		changeCount++
	testWatcher.watchDirectoryTreeSync testDir

	fs.writeFileSync testFile1, 'test'
	fs.renameSync testFile1, testFile2
	fs.unlinkSync testFile2

	setTimeout ->
		JSON.stringify(treeListToRelativePath(testDir, testWatcher.get())).should.equal '[""]'
		changeCount.should.equal 2
	, 500

exports.testWatchCreateAndRenameDirectory = ->
	testDir = path.resolve tempDir, 'createAndRenameDirectory'
	makeDirIfNotExists testDir
	testWatcher = dirWatcher.create()
	testWatcher.watchDirectoryTreeSync testDir

	testDir1 = path.resolve testDir, 'testDir1'
	testDir2 = path.resolve testDir, 'testDir2'
	fs.mkdirSync testDir1, 0777
	fs.renameSync testDir1, testDir2

	setTimeout ->
		JSON.stringify(treeListToRelativePath(testDir, testWatcher.get())).should.equal '["","testDir2"]'
	, 500

exports.testRemoveDirectory = ->
	testDir = path.resolve tempDir, 'removeDirectory'
	makeDirIfNotExists testDir
	testWatcher = dirWatcher.create()
	testWatcher.watchDirectoryTreeSync testDir

	testDir3 = path.resolve testDir, 'testDir3'
	fs.mkdirSync testDir3, 0777
	fs.rmdirSync testDir3
	
	setTimeout ->
		JSON.stringify(treeListToRelativePath(testDir, testWatcher.get())).should.equal '[""]'
	, 500

exports.testMakeSubdirectoryFile = ->
	testDir = path.resolve tempDir, 'makeSubdirectoryFile'
	makeDirIfNotExists testDir

	testDir4 = path.resolve testDir, 'testDir4'
	testDir4File1 = path.resolve testDir, 'testDir4', 'testFile.txt'

	changeCount = 0
	testWatcher = dirWatcher.create (entry) ->
		switch changeCount
			when 0 then entry.should.equal testDir4File1
		changeCount++
	testWatcher.watchDirectoryTreeSync testDir

	fs.mkdirSync testDir4, 0777
	# inotify doesn't work immediately so you do need to give it a bit of time
	setTimeout ->
		fs.writeFileSync testDir4File1, 'test'
	, 250

	setTimeout ->
		JSON.stringify(treeListToRelativePath(testDir, testWatcher.get())).should.equal '["","testDir4"]'
		changeCount.should.equal 1
	, 500


exports.testRenameDirectoryWithSubdirectory = ->
	testDir = path.resolve tempDir, 'renameDirectoryWithSubdirectory'
	makeDirIfNotExists testDir
	testWatcher = dirWatcher.create()
	testWatcher.watchDirectoryTreeSync testDir

	testDir5 = path.resolve testDir, 'testDir5'
	testDir5Dir1 = path.resolve testDir, 'testDir5', 'testDir1'
	testDir6 = path.resolve testDir, 'testDir6'
	testDir6Dir1 = path.resolve testDir, 'testDir6', 'testDir1'

	fs.mkdirSync testDir5, 0777
	fs.mkdirSync testDir5Dir1, 0777
	fs.renameSync testDir5, testDir6

	setTimeout ->
		JSON.stringify(treeListToRelativePath(testDir, testWatcher.get())).should.equal '["","testDir6","testDir6/testDir1"]'
	, 500