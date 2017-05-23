describe "Touch Events", ->
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

    dispatchEvent canvas, "touchstart"
    assert.equal called, 1

    dispatchEvent canvas, "touchmove"
    assert.equal called, 2

    dispatchEvent canvas, "touchend"
    assert.equal called, 3

    dispatchEvent canvas, "touchcancel"
    assert.equal called, 4
