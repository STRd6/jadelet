describe "real world cases", ->
  template = makeTemplate """
    .node
      - subtemplate = @subtemplate
      - @items.forEach ({items, key, value}) ->
        .row
          - if items
            = subtemplate items: items
          - else
            .item
              input.key(value=key)
              input.value(value=value)
  """

  it "should render fine", ->
    model =
      subtemplate: template
      items: Observable [
        {key: Observable("wat"), value: Observable("teh")}
        {key: Observable("duder"), value: Observable("yo")}
        {items: Observable([
          {key: Observable("yolo"), value: Observable("heyo")}
        ])}
      ]

    behave template(model), ->
      assert.equal Q(".key").value, "wat"
      assert.equal all(".node").length, 2
      assert.equal all(".key").length, 3

  it "should respond to changes in the observable array", ->
    model =
      subtemplate: template
      items: Observable [
        {key: Observable("wat"), value: Observable("teh")}
        {key: Observable("duder"), value: Observable("yo")}
        {items: Observable([
          {key: Observable("yolo"), value: Observable("heyo")}
        ])}
      ]

    behave template(model), ->
      model.items.push {key: Observable("newbie"), value: Observable("guh")}

      assert.equal Q(".key").value, "wat"
      assert.equal all(".node").length, 2
      assert.equal all(".key").length, 4

      model.items.push
        items: Observable [
          key: Observable("yolo"), value: Observable("heyo")
        ]

      assert.equal all(".node").length, 3
