const tr = require('./build-translations.js');//.watchTranslations();
const hbs = require('./build-hbs.js');
const hound = require('hound');

const fs = require('fs');
fs.watch('./src/lang/translations', (eventType) => {
	if (eventType === 'change') {
		try {
			tr.buildTranslations(() => hbs.buildHtml() )
		}
		catch(e) {
			console.log(e);
		}
	}
});

var dirs = ['./src', './data'];
dirs.forEach(function(dir) {
	var watcher = hound.watch(dir);
	watcher.on('create', function() {
		// console.log('file created');
		try {
			hbs.buildHtml();
		}
		catch(e) {
			console.log(e);
		}
	});
	watcher.on('change', function(file) {
		// console.log('change detected', file);
		try {
			hbs.buildHtml();
		}
		catch(e) {
			console.log(e);
		}
	});
});

tr.buildTranslations(() => hbs.buildHtml() )