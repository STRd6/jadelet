assert = require "assert"

Hamlet = require "../dist/main"

{Observable} = Hamlet

describe "Hamlet", ->
  it "should provide observable", ->
    assert Observable
