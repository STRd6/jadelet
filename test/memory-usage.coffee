describe "Memory usage", ->
  it "should remain stable even after many iterations", ->

    global.gc()
    initialMemoryUsage = process.memoryUsage().heapUsed

    template = makeTemplate """
      button(@click class=@selected) Test
    """

    current = Observable null

    create = ->
      model =
        selected: ->
          "selected" if current() is model
        click: ->

      template model

    i = 0
    while i < 1000
      button = create()
      Runtime._dispose(button)
      i += 1

    global.gc()
    finalMemoryUsage = process.memoryUsage().heapUsed

    console.log finalMemoryUsage, initialMemoryUsage
    # There's a surprising amount of variability in this memory usage number, but this seems
    # to trigger it every time when the call to _dispose is removed, so it may be decent at
    # detecting leaks
    assert finalMemoryUsage - initialMemoryUsage < 10000
