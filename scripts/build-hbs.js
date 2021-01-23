exports.buildHtml = function(cb) {
	var fs = require('fs');
	var HandleBars = require('handlebars');
	var dataDir = './data';
	var partialsDir = './src/views/partials';
	var viewsDir = './src/views/';

	var data = {
		includes : {}
	}

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
			lang = e.split(/\.json$/)[0];
			data.lang = JSON.parse(fs.readFileSync(dataDir + '/lang/' + e).toString());

			subPartials = ['get_started.html']
			subPartials.forEach(function(e) {
				if (/\.html$/.exec(e)) {
					var template = fs.readFileSync(partialsDir + '/' + e).toString();
					var hbs = HandleBars.compile(template);
					data.includes[e.split(/\.html$/)[0]] = hbs(data);
				}
			});

			let files = fs.readdirSync(partialsDir);
			files.forEach(function(e) {
				if (/\.html$/.exec(e)) {
					if (subPartials.includes(e)) {
						return;
					}
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
					fs.writeFileSync('./dist/' + e.split(/\.html$/)[0] + '.' + lang + '.html', hbs(data));
				}
			})
		}
	});
}