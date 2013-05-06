### global module:false ###
fs = require 'fs'

module.exports = (grunt) ->
  defaults = grunt.file.readJSON('defaults.json')
  locals = if fs.existsSync './locals.json' then grunt.file.readJSON('locals.json') else {}
  settings = extend {}, defaults, locals
  ENV = process.env['NODE_ENV'] or settings['ENV'] or 'development'

  paths =
    temp: 'temp/'
    dist: 'dist/'
    views: 'views/'
    assets: settings.ASSET_ROOT
    components: '<%= paths.assets %>components/'
    scripts: '<%= paths.assets %>scripts/'
    stylesheets: '<%= paths.assets %>stylesheets/'
    images: '<%= paths.assets %>images/'

  assetHelper = asset paths.dist + settings.ASSET_ROOT,
    settings.ASSET_URL, settings.ASSET_CACHE_BUSTING, ENV

  grunt.initConfig
    paths: paths
    imagemin:
      dist:
        options:
          optimizationLevel: 3
        files: [
          {
            expand: true
            cwd: '<%= paths.images %>'
            src: '**/*.{png,jpg,jpeg}'
            dest: '<%= paths.dist %><%= paths.images %>'
          }
        ]

    coffee:
      build:
        files: [
          {
            expand: true
            cwd: '<%= paths.scripts %>'
            src: '**/*.coffee'
            dest: '<%= paths.temp %><%= paths.scripts %>'
            rename: (dest, src) ->
              dest + src.split('.').slice(0,-1).join('.') + '.js'
          }
        ]

    less:
      build:
        options:
          paths: ['<%= paths.components %>', '<%= paths.stylesheets %>']
        files:
          '<%= paths.temp %><%= paths.stylesheets %>style.css':
            '<%= paths.stylesheets %>style.less'

    copy:
      js:
        files: [
          {
            expand: true
            cwd: '<%= paths.scripts %>'
            src: '**/*.js'
            dest: '<%= paths.temp %><%= paths.scripts %>'
          }
          {
            '<%= paths.dist %><%= paths.scripts %>respond.min.js':
              '<%= paths.components %>respond/respond.min.js'
          }
        ]
      css:
        files: [
          {
            expand: true
            cwd: '<%= paths.stylesheets %>'
            src: '**/*.css'
            dest: '<%= paths.temp %><%= paths.stylesheets %>'
          }
        ]
      images:
        files: [
          {
            expand: true
            cwd: '<%= paths.components %>bootstrap/img'
            src: '*.png'
            dest: '<%= paths.dist%><%= paths.images %>'
          }
          {
          expand: true
          cwd: '<%= paths.images %>'
          src: '*.{gif,ico}'
          dest: '<%= paths.dist%><%= paths.images %>'
          }
        ]
      dist:
        files:
          '<%= paths.dist %><%= paths.stylesheets %>style.css':
            '<%= paths.temp %><%= paths.stylesheets %>style.css'

    cssmin:
      dist:
        files:
          '<%= paths.dist %><%= paths.stylesheets %>style.min.css':
            '<%= paths.dist %><%= paths.stylesheets %>style.css'

    uglify:
      build:
        options:
          mangle: false
          compress: false
          beautify: true
        files:
          '<%= paths.dist %><%= paths.scripts %>bundle.js': [
            '<%= paths.components %>jquery/jquery.js'
            '<%= paths.components %>FitText.js/jquery.fittext.js'
            '<%= paths.temp %><%= paths.scripts %>utils.js'
            '<%= paths.temp %><%= paths.scripts %>video.js'
            '<%= paths.temp %><%= paths.scripts %>tracking.js'
            '<%= paths.temp %><%= paths.scripts %>app.js'
          ]
      dist:
        options:
          preserveComments: 'some'
        files:
          '<%= paths.dist %><%= paths.scripts %>bundle.min.js': '<%= paths.dist %><%= paths.scripts %>bundle.js'

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
            dest: '<%= paths.dist %><%= paths.views %>'
            ext: '.html'
          }
        ]

    replace:
      css:
        src: '<%= paths.dist %><%= paths.stylesheets %>style.css'
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
  grunt.registerTask 'stylesheets', ['less', 'copy:css', 'copy:dist', 'replace:css', 'cssmin']
  grunt.registerTask 'scripts', ['coffee', 'copy:js', 'uglify:build', 'uglify:dist']
  grunt.registerTask 'images', ['imagemin', 'copy:images']
  grunt.registerTask 'default', ['images', 'stylesheets', 'scripts', 'jade']

