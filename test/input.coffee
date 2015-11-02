describe "input", ->
  template = makeTemplate """
    %input(type="text" @value)
  """


  it "should maintain caret position"
  # PENDING
  ->
    model =
      value: Observable "yolo"

    behave template(model), ->
      input = Q("input")
      input.focus()
      input.selectionStart = 2

      assert.equal input.selectionStart, 2

      input.value = "yo2lo"
      # input.selectionStart = 3

      assert.equal input.selectionStart, 3

      input.onchange()

      assert.equal input.selectionStart, 3
