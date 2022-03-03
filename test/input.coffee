describe "input", ->
  template = makeTemplate """
    input(type="text" @value)
  """

  it "should maintain caret position"
  # PENDING
  ->
    model =
      value: Observable "yolo"

    input = template(model)

    input.focus()
    input.selectionStart = 2

    assert.equal input.selectionStart, 2

    input.value = "yo2lo"
    # input.selectionStart = 3

    assert.equal input.selectionStart, 3

    input.onchange()

    assert.equal input.selectionStart, 3

  it "should start with given vaule", ->
    T = Jadelet.exec """
      input(type="text" value="hello")
    """

    el = T()
    assert.equal el.value, "hello"
