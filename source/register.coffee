{compile} = require "../"
fs = require "fs"

getRootModule = (module) ->
  return module unless module.parent
  getRootModule module.parent

compileRaw = (raw, opts={}) ->
  compile raw,
    exports: opts.exports ? "module.exports"
    runtime: opts.runtime ? "require('jadelet')"

# Hook require to .jadelet extension
require.extensions[".jadelet"] = (module, filename) ->
  options = module.options or getRootModule(module).options

  raw = fs.readFileSync filename, 'utf8'
  src = compileRaw raw, options
  module._compile src, filename

# Browserify transform
{ Transform } = require('readable-stream')

module.exports = (filename, options={}) ->
  chunks = []
  return new Transform
    transform: (chunk, encoding, callback) ->
      chunks.push(chunk)
      callback()

    flush: (callback) ->
      raw = Buffer.concat(chunks).toString()

      try
        @push compileRaw raw, options
        callback(null)
      catch error
        callback(error)
