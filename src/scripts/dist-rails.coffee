fs = require('fs')
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
				if !/^http/.exec capture
					return str
				else
					path = capture.replace('./', '').replace('../', '')
					return ' image-url("' + path + '")'
		)
		fs.writeFileSync('./dist-rails/sass/' + file, str)
)