assert = require "assert"

Jadelet = require "../source/runtime"

describe "Jadelet Runtime", ->
  it "should be a function that produces a document fragment from a compiled template", ->
    assert typeof Jadelet is "function"

  it "should provide Observable", ->
    assert Jadelet.Observable

  it "should throw an error on multiple root elements", ->
    template = makeTemplate """
      h1 yo
      p what's my information architecture lol
    """

    assert.throws ->
      template()
