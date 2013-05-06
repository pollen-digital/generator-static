crypto = require 'crypto'
fs = require 'fs'
path = require 'path'

exports.AssetManager = class AssetManager
  constructor: (@assetRoot, @assetURL, @hashed, @environment = 'development') ->
    @cache = {}

  injectPath: (assetPath, envSuffix) ->
    dirname = path.dirname assetPath
    basename = path.basename assetPath
    extname = path.extname basename
    noext = path.basename basename, extname
    suffix = if @environment is 'development' then '' else envSuffix
    path.join dirname, "#{noext}#{suffix}#{extname}"

  calculateMD5: (filePath) ->
    return '' if not fs.existsSync filePath
    md5 = crypto.createHash 'md5'
    contents = fs.readFileSync filePath
    md5.update(contents).digest 'hex'

  helper: ->
    func = (assetPath, envSuffix = '') ->
      fixedPath = @injectPath assetPath, envSuffix
      filePath = path.join @assetRoot, fixedPath
      return @cache[filePath] if @cache[filePath]?
      hash = if @hashed then @calculateMD5(filePath)[..7] else ''
      affix = if hash then "?rel=#{hash}" else ''
      @cache[filePath] = "#{@assetURL}#{fixedPath}#{affix}"
      @cache[filePath]
    func.bind @

extend = (args...) ->
  dest = args[0]
  return dest if not dest?
  args[1..].forEach (item) ->
    (dest[prop] = item[prop]) for prop of item
  dest
