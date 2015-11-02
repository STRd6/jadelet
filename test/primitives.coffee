describe "Primitives", ->
  template = makeTemplate """
    %div
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

    behave template(model), ->
      assert.equal Q("div").textContent, "heytrue51truee"
