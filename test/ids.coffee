describe "ids", ->
  it "should work with simple cases", ->
    template = makeTemplate """
      h1#rad
    """
    element = template()

    assert.equal element.id, "rad"

  it "should throw on arbitrary text", ->
    assert.throws ->
      makeTemplate """
        h1(id=noquotes)
      """

  it "should use the last valid id when multiple exist", ->
    template = makeTemplate """
      h1#rad(id="cool")
    """

    element = template()
    assert.equal element.id, "cool"

  it "should use the last id when given an array", ->
    template = makeTemplate """
      h1(@id)
    """

    element = template
      id: ["one", "two"]
    assert.equal element.id, "two"

  it "should not have an id when given an empty array", ->
    template = makeTemplate """
      h1(@id)
    """

    element = template
      id: []
    assert.equal element.getAttribute('id'), null

  it "should update the id if it's observable", ->
    template = makeTemplate """
      h1(@id)
    """

    model =
      id: Observable "cool"

    element = template(model)
    assert.equal element.id, "cool"
    model.id "wat"
    assert.equal element.id, "wat"

  it "should update the last existing id if mixing literals and observables", ->
    template = makeTemplate """
      h1#wat(@id id=@other)
    """

    model =
      id: Observable "cool"
      other: Observable "other"

    element = template(model)
    assert.equal element.id, "other"
    #@ts-expect-error TODO: Update observable library to allow nullable
    model.other null
    assert.equal element.id, "cool"
    #@ts-expect-error TODO: Update observable library to allow nullable
    model.id null
    assert.equal element.id, "wat"

  it "should be bound in the context of the object", ->
    template = makeTemplate """
      .duder(@id)
    """

    model =
      id: ->
        @myId()
      myId: ->
        "hats"

    element = template(model)
    assert.equal element.id, "hats"
