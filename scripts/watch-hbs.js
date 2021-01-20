exports.watchHbs = function() {
	var fs = require('fs');
	var HandleBars = require('handlebars');
	var hound = require('hound');
	var dataDir = './data';
	var partialsDir = './src/views/partials';
	var viewsDir = './src/views/';

	var data = {
		includes : {}
	}

	var buildHtml = function() {
		fs.readdirSync(dataDir, function(err, files) {
			files.forEach(function(e) {
				if (/\.json$/.exec(e)) {
					data[e.split(/\.json$/)[0]] = JSON.parse(fs.readFileSync(dataDir + '/' + e).toSring());
				}
			});
		});

		files = fs.readdirSync(dataDir + '/lang');
		files.forEach(function(e) {
			if (/\.json$/.exec(e)) {
				try {
					lang = e.split(/\.json$/)[0];
					data.lang = JSON.parse(fs.readFileSync(dataDir + '/lang/' + e).toString());

					let files = fs.readdirSync(partialsDir);
					files.forEach(function(e) {
						if (/\.html$/.exec(e)) {
							var template = fs.readFileSync(partialsDir + '/' + e).toString();
							var hbs = HandleBars.compile(template);
							data.includes[e.split(/\.html$/)[0]] = hbs(data);
						}
					});

					files = fs.readdirSync(viewsDir);
					files.forEach(function(e) {
						if (/\.html$/.exec(e)) {
							var template = fs.readFileSync(viewsDir + '/' + e).toString();
							var hbs = HandleBars.compile(template);
							fs.writeFile('./dist/' + e.split(/\.html$/)[0] + '.' + lang + '.html', hbs(data), function(err) {
								if (err) {
									console.log('err', err);
								}
							});
						}
					})
				}
				catch(e) {
					console.log(e);
				}
			}
		});
	}

	var dirs = ['./src', './data'];
	dirs.forEach(function(dir) {
		var watcher = hound.watch(dir);
		watcher.on('create', function() {
			console.log('file created', file);
			buildHtml();
		});
		watcher.on('change', function(file) {
			console.log('change detected', file);
			buildHtml();
		});
	});

	buildHtml();
}