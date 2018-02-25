assert = require('assert')
fs = require('fs')
CoffeeScript = require "coffeescript"

jadeletCompiler = require('../dist/compiler')

compile = (source, opts={}) ->
  opts.compiler ?= CoffeeScript
  opts.mode ?= "jade"

  jadeletCompiler source, opts

compileDirectory = (directory, mode) ->
  fs.readdirSync(directory).forEach (file) ->
    if file.match /\.jade(let)?$/
      data = fs.readFileSync "#{directory}/#{file}", "UTF-8"

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

    it "is removable by passing false", ->
      compiled = compile "h1", exports: false

      assert compiled.match(/^\(function\(data\) \{/)
