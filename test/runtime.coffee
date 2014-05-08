assert = require "assert"

require "../source/runtime"

describe "Hamlet Runtime", ->
  it "should be a global function that produces a document fragment from a compiled template", ->
    assert typeof Hamlet is "function"

  it "should provide Observable", ->
    assert Hamlet.Observable
