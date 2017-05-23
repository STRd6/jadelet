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
