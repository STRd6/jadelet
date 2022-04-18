describe "register", ->
  it "should register", ->
    require "../register"

    T = require "./samples/simple_class"
    assert T()
