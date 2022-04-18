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

  it "shouldn't bind on- events", ->
    template = makeTemplate """
      button(onclick=@click)
    """

    result = null

    model =
      name: Observable "Foobert"
      click: ->
        result = @name()

    button = template(model)
    # Function was called to seet the "onclick" attribute
    assert.equal result, "Foobert"
    assert.equal button.getAttribute("onclick"), "Foobert"

  it "should skip non-functions when binding events", ->
    template = makeTemplate """
      button(@mouseenter @mouseleave)
    """

    model =
      mouseenter: "wut"
      mouseleave: "lol"

    button = template(model)

    dispatch button, "mouseenter"
    dispatch button, "mouseleave"

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
    dispatch button, "mouseenter"
    assert.equal result, 1
    dispatch button, "mouseleave"
    assert.equal result, 2

  it "shoud handle all touch events", ->
    template = makeTemplate """
      canvas(@touchstart @touchmove @touchend @touchcancel)
    """

    called = 0
    eventFn = ->
      called += 1

    model =
      touchcancel: eventFn
      touchstart: eventFn
      touchmove: eventFn
      touchend: eventFn

    canvas = template(model)
    assert.equal called, 0

    dispatch canvas, "touchstart"
    assert.equal called, 1

    dispatch canvas, "touchmove"
    assert.equal called, 2

    dispatch canvas, "touchend"
    assert.equal called, 3

    dispatch canvas, "touchcancel"
    assert.equal called, 4

  it "shoud handle all animation events", ->
    template = makeTemplate """
      div(@animationstart @animationiteration @animationend @transitionend)
    """

    called = 0
    eventFn = ->
      called += 1

    model =
      animationstart: eventFn
      animationend: eventFn
      animationiteration: eventFn
      transitionend: eventFn

    canvas = template(model)
    assert.equal called, 0

    dispatch canvas, "animationstart"
    assert.equal called, 1

    dispatch canvas, "animationiteration"
    assert.equal called, 2

    dispatch canvas, "animationend"
    assert.equal called, 3

    dispatch canvas, "transitionend"
    assert.equal called, 4
