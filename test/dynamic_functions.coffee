describe "dynamic functions", ->
  describe "if statements", ->
    it "should rerender when observable conditionals change", ->
      template = makeTemplate """
        div
          - if @cool() #NOTE: Function must be called to autobind
            .cool
          - else
            .uncool
      """

      model =
        cool: Observable true

      behave template(model), ->
        assert.equal all(".cool").length, 1
        assert.equal all(".uncool").length, 0

        model.cool false

        assert.equal all(".cool").length, 0
        assert.equal all(".uncool").length, 1
