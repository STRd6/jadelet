assert = require "assert"

Hamlet = require "../source/main"

{Observable} = Hamlet

describe "Hamlet", ->
  it "should provide observable", ->
    assert Observable
