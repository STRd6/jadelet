describe "efficiency", ->
  it "should not re-render sub elements when classes change", ->
    template = makeTemplate """
      .duder(@class)
        - @subrender()
    """

    count = 0

    model =
      class: Observable "something"
      subrender: ->
        count += 1

    behave template(model), ->
      assert.equal count, 1
      model.class "somethingElse"
      assert.equal count, 1
      assert Q(".somethingElse")

  it "should not re-render sub elements when attributes change", ->
    template = makeTemplate """
      .duder(@name)
        - @subrender()
    """

    count = 0

    model =
      name: Observable "something"
      subrender: ->
        count += 1

    behave template(model), ->
      assert.equal count, 1
      model.name "somethingElse"
      assert.equal count, 1
      assert Q("[name=somethingElse]")

  it "should not re-render sub elements when ids change", ->
    template = makeTemplate """
      .duder(@id)
        - @subrender()
    """

    count = 0

    model =
      id: Observable "something"
      subrender: ->
        count += 1

    behave template(model), ->
      assert.equal count, 1
      model.id "somethingElse"
      assert.equal count, 1
      assert Q("#somethingElse")

  it "should render the template once when the observable changes", ->
    template = makeTemplate """
      .awesome
        - @renderedOuter()
        %ul
          - renderedItem = @renderedItem
          - @renderedTemplate()
          - @items.each (item) ->
            .item
            - renderedItem()
    """

    oCount = 0
    tCount = 0
    iCount = 0

    model =
      items: Observable [
        "A"
        "B"
        "C"
      ]
      renderedOuter: ->
        oCount += 1
      renderedTemplate: ->
        tCount += 1
      renderedItem: ->
        iCount += 1

    behave template(model), ->
      assert.equal oCount, 1
      assert.equal tCount, 1
      assert.equal iCount, 3

      model.items.push "D"
      assert.equal oCount, 1
      assert.equal tCount, 2
      assert.equal iCount, 7

      model.items.push "E"
      assert.equal oCount, 1
      assert.equal tCount, 3
      assert.equal iCount, 12
