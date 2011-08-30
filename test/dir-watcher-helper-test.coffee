dwh = require '../src/dir-watcher-helper'
path = require 'path'
should = require 'should'

exports.testIsDirectoryTrue = ->
	dwh.isDirectory __dirname, (isDirectory) ->
		isDirectory.should.be.true

exports.testIsDirectoryFalse = ->
	dwh.isDirectory __dirname + 'rubbish', (isDirectory) ->
		isDirectory.should.be.false

exports.testIsFileTrue = ->
	dwh.isFile path.resolve(__dirname, 'dir-watcher-helper-test.coffee'), (isFile) ->
		isFile.should.be.true

exports.testIsFileFalse = ->
	dwh.isFile path.resolve(__dirname, 'rubbish'), (isFile) ->
		isFile.should.be.false

exports.testIterateDirectory = ->
	dwh.iterateDirectory __dirname, (entry) ->
		(path.basename(entry) in ['dir-watcher-test.coffee', 'dir-watcher-helper-test.coffee']).should.be.true