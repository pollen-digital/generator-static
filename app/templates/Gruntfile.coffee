### global module:false ###
fs = require 'fs'
gruntutils = require './gruntutils'
AssetManager = gruntutils.AssetManager
extend = gruntutils.extend

module.exports = (grunt) ->
  bowerConf = grunt.file.readJSON '.bowerrc'
  defaults = grunt.file.readJSON 'defaults.json'
  locals = {}
  if fs.existsSync './locals.json'
    locals = grunt.file.readJSON 'locals.json'
  settings = extend {}, defaults, locals

  ENV = process.env['NODE_ENV'] or settings['ENV'] or 'development'

  paths =
    temp: 'temp/'
    dist: 'dist/'
    assets: settings.ASSET_ROOT
    views: 'app/views/'
    components: bowerConf.directory
    scripts: '<%= paths.assets %>scripts/'
    stylesheets: '<%= paths.assets %>styles/'
    images: '<%= paths.assets %>images/'

  assetHelper = new AssetManager(
    paths.dist + settings.ASSET_ROOT
    settings.ASSET_URL
    settings.ASSET_CACHE_BUSTING
    ENV
  ).makeHelper()

  grunt.initConfig
    paths: paths

    # optimise png and jpeg files
    imagemin:
      dist:
        options:
          optimizationLevel: 3
        files: [
          {
            expand: true
            cwd: '<%= paths.images %>'
            src: '**/*.{png,jpg,jpeg}'
            dest: '<%= paths.dist + paths.images %>'
          }
        ]

    coffee:
      build:
        files: [
          {
            expand: true
            cwd: '<%= paths.scripts %>'
            src: '**/*.coffee'
            dest: '<%= paths.temp + paths.scripts %>'
            rename: (dest, src) ->
              dest + src.split('.').slice(0,-1).join('.') + '.js'
          }
        ]

    less:
      build:
        options:
          paths: ['<%= paths.components %>', '<%= paths.stylesheets %>']
        files:
          '<%= paths.temp + paths.stylesheets %>style.css':
            '<%= paths.stylesheets %>style.less'

    copy:
      js:
        files: [
          # copy any js files inside the scripts folder
          {
            expand: true
            cwd: '<%= paths.scripts %>'
            src: '**/*.js'
            dest: '<%= paths.temp + paths.scripts %>'
          }
          # respond.js needs to be included separately so we copy it into
          # output folder
          {
            '<%= paths.dist + paths.scripts %>respond.min.js':
              '<%= paths.components %>respond/respond.min.js'
          }
        ]
      css:
        files: [
          {
            expand: true
            cwd: '<%= paths.stylesheets %>'
            src: '**/*.css'
            dest: '<%= paths.temp + paths.stylesheets %>'
          }
        ]
      images:
        files: [
          {
          expand: true
          cwd: '<%= paths.images %>'
          src: '*.{gif,ico}'
          dest: '<%= paths.dist + paths.images %>'
          }
        ]
      dist:
        files:
          '<%= paths.dist + paths.stylesheets %>style.css':
            '<%= paths.temp + paths.stylesheets %>style.css'

    cssmin:
      dist:
        files:
          '<%= paths.dist + paths.stylesheets %>style.min.css':
            '<%= paths.dist + paths.stylesheets %>style.css'

    # generates the js application bundle both minified and unminified versions
    uglify:
      build:
        options:
          mangle: false
          compress: false
          beautify: true
        files:
          '<%= paths.dist + paths.scripts %>bundle.js': [
            '<%= paths.components %>jquery/jquery.js'
            # CHECKPOINT: [js] list the modules you want to include into the
            # js application bundle here. This includes third party modules,
            # compiled coffee files and any other js modules you manually
            # included in the project tree
            # NOTE: ordering matters
          ]
      dist:
        options:
          preserveComments: 'some'
        files:
          '<%= paths.dist + paths.scripts %>bundle.min.js':
            '<%= paths.dist + paths.scripts %>bundle.js'

    jade:
      dist:
        options:
          pretty: true
          data:
            settings: settings
            asset: assetHelper
            ENV: ENV
        files: [
          {
            expand: true
            cwd: '<%= paths.views %>'
            src: ['**/*.jade', '!**/_*.jade']
            dest: '<%= paths.dist + paths.views %>'
            ext: '.html'
          }
        ]

    # finds all instances of the string $ASSET(some_asset_path) in the
    # concatenated and resolves the path of the asset.
    # It relies on the assetHelper for this.
    # Example (assuming asset url is '/assets/'):
    # .bg { background: url($ASSET(images/background.png)); }
    # gets replaced with
    # .bg { background: url(/assets/images/background.png?rel=a27bce2); }
    replace:
      css:
        src: '<%= paths.dist + paths.stylesheets %>style.css'
        overwrite: true
        replacements: [
          {
            from: /\$ASSET\((.*?)\)/g
            to: ->
              groups = arguments[3]
              assetHelper groups[0]
          }
        ]

    watch:
      images:
        files: '<%= paths.images %>**/*.{png,gif,jpg,jpeg}'
        tasks: ['images', 'stylesheets', 'jade']
      views:
        files: '<%= paths.views %>**/*.jade'
        tasks: ['jade']
      stylesheets:
        files: '<%= paths.stylesheets %>**/*.{less,css}'
        tasks: ['stylesheets', 'jade']
      scripts:
        files: '<%= paths.scripts %>**/*.{js,coffee,coffee.md,litcoffee}'
        tasks: ['scripts', 'jade']

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-cssmin'
  grunt.loadNpmTasks 'grunt-contrib-imagemin'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-less'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-text-replace'
  grunt.registerTask 'stylesheets', ['less', 'copy:css', 'copy:dist',
    'replace:css', 'cssmin']
  grunt.registerTask 'scripts', ['coffee', 'copy:js', 'uglify:build',
    'uglify:dist']
  grunt.registerTask 'images', ['imagemin', 'copy:images']
  grunt.registerTask 'default', ['images', 'stylesheets', 'scripts', 'jade']

