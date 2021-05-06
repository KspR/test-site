sand.define('CreateDoc/TemplatePicker/Menu', [
	'Seed'
	'templates'
	'DOM/toDOM'
], (r) ->

	TEMPLATES_CONF = [
		{
			id : 'agile-artifacts'
			title : lang.discover['agile-artifacts']
			entries : [
				"user-story-mapping"
				"kanban-board"
				"scrum-board"
				"pi-planning-board"
				"program-board"
				"portfolio-kanban"
			]
		}
		{
			id : 'strategy-and-roadmapping'
			title : lang.discover['strategy-and-roadmapping']
			entries : [
				"twelve-month-roadmap"
				"impact-mapping"
				"okr-framework"
			]
		}
		{
			id : 'product-management'
			title : lang.discover['product-management']
			entries : [
				"example-mapping"
				"persona"
				"customer-journey-mapping"
				"hypothesis-table"
				"event-modeling"
				"empathy-map"
				"moscow-method"
			]
		}
		{
			id : 'agile-retrospectives'
			title : lang.discover['agile-retrospectives']
			entries : [
				"start-stop-continue-retrospective"
				"speedboat-retrospective"
				"starfish-retrospective"
				"fourls-retrospective"
				"three-little-pigs-retrospective"
				"timeline-retrospective"
				"esvp-retrospective"
				"learning-matrix"
				"planning-poker"
				"extreme-quotation"
				"niko-niko-calendar"
				"roam-board"
			]
		}
		{
			id : 'creativity-and-innovation'
			title : lang.discover['creativity-and-innovation']
			entries : [
				"lotus-blossom-technique"
			]
		}
		{
			title : lang.templates['strategic-analysis']
			entries : [
				'prioritization-matrix'
				'swot-matrix'
				'pestel-analysis-framework'
			]
		}
		{
			title : lang.discover['canvas']
			entries : [
				"business-model-canvas"
				"lean-startup-canvas"
				"value-proposition-canvas"
				"product-vision-board"
				"the-go-product-roadmap"
			]
		}
	]

	r.Seed.extend(
		tpl : ->
			@elts = []

			buildEntry = (entry) =>
				label = entry.label

				if label is "Rétrospective Start/Stop/Continue"
					label = 'Start/Stop/Continue'

				if label is "Start/Stop/Continue Retrospective"
					label = 'Start/Stop/Continue'

				if label is "Rétrospective de l'Etoile de Mer"
					label = 'Etoile de Mer'

				if label is 'Cartographie du parcours client'
					label = 'Cartographie parcours client'

				el = r.toDOM(
					tag : '.' + entry.id.replace('12', 'twelve').replace('4', 'four') + '.entry'
					children : [
						'.preview'
						'.label ' + label
					]
					events : mousedown : =>
						@pick entry.id
				)

				@elts.push
					el : el
					entry : entry
					id : entry.id

				el

			tag : '.template-picker-menu'
			children : [
				{
					tag : '.wrapper'
					style : 'touch-action:initial;'
					children : [
						{
							tag : '.container'
							children : [
								['.bloc-catgories', TEMPLATES_CONF.map((c) => '.category ' + c.title)]
								['.bloc-all', [
									['.bloc-entries', [
										'.bloc-title Basic' #todo translate
										['.entries', [
											buildEntry(
												id : 'blank'
												label : lang.templates.blank
											)
											buildEntry(
												id : 'empty-draft-plus-title'
												label : lang.templates['empty-draft-plus-title']
											)
											buildEntry(
												id : 'empty-draft-plus-title-plus-lists'
												label : lang.templates['empty-draft-plus-title-plus-lists']
											)
										]]
									]]
								].concat(
									TEMPLATES_CONF.map((elt) ->
										['.bloc-entries', [
											'.bloc-title ' + elt.title
											['.entries', elt.entries.map((id) ->
												if !r.templates[id]
													return 'div'
												buildEntry(
													id : id
													label : r.templates[id].label
												)
											)]
										]]
									)
								)]
							]
						}
					]
				}
			]

		pick : (id) ->
			now = Date.now()

			if @current and @current.id is id
				if @lastDowntime and (now - @lastDowntime < 350)
					@super.createDoc()
					return

			@lastDowntime = now

			if @current
				$(@current.el).removeClass 'selected'
			@current = @elts.one('id', id)
			$(@current.el).addClass 'selected'

		cancel : ->
			@fire('cancel')
			@super.up()
	)

)

