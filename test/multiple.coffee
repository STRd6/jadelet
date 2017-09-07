describe "multiple bindings", ->
  template = makeTemplate """
    div
      input(type="text" value=@value)
      select(value=@value options=[1..@max])
      hr
      input(type="range" value=@value min="1" max=@max)
      hr
      progress(value=@value max=@max)
  """
  model =
    max: 10
    value: Observable 5

  it "should be initialized to the right values", ->
    element = template(model)

    select = element.querySelector("select")

    ["text", "range"].forEach (type) ->
      assert.equal element.querySelector("input[type='#{type}']").value, 5

    assert.equal element.querySelector("progress").value, 5
    assert.equal select.value, 5

    [2, 7, 3, 8].forEach (value) ->
      # NOTE: This is how we're simulating an onchange event
      select.selectedIndex = value - 1
      select.onchange()

      assert.equal select.value, value

      ["text", "range"].forEach (type) ->
        assert.equal element.querySelector("input[type='#{type}']").value, value

      assert.equal element.querySelector("progress").value, value
