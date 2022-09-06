#global module:false
module.exports = (grunt) ->

	# Default task.
	@registerTask(
		"default"
		"Default task, that runs the production build"
		[
			"dist"
		]
	)

	@registerTask(
		"dist"
		"Produces the production files"
		[
			#"test"
			"build"
			"assets-dist"
			"assemble"
			"htmlmin"
			#"htmllint"
			#"bootlint"
			"useMinAssets"
		]
	)

	#Alternate External tasks
	@registerTask(
		"debug"
		"Produces unminified files"
		[
			"build"
			"assemble"
			#"htmllint"
		]
	)

	@registerTask(
		"build"
		"Produces unminified files"
		[
			"checkDependencies"
			"clean:dist"
			"copy:wetboew"
			"copy:demos"
			"copy:demos_min"
			"copy:gcweb"
			"copy:gcweb-assets"
			"assets"
			"css"
			"js"
		]
	)

	@registerTask(
		"init"
		"Only needed when the repo is first cloned"
		[
			"install-dependencies"
			"hub"
		]
	)

	@registerTask(
		"deploy"
		"Build and deploy artifacts to wet-boew-dist"
		->
			if process.env.TRAVIS_PULL_REQUEST is "false" and process.env.DIST_REPO isnt `undefined` and ( process.env.TRAVIS_TAG isnt "" or process.env.TRAVIS_BRANCH is "master" )
				grunt.task.run [
					"copy:deploy"
					"gh-pages:travis"
					"gh-pages:travis_cdn"
					"wb-update-examples"
				]
	)

	@registerTask(
		"test-mocha"
		"Run tests locally with Grunt Mocha"
		[
			"pre-mocha"
			"mocha"
		]
	)

	@registerTask(
		"pre-mocha"
		"INTERNAL: prepare for running Mocha unit tests"
		() ->
			grunt.task.run [
				"concat:test"
				"copy:test"
				"assemble:test"
			]

			#Prevents multiple instances of connect from running
			if grunt.config.get('connect.test.options.port') is `undefined`
				grunt.task.run "connect:test"
	)

	@registerTask(
		"server"
		"Run the Connect web server for local repo"
		[
			"connect:server"
			"watch"
			]
	)

	@registerTask(
		"css"
		"INTERNAL: Compiles Sass and vendor prefixes the result"
		[
			"clean:css_min"
			"sass"
			"autoprefixer"
			"usebanner:css"
			"cssmin"
			"cssmin_ie8_clean"
		]
	)

	@registerTask(
		"assets-dist"
		"INTERNAL: Process non-CSS/JS assets to dist"
		[
			"copy:site_min"
			#"copy:wetboew_demo_min"
		]
	)

	@registerTask(
		"assets"
		"INTERNAL: Process non-CSS/JS assets to dist"
		[
			"copy:site"
			"copy:assets"
			"copy:fonts"
			#"copy:wetboew_demo"
		]
	)

	@registerTask(
		"test"
		"INTERNAL: Runs testing tasks except for SauceLabs testing"
		[
			"sasslint"
		]
	)

	@registerTask(
		"js"
		"INTERNAL: Brings in the custom JavaScripts."
		[
			"concat:plugins"
			"copy:js_lib"
			"copy:deps_custom"
			"uglify"
			"copy:deps"
			"clean:deps"
		]
	)

	@registerTask(
		"useMinAssets"
		"Replace unmin refrences with the min paths for HTML files"
		() ->
			htmlFiles = grunt.file.expand(
				"dist/**/*.html"
				"!dist/unmin/**/*.html"
			)

			htmlFiles.forEach(
				( file ) ->
					contents = grunt.file.read file
					contents = contents.replace /\.\.\/(wet\-boew|gcweb)/gi, "$1"
					contents = contents.replace /\"(?!https:)([^\"]*)?\.(js|css)\"/g, "\"$1.min.$2\""

					grunt.file.write file, contents
			)
	)

	@initConfig

		# Metadata.
		pkg: @file.readJSON "package.json"
		themeDist: "dist/<%= pkg.name %>"
		jqueryVersion: @file.readJSON "lib/jquery/bower.json"
		jqueryOldIEVersion: @file.readJSON "lib/jquery-oldIE/bower.json"
		banner: "/*!\n * Web Experience Toolkit (WET) / Boîte à outils de l'expérience Web (BOEW)\n * wet-boew.github.io/wet-boew/License-en.html / wet-boew.github.io/wet-boew/Licence-fr.html\n" +
				" * v<%= pkg.version %> - " + "<%= grunt.template.today('yyyy-mm-dd') %>\n *\n */"

		# Commit Messages
		travisBuildMessage: "Travis build " + process.env.TRAVIS_BUILD_NUMBER
		distDeployMessage: ((
			if process.env.TRAVIS_TAG
				"Production files for the " + process.env.TRAVIS_TAG + " release."
			else
				"<%= travisBuildMessage %>"
		))
		cdnDeployMessage: ((
			if process.env.TRAVIS_TAG
				"CDN files for the " + process.env.TRAVIS_TAG + " release."
			else
				"<%= travisBuildMessage %>"
		))

		deployBranch: "<%= pkg.name %>"

		checkDependencies:
			all:
				options:
					npmInstall: false

		clean:
			dist: [ "dist"]
			lib: ["lib"]
			deps: ["<%= themeDist %>/theme-js-deps"]
			css: [
				"<%= themeDist %>/css"
				"<%= themeDist %>/assets/css"
			]
			css_min: [
				"<%= themeDist %>/css/*.min.css"
				"<%= themeDist %>/assets/css/*.min.css"
			]

		concat:
			plugins:
				options:
					stripBanners: false
				src: [
					"src/plugins/**/*.js"
					"src/theme.js"
					"!src/plugins/**/test.js"
					"!src/plugins/**/assets/*.js"
					"!src/plugins/**/demo/*.js"
				]
				dest: "<%= themeDist %>/js/theme.js"

			test:
				src: [
					"lib/wet-boew/src/test.js"
					"src/**/test.js"
				]
				dest: "dist/unmin/test/tests.js"

		copy:
			wetboew:
				expand: true
				cwd: "lib/GCWeb/lib/wet-boew/dist"
				src: [
					"wet-boew/**/*.*"
				]
				dest: "dist"
			"gcweb":
				expand: true
				cwd: "lib/GCWeb/dist/"
				src: [
					"img/**/*.*"
					# "**/ajax/**/*.*"
				]
				dest: "dist"
			"gcweb-assets":
				expand: true
				cwd: "lib/GCWeb/dist/GCWeb/"
				src: [
					"assets/**/*.*"
					"fonts/**/*.*"
					"css/**/*.css"
					"!css/**/*.min.css"
				]
				dest: "<%= themeDist %>"
			#wetboew_demo:
			#	expand: true
			#	cwd: "lib/wet-boew/dist/unmin"
			#	src: [
			#		"demos/**/*.*"
			#		"docs/**/*.*"
			#		"!**/*.html"
			#		"demos/**/ajax/*.html"
			#	]
			#	dest: "dist/unmin"
			#wetboew_demo_min:
			#	expand: true
			#	cwd: "lib/wet-boew/dist"
			#	src: "<%= copy.wetboew_demo.src %>"
			#	dest: "dist"
			site:
				expand: true
				cwd: "site/img"
				src: "**/*.*"
				dest: "dist/unmin/img"
			site_min:
				expand: true
				cwd: "site/img"
				src: "**/*.*"
				dest: "dist/img"
			assets:
				expand: true
				cwd: "src/assets"
				src: "**/*.*"
				dest: "<%= themeDist %>/assets"
			# Copy third party library
			js_lib:
				expand: true
				flatten: true
				cwd: "lib"
				src: [
					"jsonpointer/src/jsonpointer.js"
					"JSON-Patch/src/json-patch.js"
				]
				dest: "<%= themeDist %>/theme-js-deps"
			test:
				files: [
					cwd: "src"
					src: [
						"**/test/*.*"
					]
					dest: "dist/unmin/test"
					rename: (dest, src) ->
						dest + src.replace /plugins|polyfills|others/, ""
					expand: true
				,
					cwd: "node_modules"
					src: [
						"mocha/mocha.js"
						"mocha/mocha.css"
						"expect.js/index.js"
						"sinon/pkg/sinon.js"
						"sinon/pkg/sinon-ie.js"
					]
					dest: "dist/unmin/test"
					expand: true
					flatten: true
				]
			deps_custom:
				expand: true
				cwd: "src/plugins/deps"
				src: "**/*.*"
				dest: "<%= themeDist %>/theme-js-deps"
			deps:
				expand: true
				cwd: "<%= themeDist %>/theme-js-deps"
				src: "**/*.*"
				dest: "dist/wet-boew/js/deps"
			demos:
				expand:true
				cwd: "src/plugins"
				src: [
					"**/*.{jpg,html,xml}"
					"**/demo/*.*"
					"**/ajax/*.*"
					"**/img/*.*"
					"!**/assets/*.*"
					"!**/deps/*.*"
					"!**/test/*.*"
					"!**/*.scss"
				]
				dest: "dist/unmin/demos/"
			demos_min:
				expand:true
				cwd: "src/plugins"
				src: [
					"**/*.{jpg,html,xml}"
					"**/demo/*.*"
					"**/ajax/*.*"
					"**/img/*.*"
					"!**/assets/*.*"
					"!**/deps/*.*"
					"!**/test/*.*"
					"!**/*.scss"
				]
				dest: "dist/demos/"
			fonts:
				expand: true
				cwd: "src/fonts"
				src: [
					"**/*.*"
					"!**/*.scss"
				]
				dest: "<%= themeDist %>/fonts"
			deploy:
				files: [
					{
						src: [
							"*.txt"
							"README.md"
						]
						dest: "dist"
						expand: true
					}

					{
						src: "*.txt"
						dest: "<%= themeDist %>"
						expand: true
					}

					#Backwards compatibility.
					#TODO: Remove in v4.1
					{
						cwd: "<%= themeDist %>"
						src: "**/*.*"
						dest: "dist"
						expand: true
					}
					{
						cwd: "dist/wet-boew"
						src: "**/*.*"
						dest: "dist"
						expand: true
					}
				]

				#Backwards compatibility.
				#TODO: Remove in v4.1
				options:
					noProcess: [
						'**/*.{png,gif,jpg,ico,ttf,eot,otf,woff,svg,swf}'
					]
					process: (content, filepath) ->
						if filepath.match /\.css/
							return content.replace /\.\.\/\.\.\/wet-boew\/(assets|fonts)/g, '../$1'
						content

		sasslint:
			options:
				configFile: ".sass-lint.yml"
			all:
				expand: true
				src: [
						"**/*.scss"
						"!lib/**"
						"!node_modules/**"
						"!dist/**"
					]

		sass:
			all:
				expand: true
				cwd: "src"
				src: "*.scss"
				dest: "<%= themeDist %>/css"
				ext: ".css"

		autoprefixer:
			options:
				browsers: [
					"last 2 versions"
					"android >= 2.3"
					"bb >= 7"
					"ff >= 17"
					"ie >= 8"
					"ios 5"
					"opera 12.1"
				]
			modern:
				cwd: "<%= themeDist %>/css"
				src: [
					"*.css"
					"!ie8*.css"
				]
				dest: "<%= themeDist %>/css"
				expand: true
			oldIE:
				options:
					browsers: [
						"ie 8"
					]
				cwd: "<%= themeDist %>/css"
				src: [
					"ie8*.css"
				]
				dest: "<%= themeDist %>/css"
				expand: true

		usebanner:
			css:
				options:
					banner: "@charset \"utf-8\";\n<%= banner %>"
				files:
					src: "<%= themeDist %>/css/*.*"

		cssmin:
			theme:
				expand: true
				cwd: "<%= themeDist %>/css"
				src: "*.css"
				ext: ".min.css"
				dest: "<%= themeDist %>/css"
			assets:
				expand: true
				cwd: "<%= themeDist %>/assets/css"
				src: "*.css"
				ext: ".min.css"
				dest: "<%= themeDist %>/assets/css"

		cssmin_ie8_clean:
			min:
				expand: true
				cwd: "<%= themeDist %>/css"
				src: "**/ie8*.min.css"
				dest: "<%= themeDist %>/css"

		jshint:
			options:
				jshintrc: "lib/wet-boew/.jshintrc"

			lib_test:
				src: [
					"src/**/*.js"
				]

		jscs:
			all:
				src: [
					"src/**/*.js"
				]

		# Minify
		uglify:
			options:
				preserveComments: (uglify,comment) ->
					return comment.value.match(/^!/i)
			dist:
				options:
					banner: "<%= banner %>"
				expand: true
				cwd: "<%= themeDist %>"
				src: [
					"**/*.js"
					"!<%= themeDist %>/theme-js-deps"
				]
				dest: "<%= themeDist %>"
				ext: ".min.js"

			deps:
				options:
					preserveComments: "some"
				expand: true
				cwd: "<%= themeDist %>/theme-js-deps"
				src: [
					"*.js"
					"!*.min.js"
				]
				dest: "<%= themeDist %>/theme-js-deps"
				ext: ".min.js"
				extDot: "last"

		assemble:
			options:
				prettify:
					indent: 2
				marked:
					sanitize: false
				production: false
				data: [
					"lib/GCWeb/lib/wet-boew/site/data/**/*.{yml,json}"
					"lib/GCWeb/site/data/**/*.{yml,json}"
					"site/data/**/*.{yml,json}"
				]
				helpers: [
					"lib/GCWeb/lib/wet-boew/site/helpers/helper{,s}-*.js"
					"lib/GCWeb/site/helpers/helper{,s}-*.js"
					"site/helpers/helper{,s}-*.js"
				]
				partials: [
					"lib/GCWeb/lib/wet-boew/site/includes/**/*.hbs"
					"lib/GCWeb/site/includes/**/*.hbs"
					"site/includes/**/*.hbs"
				]
				layoutdir: "site/layouts"
				layout: "default.hbs"
				environment:
					jqueryVersion: "<%= jqueryVersion.version %>"
					jqueryOldIEVersion: "<%= jqueryOldIEVersion.version %>"
				assets: "dist/unmin"

			ajax:
				options:
					layoutdir: "lib/GCWeb/lib/wet-boew/site/layouts"
					layout: "ajax.hbs"

				cwd: "site/pages/ajax"
				src: [
					"*.hbs"
				]
				dest: "dist/unmin/ajax/"
				expand: true
				flatten: true

			demos:
				files: [
						#site
						expand: true
						cwd: "site/pages"
						src: [
							"**/*.hbs"
							"!ajax/**.hbs"
							"!splashpage.hbs"
							"!demos/**/*.hbs"
							"!docs/**/*.hbs"
							"!partners/**/*.hbs"
							"!servicecomplexe/**/*.hbs"
							"!styleguide/**/*.hbs"
						]
						dest: "dist/unmin"
					,
						#plugins with business logic (theme plugins)
						expand: true
						cwd: "src/plugins"
						src: [
							"**/*.hbs"
						]
						dest: "dist/unmin/demos"
					#,
					#	#docs
					#	expand: true
					#	cwd: "lib/GCWeb/lib/wet-boew/site/pages/docs"
					#	src: [
					#		"**/*.hbs"
					#	]
					#	dest: "dist/unmin/docs"
					#,
					#	#plugins
					#	expand: true
					#	cwd: "lib/GCWeb/lib/wet-boew/site/pages/demos"
					#	src: [
					#		"**/*.hbs"
					#	]
					#	dest: "dist/unmin/demos"
					#,
					#	expand: true
					#	cwd: "lib/GCWeb/lib/wet-boew/src/plugins"
					#	src: [
					#		"**/*.hbs"
					#	]
					#	dest: "dist/unmin/demos"
					#,
					#	expand: true
					#	cwd: "lib/GCWeb/lib/wet-boew/src/polyfills"
					#	src: "**/*.hbs"
					#	dest: "dist/unmin/demos"
					#,
					#	expand: true
					#	cwd: "lib/GCWeb/lib/wet-boew/src/other"
					#	src: "**/*.hbs"
					#	dest: "dist/unmin/demos"
				]

			#experimental:
			#	options:
			#		experimental: true
			#	cwd: "site/pages"
			#	src: [
			#		"*.hbs",
			#		"!splashpage.hbs"
			#	]
			#	dest: "dist/unmin/experimental"
			#	expand: true

			splash:
				options:
					layout: "splashpage.hbs"
				cwd: "site/pages"
				src: [
					"splashpage.hbs"
				]
				dest: "dist/unmin/"
				expand: true

			#partners:
			#	cwd: "site/pages/partners"
			#	src: [
			#		"*.hbs"
			#	]
			#	dest: "dist/unmin/partners/"
			#	expand: true
			#
			#test:
			#	options:
			#		offline: true
			#	expand: true
			#	cwd: "site/pages"
			#	src: "test/test.hbs"
			#	dest: "dist/unmin"

		htmlmin:
			options:
				collapseWhitespace: true
				preserveLineBreaks: true
				preventAttributesEscaping: true
			all:
				cwd: "dist/unmin"
				src: [
					"**/*.html"
				]
				dest: "dist"
				expand: true

		htmllint:
			ajax:
				options:
					ignore: [
						"Element “head” is missing a required instance of child element “title”."
						"The “details” element is not supported properly by browsers yet. It would probably be better to wait for implementations."
						"The value of attribute “title” on element “a” from namespace “http://www.w3.org/1999/xhtml” is not in Unicode Normalization Form C." #required for vietnamese translations
						"Text run is not in Unicode Normalization Form C." #required for vietnamese translations
					]
				src: [
					"dist/unmin/ajax/**/*.html"
					"dist/unmin/demos/menu/demo/*.html"
				]
			templates:
				options:
					ignore: [
						"The “details” element is not supported properly by browsers yet. It would probably be better to wait for implementations."
						"Element “dl” is missing a required instance of child element “dd”."
						"XHTML element “dl” is missing a required instance of child element “dd”."
						"Element “dl” is missing a required instance of child element “dt”."
						"XHTML element “dl” is missing a required instance of child element “dt”."
						"Empty heading."
					]
				src: [
					"dist/unmin/demos/data-json/template-en.html"
					"dist/unmin/demos/data-json/template-fr.html"
				]
			all:
				options:
					ignore: [
						"The “details” element is not supported properly by browsers yet. It would probably be better to wait for implementations."
						"The “date” input type is not supported in all browsers. Please be sure to test, and consider using a polyfill."
						"The “track” element is not supported by browsers yet. It would probably be better to wait for implementations."
						"The “time” input type is not supported in all browsers. Please be sure to test, and consider using a polyfill."
						"The value of attribute “title” on element “a” from namespace “http://www.w3.org/1999/xhtml” is not in Unicode Normalization Form C." #required for vietnamese translations
						"Text run is not in Unicode Normalization Form C." #required for vietnamese translations
						"The “longdesc” attribute on the “img” element is obsolete. Use a regular “a” element to link to the description."
						/Bad value “\.\/\.\.\/[^”]*” for attribute “[^”]*” on XHTML element “[^”]*”: Path component contains a segment “\/\.\.\/” not at the beginning of a relative reference, or it contains a “\/\.\/”. These should be removed./
					]
				src: [
					"dist/unmin/**/*.html"
					"!dist/unmin/**/ajax/**/*.html"
					"!dist/unmin/assets/**/*.html"
					"!dist/unmin/demos/menu/demo/*.html"
					"!dist/unmin/test/*.html"
					"!dist/unmin/demos/data-json/template-en.html"
					"!dist/unmin/demos/data-json/template-fr.html"
				]

		bootlint:
			all:
				options:
					stoponerror: true
					relaxerror: [
						# We recommend handling this through the server headers so it never appears in the markup
						"W002" # `<head>` is missing X-UA-Compatible `<meta>` tag that disables old IE compatibility modes
						# TODO: The rules below should be resolved
						"E013" # Only columns (`.col-*-*`) may be children of `.row`s
						"E014" # Columns (`.col-*-*`) can only be children of `.row`s or `.form-group`s
						"E031" # Glyphicon classes must only be used on elements that contain no text content and have no child elements.
						"E023" # `.panel-body` must have a `.panel` or `.panel-collapse` parent
						"E024" # `.panel-heading` must have a `.panel` parent
						"W010" # Using `.pull-left` or `.pull-right` as part of the media object component is deprecated as of Bootstrap v3.3.0. Use `.media-left` or `.media-right` instead.
						"E032" # `.modal-content` must be a child of `.modal-dialog`
						"W009" # Using empty spacer columns isn't necessary with Bootstrap's grid. So instead of having an empty grid column with `class="col-xs-12"` , just add `class="col-xs-offset-12"` to the next grid column.
						"E012" # `.input-group` and `.col-*-*` cannot be used directly on the same element. Instead, nest the `.input-group` within the `.col-*-*`
					]
				src: [
					"dist/**/*.html"
					# Ignore HTML fragments used for the menus
					"!dist/**/assets/*.html"
					"!dist/**/ajax/*.html"
				]

		watch:
			gruntfile:
				files: "Gruntfile.coffee"
				tasks: [
					"dist"
				]
			sass:
				files: "src/**/*.scss"
				tasks: [
					"css"
				]
			pages:
				files: "site/pages/**/*.hbs"
				tasks: [
					"assemble:demos"
					"htmlmin"
					"useMinAssets"
				]
			includes:
				files: "site/includes/**/*.hbs"
				tasks: [
					"assemble"
					"htmlmin"
					"useMinAssets"
				]
			layouts:
				files: "site/layouts/**/*.hbs"
				tasks: [
					"assemble"
					"htmlmin"
					"useMinAssets"
				]
			assets_css:
				files: "src/assets/css/*.css"
				tasks: [
					"copy:assets"
					"cssmin:assets"
				]
			lib_test:
				files: "<%= jshint.lib_test.src %>"
				tasks: [
					"jshint:lib_test"
				]
			source:
				files: "<%= jshint.lib_test.src %>"
				tasks: [
					"build"
				]
				options:
					interval: 5007
					livereload: true

		hub:
			"GCWeb":
				src: [
					"lib/GCWeb/Gruntfile.coffee"
					"lib/GCWeb/lib/wet-boew/Gruntfile.coffee"
				]
				tasks: [
					"dist"
				]

		"install-dependencies":
			options:
				cwd: "lib/GCWeb"
				failOnError: false
				isDevelopment: true

		connect:
			options:
				port: 8000

			server:
				options:
					base: "dist"
					middleware: (connect, options, middlewares) ->
						middlewares.unshift(connect.compress(
							filter: (req, res) ->
								/json|text|javascript|dart|image\/svg\+xml|application\/x-font-ttf|application\/vnd\.ms-opentype|application\/vnd\.ms-fontobject/.test(res.getHeader('Content-Type'))
						))
						middlewares

			test:
				options:
					base: "."
					middleware: (connect, options, middlewares) ->
						middlewares.unshift(connect.compress(
							filter: (req, res) ->
								/json|text|javascript|dart|image\/svg\+xml|application\/x-font-ttf|application\/vnd\.ms-opentype|application\/vnd\.ms-fontobject/.test res.getHeader("Content-Type")
						))
						middlewares

		mocha:
			all:
				options:
					reporter: "Spec"
					urls: ["http://localhost:8000/dist/unmin/test/test.html?txthl=just%20some%7Ctest"]

		"gh-pages":
			options:
				clone: "themes-dist"
				base: "dist"

			travis:
				options:
					repo: process.env.DIST_REPO
					branch: "<%= deployBranch %>"
					message: "<%= distDeployMessage %>"
					tag: ((
						if process.env.TRAVIS_TAG then process.env.TRAVIS_TAG + "-" + "<%= pkg.name.toLowerCase() %>" else false
					))
				src: [
					"**/*.*"
				]

			travis_cdn:
				options:
					repo: process.env.CDN_REPO
					branch: "<%= deployBranch %>"
					clone: "themes-cdn"
					base: "<%= themeDist %>"
					message: "<%= cdnDeployMessage %>"
					tag: ((
						if process.env.TRAVIS_TAG then process.env.TRAVIS_TAG + "-" + "<%= pkg.name.toLowerCase() %>" else false
					))
				src: [
					"**/*.*"
				]

			local:
				src: [
					"**/*.*"
				]

		"wb-update-examples":
			travis:
				options:
					repo: process.env.DEMOS_REPO
					branch: process.env.DEMOS_BRANCH
					message: "<%= distDeployMessage %>"

	require( "load-grunt-tasks" )( grunt )

	require( "time-grunt" )( grunt )
	@
