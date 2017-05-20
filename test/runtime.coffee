assert = require "assert"

Jadelet = require "../source/runtime"

describe "Jadelet Runtime", ->
  it "should be a function that produces a document fragment from a compiled template", ->
    assert typeof Jadelet is "function"

  it "should provide Observable", ->
    assert Jadelet.Observable
