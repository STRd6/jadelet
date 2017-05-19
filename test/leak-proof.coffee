describe "Jadelet", ->
  it "shouldn't leak all over the place", ->
    template = makeTemplate """
      items
        - @items.forEach (item) ->
          button(click=item.click class=item.active)= item.text
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

    behave template(model), ->
      assert.equal items.listeners.length, 1
      assert.equal activeItem.listeners.length, 3
      console.log Runtime._elementCleaners
      items.push Item()
      assert.equal items.listeners.length, 1
      assert.equal activeItem.listeners.length, 4
      items.push Item()
      assert.equal items.listeners.length, 1
      assert.equal activeItem.listeners.length, 5
