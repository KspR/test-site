exports.watchTranslations = ->

	fs = require('fs')
	cp = require('child_process')

	deepen = (o) ->
		oo = {}
		for k, v of o
			t = oo
			parts = k.split('.')
			key = parts.pop()
			while parts.length
				part = parts.shift()
				t = t[part] = t[part] || {}
			t[key] = o[k]
		oo

	buildTranslations = ->
		fs.readFile('./src/lang/translations', (err, res) ->
			raw = res.toString()

			lines = raw.split('\n')

			lines = lines.map((line) ->
				res = {}

				indent = 0
				len = line.length
				i = 0
				while i < len
					if line.charAt(i) is '\t'
						indent++
					else
						if line.charAt(i) is '#'
							res.comment = true
						break
					i++

				res.text = line.replace(/\t/g, '')
				res.indent = indent
				res
			).filter((line) -> not(line.comment))

			keys = []

			keys = []
			langs = [{}, {}]
			mode = null
			buffer = ''

			for i in [0...lines.length]
				line = lines[i]

				console.log '------ new line ------'
				console.log line, inTranslation, mode
				console.log '---'

				if mode isnt 'multi'
					if line.text is '------'
						mode = 'multi'
						inTranslation = 0
						buffer = ''
					else
						indent = line.indent
						if lines[i+1]
							nextIndent = lines[i+1].indent
							if nextIndent is indent
								console.log 'same indent as next line'
								if not inTranslation
									console.log 'appended as new translation for current key ' + keys.join('.')
									langs[0][keys.join('.')] = line.text
									inTranslation = 1
								else
									console.log 'appended as translation for current key ' + keys.join('.')
									langs[inTranslation][keys.join('.')] = line.text
									inTranslation++
							else
								if typeof(inTranslation) is 'number'
									console.log 'appnded as last translation for current key ' + keys.join('.')
									langs[inTranslation][keys.join('.')] = line.text
									inTranslation = false
								if nextIndent > indent
									console.log 'pushing key', keys.join('.'), line.text
									keys.push(line.text)
								else
									for j in [0...indent-nextIndent]
										keys.pop()
										console.log 'poping key'
						else
							console.log 'appended as last translation'
							langs[inTranslation][keys.join('.')] = line.text
				else
					console.log 'mode is multi', inTranslation, buffer
					if line.text is '------'
						langs[inTranslation][keys.join('.')] = buffer
						mode = null
						inTranslation = false

						indent = line.indent
						if lines[i+1]
							nextIndent = lines[i+1].indent
							for j in [0...indent-nextIndent]
								keys.pop()
								console.log 'poping key'
					else if line.text is '---'
						langs[inTranslation][keys.join('.')] = buffer
						inTranslation++
						buffer = ''
					else
						buffer += line.text

			# console.log langs
			
			langs.map (json, i) ->
				if i is 0
					lang = 'en'
				else if i is 1
					lang = 'fr'

				fs.writeFile('./data/lang/' + lang + '.json', JSON.stringify(deepen(json), null, 2), (err) ->
					if err
						console.log 'error writing translation file', err
				)
		)

	fs.watch('./src/lang/translations', (eventType) ->
		if eventType is 'change'
			try
				buildTranslations()
			catch e
				console.log e
	)
	buildTranslations()