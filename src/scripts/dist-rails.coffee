fs = require('fs')
cp = require('child_process')
files = fs.readdirSync('./dist')
files.forEach((file) ->
	if /html$/.exec(file)
		str = fs.readFileSync('./dist/' + file).toString()
		str = str.replace(/src=("|')([^'"]*)("|')/g, (str, _, capture) ->
			if !/^http/.exec capture
				path = 'site/' + capture.replace('./', '').replace('imgs/', '')
				'src="<%= image_path("' + path + '") %>"'
			else
				return str
		)
		str = str.replace(/<!-- BEGINCSS -->(.|\n)*<!-- ENDCSS -->/, '<%= stylesheet_link_tag "portal" %>')
		str = str.replace(/<!-- PRODONLY/g, '').replace(/END -->/g, '')
		str = str.replace(/<!-- TESTONLY(.|\n)*?ENDTESTONLY -->/g, '')
		fs.writeFileSync('./dist-rails/' + file + '.erb', str)
)

files = fs.readdirSync('./src/sass')
files.forEach((file) ->
	if /sass$/.exec(file)
		str = fs.readFileSync('./src/sass/' + file).toString()
		str = str.replace(/[^-]url\("(.*)"\)/g, (str, capture) ->
			if /fonts/.exec capture
				path = capture.replace('../', '').replace('fonts/', '')
				return ' url(font-path("' + path + '"))'
			else
				if /^http/.exec capture
					return str
				else
					path = capture.replace('[^\.]\./', '').replace('\.\./', '').replace('imgs/', '')
					return ' image-url("site/' + path + '")'
		)
		fs.writeFileSync('./dist-rails/sass/' + file, str)
)

fs.readdirSync('./dist-rails').forEach((file) ->
	if /html/.exec(file)
		cp.exec('cp ./dist-rails/' + file + ' /Users/KspR/Dev/whibo/app/views/site/' + file)
)

fs.readdirSync('./dist-rails/sass').forEach((file) ->
	if /sass/.exec(file)
		cp.exec('cp ./dist-rails/sass/' + file + ' /Users/KspR/Dev/whibo/app/assets/stylesheets/portal/' + file)
)