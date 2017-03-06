describe "Events", ->

  it "click should be bound to the object context", ->
    template = makeTemplate """
      button(click=@click)
    """

    result = null

    model =
      name: Observable "Foobert"
      click: ->
        result = @name()

    behave template(model), ->
      assert.equal result, null
      Q("button").click()
      assert.equal result, "Foobert"
