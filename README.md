# Yeoman Static scaffold

A client-side project workflow template.

## Instructions
### 1. Install Node.js
#### OS X

##### Prerequisites
This guides assumes you have installed the following tools successfully:
- Xcode
- Xcode developer tools
- git
- Homebrew

Use nave (or similar) to manage you Node.js installations. You should always try to use the latest stable version of Node.js.

In a terminal, run:

	brew install node
	npm install -g nave
	nave use stable

### 2. Install http-server

`http-server` is used to serve the static site under development. Install it using:

	npm install -g http-server

### 3. Install yeoman

After that install `yeoman`:

	npm install -g yo

Now install this package:

	npm install -g generator-static

### 4. Create a project

Now, to create a new static site project, run the following command:

	yo static:app my_project

Replace `my_project` with your own project name.

yeoman will handle installing the various dependencies initially (using npm and bower).

### 5. Write code!

- all stylesheets (css/less/scss/etc...) go in `app/assets/styles/`
- all scripts (js and coffee) go in `app/assets/scripts/`
- all html (or jade) go in `app/views/`

### 6. Build/Debug

Grunt is used as the task runner. To build the your code run:

	grunt

If you are in a staging or production evironment you should set `NODE_ENV` so the code is optimised. For example:

	NODE_ENV=production grunt

or

	NODE_ENV=staging grunt

#### During development

A good way to debug the code as you develop the site is as follows:

- open one terminal window and use `nave` to select your Node.js installation
- navigate into your project's root directory and run `grunt && grunt watch`
- open a second terminal window and (again) use `nave` to select your Node.js installation
- navigate into `<PROJECT_ROOT>/dist/` and run `http-server -c-1`
- you should now have a live development server running at `http://localhost:8080` which serves up the site


## Background
### Batteries Included:
- Grunt: Task runner (similar to make, ant)
- Bower: Front-end package management (similar to pip, gem)

### Project Structure
	app/
	.... assets/
	.... .... images/
	.... .... less/
	.... .... css/
	.... .... js/
	.... .... coffee/
	.... views/ <- contains jade templates for site pages
	.bowerrc <- bower command configuration
	.editorconfig <- editor configuration rules (indent style, line endings, etc...)
	.gitignore <- contains sensible defaults for files/folders to ignore
	bower.json  <- bower package definition packages
	Gruntfile.coffee  <- grunt tasks definition module
	package.json  <- npm package definition
