assert = require('assert')
fs = require('fs')

{compile} = require('../dist/jadelet')

compileDirectory = (directory, mode) ->
  fs.readdirSync(directory).forEach (file) ->
    if file.match /\.jade(let)?$/
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
