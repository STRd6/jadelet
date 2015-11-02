describe "ids", ->
  it "should work with simple cases", ->
    template = makeTemplate """
      %h1#rad
    """
    behave template({}), ->
      assert.equal all("#rad").length, 1

  it "should be ok if undefined", ->
    template = makeTemplate """
      %h1(id=undefined)
    """
    behave template({}), ->
      assert true

  it "should use the last valid id when multiple exist", ->
    template = makeTemplate """
      %h1#rad(id="cool")
    """

    behave template({}), ->
      assert.equal all("#cool").length, 1

  it "should update the id if it's observable", ->
    template = makeTemplate """
      %h1(@id)
    """

    model =
      id: Observable "cool"

    behave template(model), ->
      assert.equal all("#cool").length, 1
      assert.equal all("#wat").length, 0
      model.id "wat"
      assert.equal all("#cool").length, 0
      assert.equal all("#wat").length, 1

  it "should update the last existing id if mixing literals and observables", ->
    template = makeTemplate """
      %h1#wat(@id id=@other)
    """

    model =
      id: Observable "cool"
      other: Observable "other"

    behave template(model), ->
      assert.equal all("#other").length, 1
      assert.equal all("#wat").length, 0
      assert.equal all("#cool").length, 0
      model.other null
      assert.equal all("#cool").length, 1
      assert.equal all("#other").length, 0
      model.id null
      assert.equal all("#wat").length, 1

  it "should be bound in the context of the object", ->
    template = makeTemplate """
      .duder(@id)
    """

    model =
      id: ->
        @myId()
      myId: ->
        "hats"

    behave template(model), ->
      assert.equal all("#hats").length, 1
