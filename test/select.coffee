describe "SELECT", ->
  OptionTemplate = makeTemplate """
    option(@value) @name
  """

  Option = (n) ->
    if typeof n is "object"
      OptionTemplate n
    else
      OptionTemplate
        name: n
        value: n

  describe "with an array of basic types for options", ->
    template = makeTemplate """
      select(@value)
        @options
    """

    it "should generate options", ->
      model =
        options: [1, 2, 3].map(Option)
        value: 2
      select = template(model)

      assert.equal select.querySelectorAll("option").length, model.options.length

    it "should have it's value set", ->
      model =
        options: [1, 2, 3].map(Option)
        value: 2
      select = template(model)

      assert.equal select.value, model.value

    it "should pass the option to the value binding on a change event", (done) ->
      model =
        options: [1, 2, 3].map(Option)
        value: Observable(1)

      model.value.observe (value) ->
        assert typeof value is "string"
        assert.equal value, "3"
        done()

      select = template(model)

      # NOTE: To simulate a selection by choosing value you must pass a string
      select.value = "3"
      assert.equal select.value, "3"
      select.onchange()

  it "should get the correct value when another bound input changes", ->
    template = makeTemplate """
      div
        select(@value)
          @options
        input(@value)
    """
    model =
      options: [1, 2, 3].map(Option)
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
      select(@value)
        @optionElements
    """
    options = [
      {name: "yolo", value: "badical"}
      {name: "wat", value: "noice"}
    ]
    model =
      options: options
      optionElements: ->
        @options.map Option
      value: options[0].value

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
      assert.equal select.value, model.value


  describe "with objects that have an observable name property", ->
    template = makeTemplate """
      select(@value)
        @optionElements
    """

    it "should observe the name as the text of the value options", ->
      options = Observable [
        {name: Observable("Napoleon"), date: "1850 AD"}
        {name: Observable("Barrack"), date: "1995 AD"}
      ]
      model =
        options: options
        optionElements: ->
          options.map Option
        value: options.get(0)

      select = template(model)
      optionElements = select.querySelectorAll("option")

      assert.equal optionElements[0].textContent, "Napoleon"
      options()[0].name("Yolo")
      assert.equal optionElements[0].textContent, "Yolo"

  describe "with objects that have an observable value property", ->
    template = makeTemplate """
      select(@value)
        @optionElements
    """
    it "should observe the value as the value of the value options", ->
      options = Observable [
        {name: Observable("Napoleon"), value: Observable("1850 AD")}
        {name: Observable("Barrack"), value: Observable("1995 AD")}
      ]
      model =
        options: options
        optionElements: ->
          @options.map Option
        value: options.get(0)

      select = template(model)

      assert.equal select.value, "1850 AD"
      options.get(0).value "YOLO"
      assert.equal select.value, "YOLO"

  describe "with an observable array for options", ->
    template = makeTemplate """
      select(@value)
        @optionElements
    """
    it "should add options added to the observable array", ->
      options = Observable [
        {name: "Napoleon", date: "1850 AD"}
        {name: "Barrack", date: "1995 AD"}
      ]
      model =
        options: options
        optionElements: ->
          @options.map Option
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
        optionElements: ->
          @options.map Option

      select = template(model)

      assert.equal select.querySelectorAll("option").length, 2
      options.remove options.get(0)
      assert.equal select.querySelectorAll("option").length, 1

    it "should have it's value set", ->
      options = Observable [
        {name: "Napoleon", value: "1850 AD"}
        {name: "Barrack", value: "1995 AD"}
      ]
      model =
        options: options
        optionElements: ->
          @options.map Option
        value: options()[0].value

      select = template(model)
      assert.equal select.value, model.value

  describe "with an object for options", ->
    template = makeTemplate """
      select(@value)
        @optionElements
    """

    it "should have an option for each key", ->
      options = Observable
        nap: "Napoleon"
        bar: "Barrack"

      model =
        options: options
        optionElements: ->
          Object.entries(@options()).map ([value, name]) ->
            Option
              name: name
              value: value

        value: "bar"

      select = template model
      assert.equal select.value, "bar"

    it "should add options added to the observable object", ->
      options = Observable
        nap: "Napoleon"
        bar: "Barrack"

      model =
        options: options
        optionElements: ->
          Object.entries(@options()).map ([value, name]) ->
            Option
              name: name
              value: value
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
        optionElements: ->
          Object.entries(@options()).map ([value, name]) ->
            Option
              name: name
              value: value
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
        optionElements: ->
          Object.entries(@options()).map ([value, name]) ->
            Option
              name: name
              value: value
        value: "bar"

      select = template model
      optionElements = select.querySelectorAll("option")

      assert.equal optionElements[1].textContent, "Barrack"
      options().bar "YOLO"
      assert.equal optionElements[1].textContent, "YOLO"
