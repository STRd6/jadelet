describe "Attributes", ->
  describe "@", ->
    it "should bind to the property with the same name", (done) ->
      template = makeTemplate """
        button(@click) Test
      """

      model =
        click: ->
          done()

      button = template(model)
      button.click()

    it "should work with multiple attributes", ->
      template = makeTemplate """
        button(before="low" @type middle="mid" @yolo after="hi") Test
      """

      model =
        type: "submit"
        yolo: "Hello"

      button = template(model)
      assert.equal button.getAttribute("type"), "submit"
      assert.equal button.getAttribute("yolo"), "Hello"

    it "shoud not be present when false or undefined", ->
      template = makeTemplate """
        button(@disabled) Test
      """

      model =
        disabled: Observable false

      button = template(model)
      assert.equal button.getAttribute("disabled"), undefined

      model.disabled true
      assert.equal button.getAttribute("disabled"), "true"
