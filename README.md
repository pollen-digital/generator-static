# Yeoman Static scaffold

A client-side project workflow template.

## Instructions
### 1. Install Node.js

Skip this section if you have a node evironment setup.

#### OS X

##### Prerequisites

This guides assumes you have installed the following tools successfully:
- Xcode
- Xcode developer tools
- git
- Homebrew

Use nave (or similar) to manage you Node.js installations. You should always try
to use the latest stable version of Node.js.

In a terminal, run:

	brew install node
	npm install -g nave
	nave use stable

### 2. Install development tools

	npm install -g bower grunt-cli yo generator-static http-server

- `bower` installs and manages many client-side dependencies (e.g. jQuery)
- `grunt-cli` used to execute grunt tasks defined in the project
- `yo` and `generator-static` will install yeoman and this generator
- `http-server` is used for serving the site in development

### 3. Create a project

Now, to create a new static site project, run the following command:

	mkdir my_project && cd my_project
	yo static:app

Replace `my_project` with your own project name.

yeoman will handle installing the various dependencies initially (using npm and
bower).

### 4. Write code!

- all stylesheets (css/less/scss) go in `<PROJECT_ROOT>/app/assets/styles/`
- all scripts (js and coffee) go in `<PROJECT_ROOT>/app/assets/scripts/`
- all html (or jade) go in `<PROJECT_ROOT>/app/views/`

### 5. Build/Debug

Grunt is used as the task runner. To build the your code run:

	grunt

If you are in a staging or production evironment you should set `NODE_ENV` so
the code is optimised. For example:

	NODE_ENV=production grunt

or

	NODE_ENV=staging grunt

#### During development

A good way to debug the code as you develop the site is as follows:

- open one terminal window and use `nave` to select your Node.js installation
- navigate into your project's root directory and run `grunt && grunt watch`
- open a second terminal window and (again) use `nave` to select your Node.js installation
- navigate into `<PROJECT_ROOT>/dist/` and run `http-server -c-1`
- you should now have a live development server running at
`http://localhost:8080` which serves up the site

## More info

### Project Structure
	<PROJECT_ROOT>/
		app/
		.... assets/
		.... .... images/
		.... .... styles/
		.... .... scripts/
		.... views/ <- contains jade templates for site pages
		.bowerrc <- bower cli configuration
		.editorconfig <- editor configuration rules (indent style, line endings)
		.gitignore <- contains sensible defaults for files/folders to ignore
		bower.json  <- bower package definition packages
		defaults.json <- default configuration for grunt tasks
		Gruntfile.coffee  <- grunt tasks definition module
		package.json  <- npm package definition

### Project settings

The project's default settings are found in `defaults.json`. If you wish to
override any values, create a file called `locals.json` and define the new
values for the desired keys.

If you want to add new settings to use in your project, ensure you have defined
default values for them in `defaults.json` and you can then override them in
`locals.json` if necessary.

Jade templates have access to settings using the `settings` context variable.

### A note about Jade templates

This project relies on Jade templates to compose the site's pages. Templates
are placed in the `<PROJECT_ROOT>/app/views/` folder.

Any template whose name begins with `_` (underscore) is considered a 'partial'
and is not compiled into the output directory (`<PROJECT_ROOT>/dist/views/` by
default). These can be included and extended by other templates and partial.

### Use cases

#### Adding a client-side dependency

Let us assume you want to use lodash on your site.

1. In the project's root directory where `bower.json` is located,
run `bower install --save lodash`
1. Open `Gruntfile.coffee` and look for the comment starting with
`# CHECKPOINT: [js]`

1. Add `lodash.js`\* to the list of modules to include in JS application bundle.
You should now have something similar to the following lines:

		files:
		  '<%= paths.dist + paths.scripts %>bundle.js': [
		    '<%= paths.components %>jquery/jquery.js'
		    # CHECKPOINT: [js] list the modules you want to include into the
		    # js application bundle here. This includes third party modules,
		    # compiled coffee files and any other js modules you manually
		    # included in the project tree
		    # NOTE: ordering matters
		    '<%= paths.components %>lodash/lodash.js'
		    '<%= paths.temp + paths.scripts %>my-module.js'
		  ]

1. (Optional) If you are running `grunt watch` in terminal, kill it
1. Run `grunt` (or `grunt default watch` if you want to watch for changes)

_\*Note: Use unminified version of modules whenever possible_

#### Working with styles

In `Gruntfile.coffee`, you will find that the `less` task only compiles
`<PROJECT_ROOT>/app/assets/styles/style.less`. This means that you should
`style.less` to define the style for the entire site. A typical `style.less` may contain something similar to the following:

	@import 'bootstrap/less/variables';
	@import 'variables';

	@import 'bootstrap/less/mixins';
	@import 'bootstrap/less/reset';
	@import 'bootstrap/less/scaffolding';
	@import 'bootstrap/less/grid';
	@import 'bootstrap/less/layouts';
	@import 'bootstrap/less/type';
	@import 'bootstrap/less/tables';
	@import 'bootstrap/less/sprites';
	@import 'bootstrap/less/buttons';
	@import 'bootstrap/less/component-animations';
	@import 'bootstrap/less/responsive-utilities';
	@import 'bootstrap/less/utilities';

	@import 'icons';
	@import 'buttons';
	@import 'type';
	@import 'structure';
	@import 'theme';

#### Referencing assets

There are two places where you might want to reference assets (css/js/img):
in Jade templates or LESS/CSS stylesheets.

##### Jade templates

When writing templates you have access to a function called
`asset(path, environmentSuffix)`. So, for example, to include javascript asset
in a template (let's call it _base.jade for this example), you would write the
following:

	// somewhere in _base.jade
	// ...
	block scripts
	  script(type='text/javascript', src=asset('scripts/bundle.js', '.min'))
	// ...

The second argument in the `asset` functions indicates that this asset is
environment-sensitive. That is: if we are running grunt in development
(e.g. `NODE_ENV=development`), then use the unminified version otherwise use
minified version. So for example given the lines above:

With `NODE_ENV=development`, they would compile to:

	<script type="text/javascript" src="/assets/scripts/bundle.js?rel=5826269c"></script>

With `NODE_ENV=production`, they would compile to:

	<script type="text/javascript" src="/assets/scripts/bundle.min.js?rel=af26cd84"></script>

##### LESS/CSS stylesheets

In stylesheets, you simply reference assets using `$ASSET(<asset_path>)`.
For example:

	.mast {
	  background: url($ASSET(images/texture.png)) repeat;
	}

There is a grunt task called `replace` that will look through the compiled
LESS/CSS and replace any instances of the `$ASSET()` string with the resolved
path of asset

##### Notes

1. The asset helper being used here uses the cache busting technique of
appending the first 8 digits of the md5 checksum for a given asset as a request parameter. This can be turned off by setting `"ASSET_CACHE_BUSTING": false`
in your local settings file (`locals.json`).
1. Asset paths passed to the asset helper for both Jade templates and
stylesheets are relative to the `ASSET_ROOT` which is `app/assets/` by default
(see `defaults.json`).
