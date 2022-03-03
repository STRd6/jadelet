describe "Memory usage", ->

  if global.gc
    usageTest = ->

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
        Jadelet.dispose(button)
        i += 1

      global.gc()
      finalMemoryUsage = process.memoryUsage().heapUsed

      # console.log finalMemoryUsage, initialMemoryUsage
      # There's a surprising amount of variability in this memory usage number, but this seems
      # to trigger it every time when the call to _dispose is removed, so it may be decent at
      # detecting leaks
      delta = finalMemoryUsage - initialMemoryUsage
      target = 20000
      assert delta < target, "Memory used #{delta} not < #{target}"

  it "should remain stable even after many iterations", usageTest
