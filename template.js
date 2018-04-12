const Promise = require('bluebird')
const fs = Promise.promisifyAll(require('fs-extra'))
const commandLineArgs = require('command-line-args')
const getUsage = require('command-line-usage')

const usageSpec = [
	{
		header: 'template.js',
		content: 'Short description of this file.'
	},
	{
		header: 'Synopsis',
		content: [
			{ colA: '$', colB: 'template.js --input <input> arguments' }
		]
	},
	{
		header: 'Options',
		optionList: [
			{ name: 'input',  alias: 'i', type: String, typeLabel: 'input', description: 'Example for an option' },
			{ name: 'help',   alias: 'h', type: Boolean, description: 'Show help' }
		]
	}
]

const options = commandLineArgs(usageSpec.find(x =>('optionList' in x)).optionList)
if(options.help) {
	console.log(getUsage(usageSpec))
	process.exit(1)
}
