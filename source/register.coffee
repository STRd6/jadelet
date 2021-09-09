{compile} = require "jadelet/dist/jadelet"

fs = require "fs"

compileRaw = (raw) ->
  compile raw,
    exports: "module.exports"
    runtime: "require('jadelet')"

# Hook require to .jadelet extension
Module._extensions[".jadelet"] = (module, filename) ->
  raw = fs.readFileSync filename, 'utf8'

  src = compileRaw raw

  module._compile src, filename

# Browserify transform
{ Transform } = require('readable-stream')

isJadelet = (filename) ->
  filename.match(/\.jadelet$/) or filename.match(/\.jade$/)

module.exports = (filename, options={}) ->
  return new Transform() unless isJadelet(filename)

  chunks = []
  return new Transform
    transform: (chunk, encoding, callback) ->
      chunks.push(chunk)
      callback()

    flush: (callback) ->
      stream = this
      raw = Buffer.concat(chunks).toString()

      try
        source = compileRaw raw

        stream.push(source)
        callback(null)
      catch error
        callback(error)
