CoffeeScript = require "coffee-script"
{compile} = require "hamlet-compiler"

fs = require "fs"

compileRaw = (raw) ->
  compile raw,
    compiler: CoffeeScript
    exports: "module.exports"
    mode: "jade" # TOOD: -> jadelet
    runtime: "require('#{__dirname}/runtime')"

# Hook require to .jadelet extension
require.extensions[".jadelet"] = (module, filename) ->
  raw = fs.readFileSync filename, 'utf8'

  src = compileRaw raw

  module._compile src, filename

# Browserify transform
through = require "through2"

isJadelet = (filename) ->
  filename.match /\.jadelet$/

module.exports = (filename, options={}) ->
  return through() unless isJadelet(filename)

  chunks = []
  transform = (chunk, encoding, callback) ->
    chunks.push(chunk)
    callback()

  flush = (callback) ->
    stream = this
    raw = Buffer.concat(chunks).toString()

    try
      source = compileRaw raw

      stream.push(source)
      callback(null)
    catch error
      callback(error)

  return through(transform, flush)
