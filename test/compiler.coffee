assert = require('assert')
fs = require('fs')

{compile} = require('../')

compileDirectory = (directory, mode) ->
  fs.readdirSync(directory).forEach (file) ->
    if file.match /\.jadelet$/
      data = fs.readFileSync "#{directory}/#{file}", "utf8"

      it "compiles #{file}", ->
        data = compile data

        assert data

describe 'Compiler', ->
  describe 'samples', ->
    compileDirectory "test/samples"

  describe "exports", ->
    it "defaults to module.exports", ->
      compiled = compile "h1"
      assert compiled.match(/^module\.exports/)

    it "defaults to require('jadelet')", ->
      compiled = compile "h1"
      assert compiled.match(/require\('jadelet'\)/)
