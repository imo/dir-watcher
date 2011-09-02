dwh = require '../src/dir-watcher-helper'
path = require 'path'
should = require 'should'

exports.testIsDirectoryTrue = ->
	dwh.isDirectory __dirname, (isDirectory) ->
		isDirectory.should.be.true

exports.testIsDirectoryFalseForFile = ->
	dwh.isDirectory __dirname + '/dir-watcher-test.coffee', (isDirectory) ->
		isDirectory.should.be.false

exports.testIsFileTrue = ->
	dwh.isFile path.resolve(__dirname, 'dir-watcher-helper-test.coffee'), (isFile) ->
		isFile.should.be.true

exports.testIsFileFalseForDirectory = ->
	dwh.isFile __dirname, (isFile) ->
		isFile.should.be.false

exports.testIterateDirectory = ->
	dwh.iterateDirectory __dirname, (entry) ->
		(path.basename(entry) in ['dir-watcher-test.coffee', 'dir-watcher-helper-test.coffee', 'folder1', 'folder2', 'folder3']).should.be.true

exports.testWalkDirectoryTree = ->
	dwh.walkDirectoryTree __dirname, (entry) ->
		(entry[__dirname.length..entry.length] in [
			'',
			'/dir-watcher-helper-test.coffee', 
			'/dir-watcher-test.coffee',
			'/folder1', 
			'/folder1/dummy', 
			'/folder2', 
			'/folder2/dummy', 
			'/folder3', 
			'/folder3/dummy', 
			'/folder2/folder4', 
			'/folder2/folder4/dummy'
		]).should.be.true

exports.testWalkDirectoryTreeSync = ->
	dwh.walkDirectoryTreeSync(__dirname).length.should.equal 11