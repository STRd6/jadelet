describe "efficiency", ->
  it "should not re-render sub elements when classes change", ->
    template = makeTemplate """
      .duder(@class)
        @subrender
    """

    count = 0

    model =
      class: Observable "something"
      subrender: ->
        count += 1

    element = template(model)
    assert.equal count, 1
    model.class "somethingElse"
    assert.equal count, 1
    assert element.classList.contains("somethingElse")

  it "should recompute siblings an appropriate amount of times", ->
    template = makeTemplate """
      div
        @item1
        @item2
        @item3
        @counter
    """

    count = 0
    model =
      item1: Observable "A"
      item2: Observable 5
      item3: Observable document.createElement "span"
      counter: ->
        count += 1

    template model

    assert.equal count, 1
    model.item1 "B"
    assert.equal count, 1
    model.item2.decrement()
    assert.equal count, 1
    model.item3 document.createElement "div"
    assert.equal count, 1

    assert.equal model.item1.listeners.length, 1
    assert.equal model.item2.listeners.length, 1
    assert.equal model.item3.listeners.length, 1


  it "should not re-render sub elements when attributes change", ->
    template = makeTemplate """
      .duder(@name)
        @subrender
    """

    count = 0

    model =
      name: Observable "something"
      subrender: ->
        count += 1

    element = template(model)
    assert.equal count, 1
    model.name "somethingElse"
    assert.equal count, 1
    assert.equal element.getAttribute("name"), "somethingElse"

  it "should not re-render sub elements when ids change", ->
    template = makeTemplate """
      .duder(@id)
        @subrender
    """

    count = 0

    model =
      id: Observable "something"
      subrender: ->
        count += 1

    element = template(model)
    assert.equal count, 1
    model.id "somethingElse"
    assert.equal count, 1
    assert.equal element.id, "somethingElse"

  it "should render the template once when the observable changes", ->
    template = makeTemplate """
      .awesome
        @renderedOuter
        ul
          @renderedTemplate
          @itemElements
    """

    itemTemplate = makeTemplate """
      .item
        @n
        @renderedItem
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
      itemElements: ->
        renderedItem = @renderedItem

        @items.map (n) ->
          itemTemplate
            n: n
            renderedItem: renderedItem
      renderedOuter: ->
        oCount += 1
      renderedTemplate: ->
        tCount += 1
      renderedItem: ->
        iCount += 1

    element = template(model)

    assert.equal oCount, 1
    assert.equal tCount, 1
    assert.equal iCount, 3

    model.items.push "D"
    assert.equal oCount, 1
    assert.equal tCount, 1
    assert.equal iCount, 7

    model.items.push "E"
    assert.equal oCount, 1
    assert.equal tCount, 1
    assert.equal iCount, 12

  it "shouldn't leak all over the place", ->
    template = makeTemplate """
      items
        @itemElements

    """

    buttonTemplate = makeTemplate """
      button(@click class=@active) @text
    """

    activeItem = Observable null

    Item = (value="yo") ->
      self =
        text: Observable value
        click: ->
        active: ->
          self is activeItem()

    items = Observable [
      Item()
      Item()
      Item()
    ]

    model =
      items: items
      itemElements: ->
        @items.map (item) ->
          buttonTemplate item

    element = template(model)

    assert.equal items.listeners.length, 1
    assert.equal activeItem.listeners.length, 3
    items.push Item()
    assert.equal items.listeners.length, 1
    assert.equal activeItem.listeners.length, 4
    items.push Item()
    assert.equal items.listeners.length, 1
    assert.equal activeItem.listeners.length, 5
    items.pop()
    assert.equal items.listeners.length, 1
    assert.equal activeItem.listeners.length, 4
    items.pop()
    items.pop()
    items.pop()
    assert.equal activeItem.listeners.length, 1
    items.pop()
    assert.equal activeItem.listeners.length, 0
