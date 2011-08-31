dirWatcherFactory = require '../src/dir-watcher'
fs = require 'fs'
path = require 'path'
should = require 'should'

# only one test was written with many assertions in it because it becomes too costly to have multiple tests with multiple watchers
# (this is especially important with setTimeout below which checks that the values are correct)
exports.testWrite = ->
	testDir = path.resolve __dirname, '..', 'lib'
	testNewDir = path.resolve testDir, 'testDir'
	testFile = path.resolve testDir, 'testFile.txt'
	testFile2 = path.resolve testDir, 'testFile2.txt'
	writeCount = 0

	dirWatcherFactory.setup false
	dirWatcher = dirWatcherFactory.create (entry) ->
		(entry in [testFile, testFile2]).should.be.true
		writeCount++

	(dirWatcher.get?).should.be.true
	(dirWatcher.watch?).should.be.true
	
	dirWatcher.watch testDir
	fs.writeFile testFile, 'test', ->
		fs.rename testFile, testFile2
	fs.mkdir testNewDir, 0777

	setTimeout ->
		dirWatcher.get().length.should.equal(2)
		fs.rmdir testNewDir
		writeCount.should.equal 2
		fs.unlink testFile2
	, 500