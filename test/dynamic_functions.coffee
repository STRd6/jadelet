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

      element = template(model)
      assert.equal element.querySelectorAll(".cool").length, 1
      assert.equal element.querySelectorAll(".uncool").length, 0

      model.cool false

      assert.equal element.querySelectorAll(".cool").length, 0
      assert.equal element.querySelectorAll(".uncool").length, 1
