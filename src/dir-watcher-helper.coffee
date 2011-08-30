fs = require 'fs'
path = require 'path'

exports.isDirectory = (dir, callback) ->
	fs.stat dir, (err, stats) ->
		callback !err? && stats.isDirectory()

exports.isFile = (file, callback) ->
	fs.stat file, (err, stats) ->
		callback !err? && stats.isFile()

exports.iterateDirectory = (dir, iterator) ->
	fs.readdir dir, (err, entries) ->
		for entry in entries
			iterator path.resolve(dir, entry)