describe "register", ->
  it "shouldn't be able to require .jadelet files until we register", ->
    assert.throws ->
      require "./templates/hello"

  it "should require .jadelet files after registering", ->
    require("../source/register")

    HelloTemplate = require "./templates/hello"
    element = HelloTemplate()

    assert.equal element.nodeName, "H1"

  it "should display parse errors"
