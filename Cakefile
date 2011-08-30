cp = require 'child_process'

run = (cmd, args) ->
	p = cp.spawn cmd, args
	p.stdout.on 'data', (data) ->
		process.stdout.write data
	p.stderr.on 'data', (data) ->
		process.stderr.write data
	p.on 'exit', (code) ->
		console.log cmd + ' process exited with code ' + code

task 'build', 'compile & npm install', (options) ->
	run 'coffee', ['-c', '-o', 'lib/', 'src/']

task 'test', 'test', (options) ->
	run 'coffee', ['test/dir-watcher-test.coffee']