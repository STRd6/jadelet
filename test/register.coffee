describe "register", ->
  it "should register", ->
    require "../register"

    #@ts-ignore
    T = require "./samples/simple_class"
    assert T()
