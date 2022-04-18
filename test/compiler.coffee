assert = require('assert')
fs = require('fs')

# TODO: prefer destructuring when CoffeeSense improves
compile = Jadelet.compile

#
###* @param directory {string} ###
compileDirectory = (directory) ->
  fs.readdirSync(directory).forEach (file) ->
    if file.match /\.jadelet$/
      it "compiles #{file}", ->
        data = fs.readFileSync "#{directory}/#{file}", "utf8"
        assert compile data

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
