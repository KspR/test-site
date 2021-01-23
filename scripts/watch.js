const tr = require('./build-translations.js');//.watchTranslations();
const hbs = require('./build-hbs.js');
const hound = require('hound');

const fs = require('fs');
fs.watch('./src/lang/translations', (eventType) => {
	if (eventType === 'change') {
		tr.buildTranslations(() => hbs.buildHtml() )
	}
});

var dirs = ['./src', './data'];
dirs.forEach(function(dir) {
	var watcher = hound.watch(dir);
	watcher.on('create', function() {
		console.log('file created', file);
		hbs.buildHtml();
	});
	watcher.on('change', function(file) {
		console.log('change detected', file);
		hbs.buildHtml();
	});
});

tr.buildTranslations(() => hbs.buildHtml() )