describe "Checkbox", ->
  template = makeTemplate """
    input(type='checkbox' checked=@checked)
  """

  it "should be checked", ->
    model =
      checked: true

    input = template(model)
    assert.equal input.checked, true

  it "should not be checked", ->
    model =
      checked: false

    input = template(model)
    assert.equal input.checked, false

  it "should track changes in the observable", ->
    model =
      checked: Observable false

    input = template(model)

    assert.equal input.checked, false, "Should not be checked"
    model.checked true
    assert.equal input.checked, true, "Should be checked"
    model.checked false
    assert.equal input.checked, false, "Should not be checked again"

    input.checked = true
    input.onchange()
    assert.equal model.checked(), true, "Value of observable should be checked when input changes"

    input.checked = false
    input.onchange()
    assert.equal model.checked(), false, "Value of observable should be unchecked when input changes"
