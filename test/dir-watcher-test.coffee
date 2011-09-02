dirWatcher = require '../src/dir-watcher'
fs = require 'fs'
path = require 'path'
should = require 'should'

resolveAndUnlinkDir = (args...) ->
	dir = path.resolve args...
	fs.rmdirSync dir if path.existsSync dir
	dir

resolveAndUnlinkFile = (args...) ->
	file = path.resolve args...
	fs.unlinkSync file if path.existsSync file
	file

# only one test was written with many assertions in it because it becomes too costly to have multiple tests with multiple watchers
# (this is especially important with setTimeout below which checks that the values are correct)
exports.testWrite = ->
	testDir = path.resolve __dirname, '..', 'lib'

	testFile1 = resolveAndUnlinkFile testDir, 'testFile1.txt'
	testFile2 = resolveAndUnlinkFile testDir, 'testFile2.txt'
	testDir4File3 = resolveAndUnlinkFile testDir, 'testDir4', 'testFile3.txt'

	testDir1 = resolveAndUnlinkDir testDir, 'testDir1'
	testDir2 = resolveAndUnlinkDir testDir, 'testDir2'
	testDir3 = resolveAndUnlinkDir testDir, 'testDir3'
	testDir4 = resolveAndUnlinkDir testDir, 'testDir4'
	testDir5Dir1 = resolveAndUnlinkDir testDir, 'testDir5', 'testDir1'
	testDir5 = resolveAndUnlinkDir testDir, 'testDir5'
	testDir6Dir1 = resolveAndUnlinkDir testDir, 'testDir6', 'testDir1'
	testDir6 = resolveAndUnlinkDir testDir, 'testDir6'

	writeCount = 0

	dirWatcher.setup false
	testWatcher = dirWatcher.create (entry) ->
		(entry in [testFile1, testFile2, testDir4File3]).should.be.true
		writeCount++
	testWatcher.watchDirectoryTree testDir

	# test write file
	fs.writeFile testFile1, 'test', ->
		# test rename file
		fs.rename testFile1, testFile2, ->
			# test delete file
			fs.unlink testFile2

	# test create dir
	fs.mkdir testDir1, 0777, ->
		# test rename dir
		fs.rename testDir1, testDir2

	fs.mkdir testDir3, 0777, ->
		# test remove dir
		fs.rmdir testDir3

	# test make directory
	fs.mkdir testDir4, 0777, ->
		# test make subdirectory file
		fs.writeFile testDir4File3, 'test'
	
	fs.mkdir testDir5, 0777, ->
		# test make subdirectory
		fs.mkdir testDir5Dir1, 0777, ->
			# test rename directory with subdirectory
			fs.rename testDir5, testDir6

	setTimeout ->
		testWatcher.get().length.should.equal(5)
		writeCount.should.equal 3

		# cleanup
		fs.unlink testDir4File3
		fs.rmdir testDir4
		fs.rmdir testDir2
		fs.rmdir testDir6Dir1
		fs.rmdir testDir6
	, 1000