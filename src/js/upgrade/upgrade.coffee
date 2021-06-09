taxList = {
	'BE' : 21,
	'BG' : 20,
	'CZ' : 21,
	'DK' : 25,
	'DE' : 19,
	'EE' : 20,
	'IE' : 23,
	'GR' : 24,
	'ES' : 21,
	'FR' : 20,
	'HR' : 25,
	'IT' : 22,
	'CY' : 19,
	'LV' : 21,
	'LT' : 21,
	'LU' : 17,
	'HU' : 27,
	'MT' : 18,
	'NL' : 21,
	'AT' : 20,
	'PL' : 23,
	'PT' : 23,
	'RO' : 19,
	'SI' : 22,
	'SK' : 20,
	'FI' : 24,
	'SE' : 25,
	'GB' : 20
}

sand.define('PaymentStepper', [
	'Seed'
	'DOM/toDOM'
	'PaymentMethodBloc'
	'KspR/SelectboxPlain'
], (r) ->
	
	_lang = lang.limitations['upgrade-popup']
	shouldSendMethod = null
	card = null

	PLANS = {
		'pro-monthly' :
			price : 10
		'pro-yearly' :
			price : 100
	}

	r.Seed.extend(
		tpl : ->
			@trace = []
			@stripe = Stripe(@_a.config.stripe.public_key)

			tag : '.popup10.popup-upgrade.popup-upgrade-big'
			children : [
				['.top-row', [
					{
						tag : '.close.do-close x'
						events : mousedown : =>
							@query('track', 'close-upgrade-popup', { from : 'x', trace : @trace })
					}
					'.title'
				]]
				'.content'
				'.bottom-row'
			]

		steps : [
			{
				id : 'select-plan'
				title : _lang['select-plan'].title
				buildContent : ->
					plans = [
						{
							id : 'pro'
							label : 'Pro'
							price :
								amount : '10€'
							yearly :
								price :
									amount : '8.34€'
							cta :
								label : lang.limitations['over-quota'].upgrade.capitalize()
								mousedown : =>
									@selectedPlan = 'pro-' + (if @yearly then 'yearly' else 'monthly')
									@to 'edit-payment-info'
						}
						{
							id : 'team'
							label : 'Team'
							price :
								amount : (if js.user.lang is 'fr' then 'De 3 à 10€*' else 'From 10€*')
							yearly :
								price :
									amount : (if js.user.lang is 'fr' then 'De ' else '') + '2.50€ ' + lang.general.to + ' 8.34€*'
							cta :
								elDesc :
									tag : 'a.cta ' + lang.general['contact-us'].capitalize()
									attr :
										href : 'mailto:hi@draft.io?subject=' + encodeURIComponent(_lang['select-plan']['contact-us-subject'])
									style : "text-decoration:none"
						}
					]

					content = @content.appendChild r.toDOM ['.plans' + (if @yearly then '.yearly' else ''), [
							['.period-alt', [
								'.period-monthly ' + _lang['select-plan']['pay-monthly']
								{
									tag : '.container'
									children : [
										'.inner'
									]
									events : mousedown : =>
										if @yearly
											$(content).removeClass('yearly')
										else
											$(content).addClass('yearly')
										@yearly = !@yearly
								}
								'.period-yearly ' + _lang['select-plan']['pay-annually']
								'.save ' + _lang['select-plan']['pay-annually-save']
							]]
						].concat(
							plans.map((p) =>
								p.teaser = _lang['select-plan'][p.id].teaser
								p.features = _lang['select-plan'][p.id].features.split(',')
								p.price.adds = _lang['select-plan'][p.id]['price-adds'].split(',')

								desc = ['.plan.' + p.id, [
									'.title ' + p.label
									'.teaser ' + p.teaser
									['.price-bloc', [
										'.price ' + p.price.amount
										['.adds', p.price.adds.map((a) -> tag : '.add ' + a )]
									]]
									['.price-bloc.yearly', [
										'.price ' + p.yearly.price.amount
										['.adds', p.price.adds.map((a) -> tag : '.add ' + a )]
									]]
									if p.cta.elDesc
										p.cta.elDesc
									else
										{
											tag : '.cta ' + p.cta.label
											events : mousedown : p.cta.mousedown.bind(@)
										}
									['ul.features', p.features.map((f) =>
										'li.feature ' + f
									)]
								]]

								if p.id is 'team'
									desc[1].push ['.ast *' + _lang['select-plan'][p.id].ast]
								desc
							)
						)]

					$(@['bottom-row']).find('.cta').remove()
			}
			{
				id : 'edit-payment-info'
				cta :
					label : _lang['edit-payment-info'].cta
					mousedown : ->
						true
				title : _lang['edit-payment-info'].title
				buildContent : ->
					@content.appendChild r.toDOM '#errors'
					@content.appendChild r.toDOM(""".billing-information.bloc0 
						<div class="bloc0-title">
							<div class="number">1</div>
							<div class="label">#{_lang['edit-payment-info']['billing-information']}</div>
						</div>
						<div class="bloc identifier-bloc">
							<div class="bloc1">
								<div class="radio-container"></div>
							</div>
							<div class="bloc1 bloc1-full-name">
								<label for="full-name">#{_lang['edit-payment-info']['full-name']}</label>
								<input id="full-name" />
							</div>
							<div class="bloc1 split-bloc bloc1-company">
								<label for="company-name">#{_lang['edit-payment-info']['company-name']}</label>
								<label for="vat-number">#{_lang['edit-payment-info']['vat-number']}</label>
								<input id="company-name" />
								<input id="vat-number" />
							</div>
						</div>
						<div class="bloc address-bloc">
							<label for="line1">#{_lang['edit-payment-info'].address}</label>
							<input id="line1" />

							<div class="triple-bloc">
								<label for="postal-code">#{_lang['edit-payment-info']['zip-code']}</label>
								<label for="city">#{_lang['edit-payment-info'].city}</label>
								<label for="country">#{_lang['edit-payment-info'].country}</label>

								<input id="postal-code" />
								<input id="city" />
								<div class="select-wrapper">
										<select id="country">
											<option value="AF">Afghanistan</option>
											<option value="AX">Åland Islands</option>
											<option value="AL">Albania</option>
											<option value="DZ">Algeria</option>
											<option value="AS">American Samoa</option>
											<option value="AD">Andorra</option>
											<option value="AO">Angola</option>
											<option value="AI">Anguilla</option>
											<option value="AQ">Antarctica</option>
											<option value="AG">Antigua and Barbuda</option>
											<option value="AR">Argentina</option>
											<option value="AM">Armenia</option>
											<option value="AW">Aruba</option>
											<option value="AU">Australia</option>
											<option value="AT">Austria</option>
											<option value="AZ">Azerbaijan</option>
											<option value="BS">Bahamas</option>
											<option value="BH">Bahrain</option>
											<option value="BD">Bangladesh</option>
											<option value="BB">Barbados</option>
											<option value="BY">Belarus</option>
											<option value="BE">Belgium</option>
											<option value="BZ">Belize</option>
											<option value="BJ">Benin</option>
											<option value="BM">Bermuda</option>
											<option value="BT">Bhutan</option>
											<option value="BO">Bolivia, Plurinational State of</option>
											<option value="BQ">Bonaire, Sint Eustatius and Saba</option>
											<option value="BA">Bosnia and Herzegovina</option>
											<option value="BW">Botswana</option>
											<option value="BV">Bouvet Island</option>
											<option value="BR">Brazil</option>
											<option value="IO">British Indian Ocean Territory</option>
											<option value="BN">Brunei Darussalam</option>
											<option value="BG">Bulgaria</option>
											<option value="BF">Burkina Faso</option>
											<option value="BI">Burundi</option>
											<option value="KH">Cambodia</option>
											<option value="CM">Cameroon</option>
											<option value="CA">Canada</option>
											<option value="CV">Cape Verde</option>
											<option value="KY">Cayman Islands</option>
											<option value="CF">Central African Republic</option>
											<option value="TD">Chad</option>
											<option value="CL">Chile</option>
											<option value="CN">China</option>
											<option value="CX">Christmas Island</option>
											<option value="CC">Cocos (Keeling) Islands</option>
											<option value="CO">Colombia</option>
											<option value="KM">Comoros</option>
											<option value="CG">Congo</option>
											<option value="CD">Congo, the Democratic Republic of the</option>
											<option value="CK">Cook Islands</option>
											<option value="CR">Costa Rica</option>
											<option value="CI">Côte d'Ivoire</option>
											<option value="HR">Croatia</option>
											<option value="CU">Cuba</option>
											<option value="CW">Curaçao</option>
											<option value="CY">Cyprus</option>
											<option value="CZ">Czech Republic</option>
											<option value="DK">Denmark</option>
											<option value="DJ">Djibouti</option>
											<option value="DM">Dominica</option>
											<option value="DO">Dominican Republic</option>
											<option value="EC">Ecuador</option>
											<option value="EG">Egypt</option>
											<option value="SV">El Salvador</option>
											<option value="GQ">Equatorial Guinea</option>
											<option value="ER">Eritrea</option>
											<option value="EE">Estonia</option>
											<option value="ET">Ethiopia</option>
											<option value="FK">Falkland Islands (Malvinas)</option>
											<option value="FO">Faroe Islands</option>
											<option value="FJ">Fiji</option>
											<option value="FI">Finland</option>
											<option value="FR">France</option>
											<option value="GF">French Guiana</option>
											<option value="PF">French Polynesia</option>
											<option value="TF">French Southern Territories</option>
											<option value="GA">Gabon</option>
											<option value="GM">Gambia</option>
											<option value="GE">Georgia</option>
											<option value="DE">Germany</option>
											<option value="GH">Ghana</option>
											<option value="GI">Gibraltar</option>
											<option value="GR">Greece</option>
											<option value="GL">Greenland</option>
											<option value="GD">Grenada</option>
											<option value="GP">Guadeloupe</option>
											<option value="GU">Guam</option>
											<option value="GT">Guatemala</option>
											<option value="GG">Guernsey</option>
											<option value="GN">Guinea</option>
											<option value="GW">Guinea-Bissau</option>
											<option value="GY">Guyana</option>
											<option value="HT">Haiti</option>
											<option value="HM">Heard Island and McDonald Islands</option>
											<option value="VA">Holy See (Vatican City State)</option>
											<option value="HN">Honduras</option>
											<option value="HK">Hong Kong</option>
											<option value="HU">Hungary</option>
											<option value="IS">Iceland</option>
											<option value="IN">India</option>
											<option value="ID">Indonesia</option>
											<option value="IR">Iran, Islamic Republic of</option>
											<option value="IQ">Iraq</option>
											<option value="IE">Ireland</option>
											<option value="IM">Isle of Man</option>
											<option value="IL">Israel</option>
											<option value="IT">Italy</option>
											<option value="JM">Jamaica</option>
											<option value="JP">Japan</option>
											<option value="JE">Jersey</option>
											<option value="JO">Jordan</option>
											<option value="KZ">Kazakhstan</option>
											<option value="KE">Kenya</option>
											<option value="KI">Kiribati</option>
											<option value="KP">Korea, Democratic People's Republic of</option>
											<option value="KR">Korea, Republic of</option>
											<option value="KW">Kuwait</option>
											<option value="KG">Kyrgyzstan</option>
											<option value="LA">Lao People's Democratic Republic</option>
											<option value="LV">Latvia</option>
											<option value="LB">Lebanon</option>
											<option value="LS">Lesotho</option>
											<option value="LR">Liberia</option>
											<option value="LY">Libya</option>
											<option value="LI">Liechtenstein</option>
											<option value="LT">Lithuania</option>
											<option value="LU">Luxembourg</option>
											<option value="MO">Macao</option>
											<option value="MK">Macedonia, the former Yugoslav Republic of</option>
											<option value="MG">Madagascar</option>
											<option value="MW">Malawi</option>
											<option value="MY">Malaysia</option>
											<option value="MV">Maldives</option>
											<option value="ML">Mali</option>
											<option value="MT">Malta</option>
											<option value="MH">Marshall Islands</option>
											<option value="MQ">Martinique</option>
											<option value="MR">Mauritania</option>
											<option value="MU">Mauritius</option>
											<option value="YT">Mayotte</option>
											<option value="MX">Mexico</option>
											<option value="FM">Micronesia, Federated States of</option>
											<option value="MD">Moldova, Republic of</option>
											<option value="MC">Monaco</option>
											<option value="MN">Mongolia</option>
											<option value="ME">Montenegro</option>
											<option value="MS">Montserrat</option>
											<option value="MA">Morocco</option>
											<option value="MZ">Mozambique</option>
											<option value="MM">Myanmar</option>
											<option value="NA">Namibia</option>
											<option value="NR">Nauru</option>
											<option value="NP">Nepal</option>
											<option value="NL">Netherlands</option>
											<option value="NC">New Caledonia</option>
											<option value="NZ">New Zealand</option>
											<option value="NI">Nicaragua</option>
											<option value="NE">Niger</option>
											<option value="NG">Nigeria</option>
											<option value="NU">Niue</option>
											<option value="NF">Norfolk Island</option>
											<option value="MP">Northern Mariana Islands</option>
											<option value="NO">Norway</option>
											<option value="OM">Oman</option>
											<option value="PK">Pakistan</option>
											<option value="PW">Palau</option>
											<option value="PS">Palestinian Territory, Occupied</option>
											<option value="PA">Panama</option>
											<option value="PG">Papua New Guinea</option>
											<option value="PY">Paraguay</option>
											<option value="PE">Peru</option>
											<option value="PH">Philippines</option>
											<option value="PN">Pitcairn</option>
											<option value="PL">Poland</option>
											<option value="PT">Portugal</option>
											<option value="PR">Puerto Rico</option>
											<option value="QA">Qatar</option>
											<option value="RE">Réunion</option>
											<option value="RO">Romania</option>
											<option value="RU">Russian Federation</option>
											<option value="RW">Rwanda</option>
											<option value="BL">Saint Barthélemy</option>
											<option value="SH">Saint Helena, Ascension and Tristan da Cunha</option>
											<option value="KN">Saint Kitts and Nevis</option>
											<option value="LC">Saint Lucia</option>
											<option value="MF">Saint Martin (French part)</option>
											<option value="PM">Saint Pierre and Miquelon</option>
											<option value="VC">Saint Vincent and the Grenadines</option>
											<option value="WS">Samoa</option>
											<option value="SM">San Marino</option>
											<option value="ST">Sao Tome and Principe</option>
											<option value="SA">Saudi Arabia</option>
											<option value="SN">Senegal</option>
											<option value="RS">Serbia</option>
											<option value="SC">Seychelles</option>
											<option value="SL">Sierra Leone</option>
											<option value="SG">Singapore</option>
											<option value="SX">Sint Maarten (Dutch part)</option>
											<option value="SK">Slovakia</option>
											<option value="SI">Slovenia</option>
											<option value="SB">Solomon Islands</option>
											<option value="SO">Somalia</option>
											<option value="ZA">South Africa</option>
											<option value="GS">South Georgia and the South Sandwich Islands</option>
											<option value="SS">South Sudan</option>
											<option value="ES">Spain</option>
											<option value="LK">Sri Lanka</option>
											<option value="SD">Sudan</option>
											<option value="SR">Suriname</option>
											<option value="SJ">Svalbard and Jan Mayen</option>
											<option value="SZ">Swaziland</option>
											<option value="SE">Sweden</option>
											<option value="CH">Switzerland</option>
											<option value="SY">Syrian Arab Republic</option>
											<option value="TW">Taiwan, Province of China</option>
											<option value="TJ">Tajikistan</option>
											<option value="TZ">Tanzania, United Republic of</option>
											<option value="TH">Thailand</option>
											<option value="TL">Timor-Leste</option>
											<option value="TG">Togo</option>
											<option value="TK">Tokelau</option>
											<option value="TO">Tonga</option>
											<option value="TT">Trinidad and Tobago</option>
											<option value="TN">Tunisia</option>
											<option value="TR">Turkey</option>
											<option value="TM">Turkmenistan</option>
											<option value="TC">Turks and Caicos Islands</option>
											<option value="TV">Tuvalu</option>
											<option value="UG">Uganda</option>
											<option value="UA">Ukraine</option>
											<option value="AE">United Arab Emirates</option>
											<option value="GB">United Kingdom</option>
											<option value="US">United States</option>
											<option value="UM">United States Minor Outlying Islands</option>
											<option value="UY">Uruguay</option>
											<option value="UZ">Uzbekistan</option>
											<option value="VU">Vanuatu</option>
											<option value="VE">Venezuela, Bolivarian Republic of</option>
											<option value="VN">Viet Nam</option>
											<option value="VG">Virgin Islands, British</option>
											<option value="VI">Virgin Islands, U.S.</option>
											<option value="WF">Wallis and Futuna</option>
											<option value="EH">Western Sahara</option>
											<option value="YE">Yemen</option>
											<option value="ZM">Zambia</option>
											<option value="ZW">Zimbabwe</option>
										</select>
									<div class="triangle">▼</div>
								</div>
							</div>

						</div>
					""")

					radio = @create(r.SelectboxPlain, {
						options : [
							{
								id : 'business'
								elDesc : ['.option', [
									['.checkbox', ['.inner']]
									'.label ' + _lang['edit-payment-info'].business
								]]
							}
							{
								id : 'individual'
								elDesc : ['.option', [
									['.checkbox', ['.inner']]
									'.label ' + _lang['edit-payment-info'].individual
								]]
							}
						]
					})

					refreshForm = =>
						if radio.current.option.id is 'business'
							$(@content).find('.bloc1-full-name').hide()
							$(@content).find('.bloc1-company').show()
						else
							$(@content).find('.bloc1-full-name').show()
							$(@content).find('.bloc1-company').hide()

					radio.on('pick', refreshForm)
					radio.pick(@_a.user.billing_infos?.customer_type || 'business')

					@radio = radio

					$(@content).find('.radio-container').append radio.el

					@content.appendChild r.toDOM(['.bloc0', [
						['.bloc0-title', [
							'.number 2'
							'.label ' + _lang['edit-payment-info']['payment-method'].title
						]]
						'.card-bloc'
					]])

					appendCardForm = =>
						$(@el).find('.card-bloc').append r.toDOM("""div 
							<!-- Used to display Element errors. -->
							<div id="card-errors" role="alert"></div>

							<div class="input-bloc">
								<label for="card-element">
									#{_lang['edit-payment-info']['payment-method']['credit-or-debit-card']}
								</label>
								<div id="card-element">
									<!-- A Stripe Element will be inserted here. -->
								</div>
							</div>

							<div class="input-bloc">
								<label for="name-on-card">#{_lang['edit-payment-info']['payment-method']['cardholders-name']}</label>
								<input id="name-on-card" />
							</div>
						""")

						elements = @stripe.elements()

						card = elements.create('card', {
							style :
								base :
									fontSize: '15px',
									fontFamily : 'futura',
									fontSmoothing : 'antialiased',
									color : '#222'
						})
						card.mount($(@el).find('#card-element').get(0))

						shouldSendMethod = true

					shouldSendMethod = false

					if @_a.user.payment_method
						paymentMethodBloc = @create(r.PaymentMethodBloc,
							onchange : =>
								$(paymentMethodBloc.el).remove()
								appendCardForm()
								$(@el).find('.card-bloc').append r.toDOM
									tag : '.cancel ' + _lang['edit-payment-info']['payment-method'].cancel
									events : mousedown : =>
										$(@el).find('.card-bloc').html('')
										$(@el).find('.card-bloc').append paymentMethodBloc.el
										shouldSendMethod = false
						)
						$(@el).find('.card-bloc').append paymentMethodBloc.el
					else
						shouldSendMethod = true
						appendCardForm()

					if @_a.user.billing_infos
						infos = @_a.user.billing_infos
						address = infos.address
						map =
							'line1' : address.line1
							'postal-code' : address.postal_code
							city : address.city

						if @_a.user.billing_infos.customer_type is 'business'
							map['company-name'] = infos.name
							map['vat-number'] = infos.eu_vat
						else
							map['full-name'] = infos.name

						for key, value of map
							if value
								$(@el).find('#' + key).val(value)


						#country
					# 	for key, value of map
					# 		if @_a.user.billing_address[key] and map[key]
					# 			$(@el).find('#' + map[key]).val(@_a.user.billing_address[key])

					countryCodes = ['AF', 'AX', 'AL', 'DZ', 'AS', 'AD', 'AO', 'AI', 'AQ', 'AG', 'AR', 'AM', 'AW', 'AU', 'AT', 'AZ', 'BS', 'BH', 'BD', 'BB', 'BY', 'BE', 'BZ', 'BJ', 'BM', 'BT', 'BO', 'BQ', 'BA', 'BW', 'BV', 'BR', 'IO', 'BN', 'BG', 'BF', 'BI', 'KH', 'CM', 'CA', 'CV', 'KY', 'CF', 'TD', 'CL', 'CN', 'CX', 'CC', 'CO', 'KM', 'CG', 'CD', 'CK', 'CR', 'CI', 'HR', 'CU', 'CW', 'CY', 'CZ', 'DK', 'DJ', 'DM', 'DO', 'EC', 'EG', 'SV', 'GQ', 'ER', 'EE', 'ET', 'FK', 'FO', 'FJ', 'FI', 'FR', 'GF', 'PF', 'TF', 'GA', 'GM', 'GE', 'DE', 'GH', 'GI', 'GR', 'GL', 'GD', 'GP', 'GU', 'GT', 'GG', 'GN', 'GW', 'GY', 'HT', 'HM', 'VA', 'HN', 'HK', 'HU', 'IS', 'IN', 'ID', 'IR', 'IQ', 'IE', 'IM', 'IL', 'IT', 'JM', 'JP', 'JE', 'JO', 'KZ', 'KE', 'KI', 'KP', 'KR', 'KW', 'KG', 'LA', 'LV', 'LB', 'LS', 'LR', 'LY', 'LI', 'LT', 'LU', 'MO', 'MK', 'MG', 'MW', 'MY', 'MV', 'ML', 'MT', 'MH', 'MQ', 'MR', 'MU', 'YT', 'MX', 'FM', 'MD', 'MC', 'MN', 'ME', 'MS', 'MA', 'MZ', 'MM', 'NA', 'NR', 'NP', 'NL', 'NC', 'NZ', 'NI', 'NE', 'NG', 'NU', 'NF', 'MP', 'NO', 'OM', 'PK', 'PW', 'PS', 'PA', 'PG', 'PY', 'PE', 'PH', 'PN', 'PL', 'PT', 'PR', 'QA', 'RE', 'RO', 'RU', 'RW', 'BL', 'SH', 'KN', 'LC', 'MF', 'PM', 'VC', 'WS', 'SM', 'ST', 'SA', 'SN', 'RS', 'SC', 'SL', 'SG', 'SX', 'SK', 'SI', 'SB', 'SO', 'ZA', 'GS', 'SS', 'ES', 'LK', 'SD', 'SR', 'SJ', 'SZ', 'SE', 'CH', 'SY', 'TW', 'TJ', 'TZ', 'TH', 'TL', 'TG', 'TK', 'TO', 'TT', 'TN', 'TR', 'TM', 'TC', 'TV', 'UG', 'UA', 'AE', 'GB', 'US', 'UM', 'UY', 'UZ', 'VU', 'VE', 'VN', 'VG', 'VI', 'WF', 'EH', 'YE', 'ZM', 'ZW']
					countryCode = 'FR' # fallback
					possibilities = window.navigator.language.split('-')

					if @_a.user.billing_infos?.address?.country
						possibilities.push @_a.user.billing_infos?.address?.country

					for i in [possibilities.length-1..0]
						possibility = possibilities[i].toUpperCase()
						if countryCodes.include(possibility)
							countryCode = possibility
							break

					$(@el).find('select').get(0).selectedIndex = $(@el).find('select').find('[value=' + countryCode + ']').index()

					refreshVATField = =>
						country = $(@el).find('#country').val().trim()
						if !taxList[country]
							$(@el).find('#vat-number').val('')
							$(@el).find('label[for=vat-number]').hide()
							$(@el).find('#vat-number').hide()
						else
							$(@el).find('#vat-number').show()
							$(@el).find('label[for=vat-number]').show()

					$(@el).find('select').get(0).onchange = refreshVATField

					refreshVATField()

					cta = $(@el).find('.cta').get(0)
					cta.addEventListener('pointerdown', =>
						billing_infos = {}

						if @radio.current.option.id is 'business'
							billing_infos.name = $(@el).find('#company-name').val().trim()
							if $(@el).find('#vat-number').val().trim()
								billing_infos.eu_vat = $(@el).find('#vat-number').val().trim()
						else
							billing_infos.name = $(@el).find('#full-name').val().trim()

						billing_infos.customer_type = @radio.current.option.id
						billing_infos.address =
							line1 : $(@el).find('#line1').val().trim()
							# line2 : $(@el).find('#line-2').val()
							postal_code : $(@el).find('#postal-code').val().trim()
							city : $(@el).find('#city').val()
							# state : $(@el).find('#state').val()
							country : $(@el).find('#country').val().trim()

						if billing_infos.customer_type is 'business'
							valid = (vat) ->
								reg = /^((AT)?U[0-9]{8}|(BE)?0[0-9]{9}|(BG)?[0-9]{9,10}|(CY)?[0-9]{8}L|(CZ)?[0-9]{8,10}|(DE)?[0-9]{9}|(DK)?[0-9]{8}|(EE)?[0-9]{9}|(EL|GR)?[0-9]{9}|(ES)?[0-9A-Z][0-9]{7}[0-9A-Z]|(FI)?[0-9]{8}|(FR)?[0-9A-Z]{2}[0-9]{9}|(GB)?([0-9]{9}([0-9]{3})?|[A-Z]{2}[0-9]{3})|(HU)?[0-9]{8}|(IE)?[0-9]S[0-9]{5}L|(IT)?[0-9]{11}|(LT)?([0-9]{9}|[0-9]{12})|(LU)?[0-9]{8}|(LV)?[0-9]{11}|(MT)?[0-9]{8}|(NL)?[0-9]{9}B[0-9]{2}|(PL)?[0-9]{10}|(PT)?[0-9]{9}|(RO)?[0-9]{2,10}|(SE)?[0-9]{12}|(SI)?[0-9]{8}|(SK)?[0-9]{10})$/
								return reg.exec(vat.replace(/[^A-Z0-9]/g, ''))

							country = $(@el).find('#country').val().trim()
							if taxList[country]
								if !billing_infos.eu_vat
									$(@el).find('#errors').html(_lang['edit-payment-info'].errors['vat-cannot-be-blank']) #todo #translate
									return

								if !valid(billing_infos.eu_vat)
									$(@el).find('#errors').html(_lang['edit-payment-info'].errors['invalid-vat-number']) #todo #translate
									return

						if !billing_infos.name || !billing_infos.address.line1 || !billing_infos.address.postal_code || !billing_infos.address.city
							$(@el).find('#errors').html(_lang['edit-payment-info'].errors['required-fields-missing']) #todo #translate
							return

						$(cta).addClass 'spin'
						validateForm = (data) =>
							data.billing_infos = billing_infos

							data.authenticity_token = $('meta[name=csrf-token]').attr('content')

							$.ajax(
								type : 'POST'
								url : '/api/payment/create_or_update_customer'
								data : data
								error : =>
									$(cta).removeClass 'spin'
									$(@el).find('#errors').html('Internal server error') #translate #todo
								success : (resp) =>
									$(cta).removeClass 'spin'
									if not resp.error
										@_a.user.billing_infos = data.billing_infos
										@to('review-order')
									else
										$(@el).find('#errors').html(resp.error)
										#todo
							)

						#test-only
						@_a.user.billing_infos = billing_infos
						@_a.user.payment_method =
							card :
								brand : 'mastercard'
								exp_month : 5
								exp_year : 2023
								last4 : 1234
							name_on_card : 'Eric Cartman'
						@to('review-order')
						return

						if shouldSendMethod #tmp
							@stripe.createPaymentMethod({
								type : 'card',
								card : card
							}).then((result) =>
								if result.error
									document.getElementById('card-errors').textContent = result.error.message;
									$(cta).removeClass 'spin'
								else
									@_a.user.payment_method = result.paymentMethod
									@_a.user.payment_method.name_on_card = $(@el).find('#name-on-card').val()
									validateForm(result)
							)
						else
							validateForm({})
					)
			}
			{
				id : 'review-order'
				cta :
					label : _lang['review-order'].cta
					mousedown : ->
						$(@el).find('.cta').addClass('spin')
						$.ajax(
							type : 'POST'
							url : '/api/payment/subscribe'
							data :
								plan : @selectedPlan
								authenticity_token : $('meta[name=csrf-token]').attr('content')
							error : =>
								$(@el).find('.cta').removeClass('spin')
								$(@el).find('#errors').html('Internal server error') #todo #translate

							success : (resp) =>
								$(@el).find('.cta').removeClass('spin')
								if not resp.error
									if resp.status is 'requires_action'
										@stripe.confirmCardPayment(resp.client_secret).then((result) =>
											if result.error
												$(@el).find('#errors').html(result.error.message)
												#todo Display error.message in your UI.
											else # the webhook will update db
												@fire 'success', resp
										)
									else if resp.status is 'success'
										@fire 'success', resp
								else
									$(@el).find('#errors').html(resp.error)
									#todo
						)
				title : _lang['review-order'].title
				buildContent : ->
					if @_a.user.billing_infos.customer_type is 'business'
						if @_a.user.billing_infos.address.country is 'FR'
							tax = taxList['FR']
						else
							tax = 0
					else
						tax = taxList[@_a.user.billing_infos.address.country] || 0

					HT = PLANS[@selectedPlan].price

					total = (HT + (HT * tax / 100))

					@content.appendChild r.toDOM(
						['.review-order', [
							'#errors'
							['.split-bloc', [
								['.sub', [
									'.title ' + _lang['edit-payment-info']['billing-information']
									'div ' + @_a.user.billing_infos.name
									if @_a.user.billing_infos.eu_vat
										'div ' + @_a.user.billing_infos.eu_vat
									else
										null
									'div ' + @_a.user.billing_infos.address.line1
									'div ' + @_a.user.billing_infos.address.postal_code + ' ' + @_a.user.billing_infos.address.city
								]]
								['.sub', [
									'.title ' + _lang['edit-payment-info']['payment-method'].title
									@create(r.PaymentMethodBloc, { changeable : false }).el
								]]
							]]
							['.bloc', [
								'.title ' + _lang['review-order'].plan
								'div Pro'
							]]
							['.bloc.amount', [
								'.title ' + _lang['review-order']['amount-to-pay']
								['table', [
									['tr', [
										'td ' + _lang['review-order']['amount-ht']
										'td ' + HT + '.00€'
									]]
									['tr', [
										'td Taxes (' + tax + '%)'
										'td ' + (HT * tax / 100).toFixed(2) + '€'
									]]
									['tr', [
										'td ' + _lang['review-order']['amount-ttc']
										'td ' + total.toFixed(2) + '€'
									]]
								]]
							]]
							['.bloc.precisions', [
								'div ' + _lang['review-order']['precisions'].replace('%total%', total).replace('%period%', _lang['review-order'].period[@selectedPlan.split('-')[1]])
							]]
						]]
					)
			}
		]

		to : (id, data) ->
			@trace.push 'to-' + id

			step = @steps.one 'id', id
			index = @steps.indexOf(step)

			# refresh title
			@title.innerHTML = step.title

			@el.scrollTop = 0

			# refresh bottom
			@['bottom-row'].innerHTML = ''
			if index isnt 0
				@['bottom-row'].appendChild r.toDOM(
					tag : '.cta-ultra-light ← ' + _lang[id].back
					events : mousedown : =>
						@to @steps[index - 1].id
				)

			if step.cta
				@['bottom-row'].appendChild r.toDOM(
					tag : '.cta'
					children : [
						'.cta-label ' + step.cta.label #next
						'.cta-spinner'
					]
					events : mousedown : step.cta.mousedown.bind(@)
				)

			# refresh content
			@content.innerHTML = ''
			step.buildContent.call(@)

		'+init' : ->
			@to('select-plan')
	)

)

