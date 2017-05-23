describe "Touch Events", ->
  it "shoud handle all touch events", ->
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