sand.define('CreateDoc', [
	'DOM/toDOM'
	'Seed'
	'MoveTo'
	'Geo/R4'
	'CreateDoc/TemplatePicker/Menu'
	'DOM/onclickoutonce'
	'DOM/parents'
	'templates'
], (r) ->

	r.Seed.extend

		'+options' :
			targetFolder : null
			db : null

		tpl : ->
			if @targetFolder
				if !['manager', 'content-manager', 'contributor'].include(@targetFolder.permission)
					@targetFolder = null

			tag : '.create-doc'
			children : [
				# '.triangle-top'
				['.blocs', [
					['.bloc.bloc-name', [
						'.bloc-label ' + lang.popups['new-draft'].name
						['.bloc-content', [
							{
								tag : 'input.field'
								attr : value : lang.popups['new-draft'].untitled
							}
						]]
					]]
					{
						tag : '.bloc.bloc-location'
						children : [
							'.bloc-label ' + lang.popups['new-draft'].folder
							{
								tag : '.bloc-content'
								children : [
									# '.picto'
									'.name'
								]
							}
							'.bloc-change ' + lang.popups['new-draft']['change-location']
						]
						events : mousedown : =>
							@moveTo = @create(r.MoveTo, {
								folder : @targetFolder || js.config.user.root_id
								db : @db
								ctaLabel : 'choose'
							})

							@moveTo.on('destroy', =>
								@moveTo = null
							, @)

							@moveTo.on('move', (folder) =>
								@targetFolder = folder
								@query('memory2').set('current_folder_id', folder.id)

								@moveTo.destroy()

								@refreshLocation()
							, @)

							document.body.appendChild @moveTo.el
					}
					['.bloc.bloc-template', [
						'.bloc-label ' + lang.popups['new-draft'].template
						# @create(r.TemplatePicker, null, 'templatePicker').el
						@create(r.Menu, null, 'templatePicker').el
					]]
				]]
				{
					tag : '.cta ' + lang.general.create.toUpperCase()
					events : mousedown : =>
						# @query('createDoc', title : @field.value.trim(), folder_id : @targetFolder.id)

						@createDoc()
				}
				{
					tag : '.cancel ' + lang.general.cancel
					events : mousedown : @destroy.bind(@)
				}
			]

		createDoc : ->
			@query('createDoc', { title : @field.value.trim(), folder_id : @targetFolder?.id }, (draft) =>
				template = @templatePicker?.current.id

				@query('track', 'create_doc', { template : template || null, id : draft.dp.docs.last().id, guest : js.user.guest });

				return unless (template and (template isnt 'blank'))
				data = r.templates[template].data

				return unless data

				# data.vertices.forEach((v) -> v.cfl = false )

				@query('track', 'create-template', { id : template })

				console.log 'draft multipleSelect paste'
				draft.multipleSelect.paste(data, { setCflAsFalse : true, fromRestore : true })#, #null, null, true)

				#RY draft.coffee
				# xMin = null
				# yMin = null
				# draft.dp.vertices.all.each (v) ->
				# 	if v.tm.rect
				# 		if (typeof(xMin) isnt 'number') or (v.tm.rect[0][0] < xMin)
				# 			xMin = v.tm.rect[0][0]
				# 		if (typeof(yMin) isnt 'number') or (v.tm.rect[0][1] < yMin)
				# 			yMin = v.tm.rect[0][1]
				# xMin ||= 0
				# yMin ||= 0

				# center = [xMin, yMin].add(draft.viewport.rects.client.getValue()[1].divide(2)).minus([100, 100]);
				# draft.viewport.move center : center

				# if [
				# 	"user-story-mapping"
				# 	"impact-mapping"
				# 	'prioritization-matrix'
				# 	"speed-boat-retrospective"
				# 	"starfish-retrospective"
				# 	"timeline-retrospective"
				# 	"learning-matrix"
				# 	"fourls-retrospective"
				# ].include template
				# 	@query 'openPopup', {
				# 		elDesc : {
				# 			tag : '.popup7'
				# 			children : [
				# 				'.do-close.close x'
				# 				'.title Deactivating magnetization'
				# 				'.msg Have you tried deactivating lists [i] to enjoy more freedom?'
				# 				'.do-close.send-button OK'
				# 			]
				# 		}
				# 	}
			)

			@destroy()

		refreshLocation : ->
			if @targetFolder
				if @targetFolder.shared
					$(@location).addClass 'shared'
				else
					$(@location).removeClass 'shared'

			if @targetFolder
				@name.innerHTML = sanitize(@getStrPath(@targetFolder)) #@getFullPath(@targetFolder)
			else
				@name.innerHTML = '/'

		getStrPath : (folder) ->
			db = @db
			folders = []

			pushFolder = (folder) ->
				return if folder.special_type is 'root'

				folders.push folder
				if folder.folder_id
					pushFolder(db.items.find(folder.folder_id))

			pushFolder folder

			folders.push folder

			if folders.length > 2
				return '/.../' + folder.name
			else if folders.length is 2
				return '/' + folder.name
			else
				return '/'

		getFullPath : (folder) ->
			str = ''
			db = @db

			addPrefix = (folder) ->
				return if folder.special_type is 'root'

				str = folder.name + '/' + str
				if folder.folder_id
					addPrefix(db.items.find(folder.folder_id))

			addPrefix folder

			str = str.slice(0, str.length - 1)

			return '/' + str

		'+init' : ->
			@refreshLocation()

			newTab = $('.header .new-tab').get(0)
			# rect = newTab.getBoundingClientRect()

			# @el.style.left = rect.left + rect.width / 2 - 298 / 2 - 5 + 'px'
			document.body.appendChild @el

			# rect = @el.getBoundingClientRect()
			# rect = new r.R4([[rect.left, rect.top], [rect.width, rect.height]])
			# containerRect = new r.R4([[7, 0], [$(window).width() - 14, $(window).height()]])
			
			# newRect = rect.forcedIn(containerRect)
			# value = newRect.getValue()
			# @el.style.left = value[0][0] + value[1][0] / 2 - 298 / 2 - 5 + 'px'

			# delta = newRect.getCenter().minus(rect.getCenter())
			# $(@el).find('.triangle-top').css('margin-left', -delta[0] + 'px')

			$(@field).focus().select()

			setTimeout( =>
				$(@field).focus().select()
			, 0)

			@templatePicker.pick('blank')

			@subons = [
				r.onclickoutonce(@el, (e) =>
					if (e.target is newTab) or r.parents(newTab, e.target)
						e.stopPropagation()
					@destroy()
				, (e) =>
					if @moveTo
						return false if r.parents(@moveTo.el, e.target) or e.target is @moveTo.el
					if @templatePicker?.menu
						return false if r.parents(@templatePicker.menu.el, e.target) or e.target is @templatePicker.menu.el
					return true
				)
			]

			kd = (e) =>
				if e.keyCode is 27
					@destroy()

			document.addEventListener('keydown', kd, true)

			@subons.push
				un : ->
					document.removeEventListener('keydown', kd, true)


		'+destroy' : ->
			@subons?.send('un')
)

sand.define('templates', ->
	_templates = window.templates
	return templates
)

sand.require('CreateDoc', 'core/Array/*', (r) =>
	new r.CreateDoc
)