sand.define('PaymentMethodBloc', [
	'Seed'
], (r) ->

	r.Seed.extend(
		'+options' :
			onchange : null
			changeable : true

		tpl : ->
			['.payment-method', [
				'.card-brand.card-' + (if ['amex', 'mastercard', 'visa'].include(@_a.user.payment_method.card.brand) then @_a.user.payment_method.card.brand else 'unknown')
				['.card-details', [
					'.number_safe •••• •••• •••• ' + @_a.user.payment_method.card.last4
					'.name-on-card ' + @_a.user.payment_method.name_on_card
					'.expires_at ' + lang['payment-method']['expires-at'] + ' ' + (@_a.user.payment_method.card.exp_month / 100).toFixed(2).split('.')[1] + '/' + @_a.user.payment_method.card.exp_year
				]]
				if @changeable
					{
						tag : '.change ' + lang.general.change.capitalize()
						events : mousedown : @onchange.bind(@)
					}
				else
					null
			]]
	)
)

sand.require('augmentations/Seed', 'PaymentStepper', 'core/Array/*', (r) =>
	app = {
		user : {}
		config :
			stripe :
				public_key : 'a'
	}

	window.js = {
		user :
			lang : 'en'
	}

	stepper = new r.PaymentStepper(app : app)
	document.body.appendChild stepper.el
)