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

    dispatchEvent canvas, "animationstart"
    assert.equal called, 1

    dispatchEvent canvas, "animationiteration"
    assert.equal called, 2

    dispatchEvent canvas, "animationend"
    assert.equal called, 3

    dispatchEvent canvas, "transitionend"
    assert.equal called, 4
