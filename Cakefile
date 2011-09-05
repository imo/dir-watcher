cp = require 'child_process'
util = require 'util'

run = (cmd, args) ->
	p = cp.spawn cmd, args
	p.stdout.on 'data', (data) ->
		process.stdout.write data
	p.stderr.on 'data', (data) ->
		process.stderr.write data
	p.on 'exit', (exitCode) ->
		util.log cmd + ' process exited with code ' + exitCode

task 'build', 'compile src/ to lib/', ->
	util.log 'Building...'
	run 'coffee',['-c', '-o', 'lib/', 'src/']

task 'test', 'test', (options) ->
	util.log 'Testing...'
	run 'expresso'