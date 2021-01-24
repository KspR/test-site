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
		workflows : {
			'agile-project-management' : {
				features : ['story-card', 'jira-integration', 'vote', 'polling-booth-mode'],
				ucs : ['story-mapping', 'scrum-board', 'program-board', 'retrospective']
			},
			'product-management' : {
				features : ['lists', 'unified-living-environment', 'right-level-of-focus', 'folder-sharing'],
				ucs : ['product-discovery', 'prioritizing', 'user-flow', 'product-roadmap']
			},
			'everyday-knowledge-work' : {
				ucs : ['todo-lists', 'organizing-your-ideas', 'creative-work', 'collecting-feedback'],
				features : ['lists', 'simple-navigation', 'visual-clusters', 'folder-sharing']
			}
		},
		pricing : {
			free : {
				features : [
	        'up-to-500-objects',
	        'unlimited-drafts',
	        'unlimited-url-sharing',
	        'unlimited-guests',
	        'one-shared-folder'
	      ]
			},
			pro : {
				features : [
	        'unlimited-objects',
	        'unlimited-shared-folders',
	        'password-protection',
	        'manual-local-backup',
	        'email-support'
	      ]
			},
			team : {
				features : [
	        'team-shared-folder',
	        'fine-grained-access-management',
	        'sso',
	        'jira',
	        'phone-support'
	      ],
				price : [
	        ['1 - 50', '8.33', '10'],
	        ['51 - 200', '6.67', '8'],
	        ['200+', '5', '6']
	      ]
			},
			faq : {
				'left-qs' : ['q1', 'q2', 'q3', 'q4'],
				'right-qs' : ['q6', 'q7', 'q8', 'q9']
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
					if (e === '_workflow.html') { // special file
						for (var key in data.workflows) {
							data.workflow_id = key;
							data.features = data.workflows[key].features;
							data.ucs = data.workflows[key].ucs;
							fs.writeFileSync('./dist/' + key.replace(/-/g, '_') + '.' + lang + '.html', hbs(data));
						}
					}
					else {
						fs.writeFileSync('./dist/' + e.split(/\.html$/)[0] + '.' + lang + '.html', hbs(data));
					}
				}
			});
		}
	});
}