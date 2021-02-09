const tr = require('./build-translations.js');//.watchTranslations();
const hbs = require('./build-hbs.js');
const hound = require('hound');

const fs = require('fs');
const langWatcher = hound.watch('./src/lang');
const buildTrs = () => {
	try {
		tr.buildTranslations(() => hbs.buildHtml() )
	}
	catch(e) {
		console.log(e);
	}
};
langWatcher.on('change', buildTrs);
langWatcher.on('create', buildTrs);

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