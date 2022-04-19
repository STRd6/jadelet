describe "Styles", ->
  it "should be bound in the context of the object", ->
    template = makeTemplate """
      duder(@style)
    """

    model =
      style: ->
        @myStyle()
      myStyle: ->
        backgroundColor: "red"

    element = template(model)
    assert.equal element.style.backgroundColor, "red"

  it "should remove styles when observables change", ->
    template = makeTemplate """
      duder(@style)
    """

    model =
      style: Observable
        backgroundColor: "red"

    element = template(model)
    assert.equal element.style.backgroundColor, "red"

    model.style
      #@ts-ignore
      color: "green"
    assert.equal element.style.backgroundColor, ""
    assert.equal element.style.color, "green"

  it "should merge observable arrays of style mappings", ->
    template = makeTemplate """
      div(style=@styles)
    """

    model =
      styles: Observable [{
        lineHeight: "1.5em"
        height: "30px"
        width: "40px"
      }, {
        color: "green"
        lineHeight: null
        height: undefined
        width: "50px"
      }]

    element = template(model)

    assert.equal element.style.color, "green"
    assert.equal element.style.height, "30px"
    assert.equal element.style.lineHeight, ""
    assert.equal element.style.width, "50px"

  it "should work with plain style strings", ->
    template = makeTemplate """
      div(@style)
    """

    model =
      style: """
        background-color: orange;
        color: blue;
      """

    element = template(model)

    assert.equal element.style.color, "blue"
    assert.equal element.style.backgroundColor, "orange"

  it "should mix and match plain strings and objects", ->
    template = makeTemplate """
      div(style=@rekt style=@styleString style=@styleObject)
    """

    model =
      rekt:
        height: "20px"
        color: "green"

      styleString:  """
        background-color: orange;
        color: blue;
      """

      styleObject: ->
        color: "black"
        width: "50px"

    element = template(model)

    assert.equal element.style.backgroundColor, "orange"
    assert.equal element.style.color, "black"
    assert.equal element.style.height, "" # Got crushed when writing the string style
    assert.equal element.style.width, "50px"
