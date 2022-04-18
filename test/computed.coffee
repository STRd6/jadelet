describe "Computed", ->
  template = makeTemplate """
    div
      h2 @name
      input(value=@first)
      input(value=@last)
  """

  it "should compute automatically with the correct scope", ->
    model =
      name: ->
        @first() + " " + @last()
      first: Observable("Mr.")
      last: Observable("Doberman")

    element = template(model)

    assert.equal element.querySelector("h2")?.textContent, "Mr. Doberman"

  it "should work on special bindings", ->
    template = makeTemplate """
      input(type='checkbox' checked=@checked)
    """
    model =
      checked: ->
        @name() is "Duder"
      name: Observable "Mang"

    element = template(model)

    assert.equal element.checked, false
    model.name "Duder"
    assert.equal element.checked, true
