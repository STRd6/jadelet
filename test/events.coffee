describe "Events", ->
  it "should bind click to the object context", ->
    template = makeTemplate """
      button(click=@click)
    """

    result = null

    model =
      name: Observable "Foobert"
      click: ->
        result = @name()

    button = template(model)
    assert.equal result, null
    button.click()
    assert.equal result, "Foobert"

  it "should bind on- events the same way", ->
    template = makeTemplate """
      button(onclick=@click)
    """

    result = null

    model =
      name: Observable "Foobert"
      click: ->
        result = @name()

    button = template(model)
    assert.equal result, null
    button.click()
    assert.equal result, "Foobert"

  it "should bind mouseenter and mouseleave events", ->
    template = makeTemplate """
      button(@mouseenter @mouseleave)
    """

    result = null

    model =
      mouseenter: ->
        result = 1
      mouseleave: ->
        result = 2

    button = template(model)

    assert.equal result, null
    dispatchEvent button, "mouseenter"
    assert.equal result, 1
    dispatchEvent button, "mouseleave"
    assert.equal result, 2

  it "should work with touch events"
