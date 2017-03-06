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

    behave template(model), ->
      assert Q(".hats")

  it "should handle observable arrays", ->
    template = makeTemplate """
      div(class=@classes)
    """

    model =
      classes: Observable ["a", "b"]

    behave template(model), ->
      assert Q(".a.b")

  it "should merge with literal classes", ->
    template = makeTemplate """
      .duder(class=@classes)
    """

    model =
      classes: Observable ["a", "b"]

    behave template(model), ->
      assert Q(".duder.a.b")

  it "should not write `undefined` to the class", ->
    template = makeTemplate """
      .duder(class=@undefined)
    """

    model =
      undefined: undefined

    behave template(model), ->
      assert !Q(".undefined")
