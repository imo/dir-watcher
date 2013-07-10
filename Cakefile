{spawn} = require 'child_process'

task 'build', 'compile src/ to lib/', ->
	spawn 'coffee',['-c', '-o', 'lib/', 'src/'], 
		stdio: 'inherit'

task 'test', 'test', (options) ->
	spawn 'expresso', [],
		stdio: 'inherit'
