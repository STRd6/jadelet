describe "@attributes", ->
  it "should bind to the property with the same name", (done) ->
    template = makeTemplate "%button(@click) Test"

    model =
      click: ->
        done()

    behave template(model), ->
      Q("button").click()

  it "should work with multiple attributes", ->
    template = makeTemplate '%button(before="low" @type middle="mid" @yolo after="hi") Test'

    model =
      type: "submit"
      yolo: "Hello"

    behave template(model), ->
      assert.equal Q("button").getAttribute("type"), "submit"
      assert.equal Q("button").getAttribute("yolo"), "Hello"
