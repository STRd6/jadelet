describe "Checkbox", ->
  template = makeTemplate """
    input(type='checkbox' checked=@checked)
  """

  describe "simple boolean checked value", ->
    it "should be checked", ->
      model =
        checked: true

      behave template(model), ->
        assert.equal Q("input").checked, true

    it "should not be checked", ->
      model =
        checked: false

      behave template(model), ->
        assert.equal Q("input").checked, false

  describe "observable checked attribute", ->
    it "should track changes in the observable", ->
      model =
        checked: Observable false

      behave template(model), ->
        assert.equal Q("input").checked, false, "Should not be checked"
        model.checked true
        assert.equal Q("input").checked, true, "Should be checked"
        model.checked false
        assert.equal Q("input").checked, false, "Should not be checked again"
