describe "Classes", ->
  it "should be bound in the context of the object", ->
    template = makeTemplate """
      .duder(class=@classes)
    """

    model =
      classes: ->
        @myClass()
      myClass: ->
        "hats"

    element = template(model)
    assert element.classList.contains "hats"

  it "should handle observable arrays", ->
    template = makeTemplate """
      div(class=@classes)
    """

    model =
      classes: Observable ["a", "b"]

    element = template(model)

    assert element.classList.contains "a"
    assert element.classList.contains "b"

    model.classes []

    assert.equal element.getAttribute("class"), null

  it "should merge with literal classes", ->
    template = makeTemplate """
      .duder(class=@classes)
    """

    model =
      classes: Observable ["a", "b"]

    element = template(model)

    assert element.classList.contains "a"
    assert element.classList.contains "b"
    assert element.classList.contains "duder"

  it "should not write `undefined` to the class", ->
    template = makeTemplate """
      .duder(class=@undefined)
    """

    model =
      undefined: undefined

    element = template(model)

    assert !element.classList.contains("undefined")
