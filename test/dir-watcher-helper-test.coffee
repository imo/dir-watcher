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

exports.testWalkDirectory = ->
	dwh.walkDirectory __dirname, (entry) ->
		(entry[__dirname.length..entry.length] in ['', '/folder1', '/folder2', '/folder3', '/folder2/folder4']).should.be.true

exports.testWalkDirectoryListSync = ->
	dwh.walkDirectoryListSync(__dirname).length.should.equal 5