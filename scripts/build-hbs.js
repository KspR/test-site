exports.buildHtml = function(cb) {
	var fs = require('fs');
	var HandleBars = require('handlebars');
	var dataDir = './data';
	var partialsDir = './src/views/partials';
	var viewsDir = './src/views/';

	var data = {
		includes : {},
		home : {
			workflows : ['scrum-master', 'product-manager', 'knowledge-worker'],
			features : ['scalable-document', 'right-level-of-focus', 'collaboration', 'jira-integration', 'large-collection-template', 'unlimited-sharing']
		},
		pricing : {
			free : {
				features : [
	        'up-to-500-objects',
	        'unlimited-drafts',
	        'unlimited-url-sharing',
	        'unlimited-guests',
	        'one-shared-folder',
			'jira-integration'
	      ]
			},
			pro : {
				features : [
	        'unlimited-objects',
	        'manual-local-backup',
	        'email-support'
	      ]
			},
			team : {
				features : [
	        'client-success-management',
	        'admin-interface',
	        'group-management',
	        'password-protection',
	        'phone-support'
	      ],
				price : [
	        ['1 - 50', '100', '10'],
	        ['51 - 200', '80', '8'],
	        ['200+', '60', '6']
	      ]
			},
			faq : {
				'left-qs' : ['q1', 'q2', 'q3', 'q4'],
				'right-qs' : ['q6', 'q7', 'q8', 'q9'],
				'all-qs' : ['q1', 'q2', 'q3', 'q4', 'q5', 'q6', 'q7', 'q8', 'q9', 'q10']
			}
		}
	}

	HandleBars.registerHelper('ifEquals', function(a, b, options) {
		return a === b ? options.fn(this) : options.inverse(this);
	});

	fs.readdirSync(dataDir, function(err, files) {
		files.forEach(function(e) {
			if (/\.json$/.exec(e)) {
				data[e.split(/\.json$/)[0]] = JSON.parse(fs.readFileSync(dataDir + '/' + e).toSring());
			}
		});
	});

	['en', 'fr'].forEach((lang) => {
		data.lang = {}
		data.lang[lang] = true; // used for "if lang.fr is true"

		let files = fs.readdirSync(dataDir + '/lang');
		files.forEach(function(e) {
			if (!/copy/.exec(e)) {
				if ((new RegExp("\\." + lang + ".json")).exec(e)) {
					let d = JSON.parse(fs.readFileSync(dataDir + '/lang/' + e).toString());
					for (var key in d) {
						if (data.lang[key]) {
							for (let _k in d[key]) {
								data.lang[key][_k] = d[key][_k];
							}
						}
						else {
							data.lang[key] = d[key];
						}
					}
				}
			}
		});

		subPartials = ['get_started.html']
		subPartials.forEach(function(e) {
			if (!/copy/.exec(e)) {
				if (/\.html$/.exec(e)) {
					var template = fs.readFileSync(partialsDir + '/' + e).toString();
					var hbs = HandleBars.compile(template);
					data.includes[e.split(/\.html$/)[0]] = hbs(data);
				}
			}
		});

		files = fs.readdirSync(partialsDir);
		files.forEach(function(e) {
			if (!/copy/.exec(e)) {
				if (/\.html$/.exec(e)) {
					if (subPartials.includes(e)) {
						return;
					}
					var template = fs.readFileSync(partialsDir + '/' + e).toString();
					var hbs = HandleBars.compile(template);
					data.includes[e.split(/\.html$/)[0]] = hbs(data);
				}
			}
		});

		files = fs.readdirSync(viewsDir);
		files.forEach(function(e) {
			if (!/copy/.exec(e)) {
				if (/\.html$/.exec(e)) {
					var template = fs.readFileSync(viewsDir + '/' + e).toString();
					var hbs = HandleBars.compile(template);
					if (e === '_workflow.html') { // special file
						for (var key in data.lang.workflows) {
							data.workflow_id = key;
							fs.writeFileSync('./dist/wf_' + key.replace(/-/g, '_') + '.' + lang + '.html', hbs(data));
						}
					}
					else {
						fs.writeFileSync('./dist/' + e.split(/\.html$/)[0] + '.' + lang + '.html', hbs(data));
					}
				}
			}
		});
	})
}