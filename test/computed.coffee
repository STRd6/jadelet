describe "Computed", ->
  template = makeTemplate """
    %div
      %h2= @name
      %input(value=@first)
      %input(value=@last)
  """

  it "should compute automatically with the correct scope", ->
    model =
      name: ->
        @first() + " " + @last()
      first: Observable("Mr.")
      last: Observable("Doberman")

    behave template(model), ->
      assert.equal Q("h2").textContent, "Mr. Doberman"

  it "should work on special bindings", ->
    template = makeTemplate """
      %input(type='checkbox' checked=@checked)
    """
    model =
      checked: ->
        @name() is "Duder"
      name: Observable "Mang"

    behave template(model), ->
      assert.equal Q("input").checked, false

      model.name "Duder"

      assert.equal Q("input").checked, true

  it "should have the correct context in each", ->
    template = makeTemplate """
      .items
        - @items.each (item) ->
          .item
            .name= @name
            %input(type='checkbox' checked=@checked)
    """

    letter = Observable "A"
    checked = ->
      @name().indexOf(letter()) is 0

    model =
      items: Observable [
        {name: Observable("Andrew"), checked: checked}
        {name: Observable("Benjamin"), checked: checked}
      ]
      letter: letter

    behave template(model), ->
      assert.equal all("input")[0].checked, true
      assert.equal all("input")[1].checked, false

      letter "B"

      assert.equal all("input")[0].checked, false
      assert.equal all("input")[1].checked, true
