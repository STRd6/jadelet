describe "Primitives", ->
  template = makeTemplate """
    div
      = @string
      = @boolean
      = @number
      = @array
  """

  it "should render correctly", ->
    model =
      string: "hey"
      boolean: true
      number: 5
      array: [1, true, "e"]

    element = template(model)
    assert.equal element.textContent, "heytrue51truee"
