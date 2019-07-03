describe "SELECT", ->
  describe "with an array of basic types for options", ->
    template = makeTemplate """
      select(@value @options)
    """
    it "should generate options", ->
      model =
        options: [1, 2, 3]
        value: 2
      select = template(model)

      assert.equal select.querySelectorAll("option").length, model.options.length

    it "should have it's value set", ->
      model =
        options: [1, 2, 3]
        value: 2
      select = template(model)

      assert.equal select.value, model.value

    it "should pass the option to the value binding on a change event", (done) ->
      model =
        options: [1, 2, 3]
        value: Observable(1)

      model.value.observe (value) ->
        # NOTE: The value is a memebr of the options array
        assert typeof value is "number"
        assert.equal value, 3
        done()

      select = template(model)

      # NOTE: To simulate a selection by choosing value you must pass a string
      select.value = "3"
      assert.equal select.value, "3"
      select.onchange()

  it "should get the correct value when another bound input changes", ->
    template = makeTemplate """
      div
        select(@value @options)
        input(@value)
    """
    model =
      options: [1, 2, 3]
      value: Observable 2

    element = template(model)

    input = element.querySelector("input")
    select = element.querySelector("select")

    input.value = "3"
    input.oninput()

    assert.equal model.value(), 3

    assert.equal select.value, 3
    model.value 1
    assert.equal select.value, 1

  describe "with an array of objects for options", ->
    template = makeTemplate """
      select(@value @options)
    """
    options = [
        {name: "yolo", value: "badical"}
        {name: "wat", value: "noice"}
      ]
    model =
      options: options
      value: options[0]

    it "should generate options", ->
      select = template(model)
      assert.equal select.querySelectorAll("option").length, model.options.length

    it "option names should be the name property of the object", ->
      select = template(model)

      names = Array::map.call select.querySelectorAll("option"), (o) -> o.text
      names.forEach (name, i) ->
        assert.equal name, model.options[i].name

    it "option values should be the value property of the object", ->
      select = template(model)

      values = Array::map.call select.querySelectorAll("option"), (o) -> o.value
      values.forEach (value, i) ->
        assert.equal value, model.options[i].value

    it "should have it's value set", ->
      select = template(model)
      # TODO: This isn't a great check
      assert.equal select._value, model.value

    it "should trigger a call to value binding when changing", (done) ->
      model =
        options: options

      model.value = Observable options[0], model
      model.value.observe (v) ->
        assert v.name is "wat"
        done()

      select = template(model)
      # Simulate a selection
      select.value = "noice"
      select.onchange()

  describe "An observable array of objects without value properties", ->
    template = makeTemplate """
      select(@value @options)
    """

    options = Observable [
      {name: "foo"}
      {name: "bar"}
      {name: "baz"}
    ]

    model =
      options: Observable options
      value: Observable options[0]

    it "should update the selected item when the model changes and the options don't have value properties", ->
      select = template(model)
      assert.equal select.selectedIndex, 0
      model.value model.options.get(1)
      assert.equal select.selectedIndex, 1


  describe "with objects that have an observable name property", ->
    template = makeTemplate """
      select(@value @options)
    """

    it "should observe the name as the text of the value options", ->
      options = Observable [
        {name: Observable("Napoleon"), date: "1850 AD"}
        {name: Observable("Barrack"), date: "1995 AD"}
      ]
      model =
        options: options
        value: options.get(0)

      select = template(model)
      optionElements = select.querySelectorAll("option")

      assert.equal optionElements[0].textContent, "Napoleon"
      options.get(0).name("Yolo")
      assert.equal optionElements[0].textContent, "Yolo"

  describe "with objects that have an observable value property", ->
    template = makeTemplate """
      select(@value @options)
    """
    it "should observe the value as the value of the value options", ->
      options = Observable [
        {name: Observable("Napoleon"), value: Observable("1850 AD")}
        {name: Observable("Barrack"), value: Observable("1995 AD")}
      ]
      model =
        options: options
        value: options.get(0)

      select = template(model)

      assert.equal select.value, "1850 AD"
      options.get(0).value "YOLO"
      assert.equal select.value, "YOLO"

  describe "with an observable array for options", ->
    template = makeTemplate """
      select(@value @options)
    """
    it "should add options added to the observable array", ->
      options = Observable [
        {name: "Napoleon", date: "1850 AD"}
        {name: "Barrack", date: "1995 AD"}
      ]
      model =
        options: options
        value: options.get(0)

      select = template(model)

      assert.equal select.querySelectorAll("option").length, 2
      options.push name: "Test", date: "2014 AD"
      assert.equal select.querySelectorAll("option").length, 3

    it "should remove options removed from the observable array", ->
      options = Observable [
        {name: "Napoleon", date: "1850 AD"}
        {name: "Barrack", date: "1995 AD"}
      ]
      model =
        options: options
        value: options.get(0)

      select = template(model)

      assert.equal select.querySelectorAll("option").length, 2
      options.remove options.get(0)
      assert.equal select.querySelectorAll("option").length, 1

    it "should have it's value set", ->
      options = Observable [
        {name: "Napoleon", date: "1850 AD"}
        {name: "Barrack", date: "1995 AD"}
      ]
      model =
        options: options
        value: options.get(0)

      select = template(model)
      # TODO: This isn't a great check
      assert.equal select._value, model.value

  describe "with an object for options", ->
    template = makeTemplate """
      select(@value @options)
    """

    it "should have an option for each key", ->
      options = Observable
        nap: "Napoleon"
        bar: "Barrack"

      model =
        options: options
        value: "bar"

      select = template model
      assert.equal select.value, "bar"

    it "should add options added to the observable object", ->
      options = Observable
        nap: "Napoleon"
        bar: "Barrack"

      model =
        options: options
        value: "bar"

      select = template(model)

      assert.equal select.querySelectorAll("option").length, 2
      options Object.assign {}, options(), {test: "Test"}
      assert.equal select.querySelectorAll("option").length, 3

    it "should remove options removed from the observable object", ->
      options = Observable
        nap: "Napoleon"
        bar: "Barrack"

      model =
        options: options
        value: "bar"

      select = template(model)

      assert.equal select.querySelectorAll("option").length, 2
      delete options().bar
      options Object.assign {}, options()
      assert.equal select.querySelectorAll("option").length, 1

    it "should observe the value as the value of the value options", ->
      options = Observable
        nap: Observable "Napoleon"
        bar: Observable "Barrack"

      model =
        options: options
        value: "bar"

      select = template model
      optionElements = select.querySelectorAll("option")

      assert.equal optionElements[1].textContent, "Barrack"
      options().bar "YOLO"
      assert.equal optionElements[1].textContent, "YOLO"
