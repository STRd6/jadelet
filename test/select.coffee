describe "SELECT", ->
  template = makeTemplate """
    %select(@value @options)
  """
  describe "with an array of basic types for options", ->
    it "should generate options", ->
      model =
        options: [1, 2, 3]
        value: 2
      behave template(model), ->
        assert.equal all("option").length, model.options.length

    it "should have it's value set", ->
      model =
        options: [1, 2, 3]
        value: 2
      behave template(model), ->
        assert.equal Q("select").value, model.value

    it "should pass the option to the value binding on a change event", (done) ->
      model =
        options: [1, 2, 3]
        value: Observable(1)

      model.value.observe (value) ->
        # NOTE: The value is a memebr of the options array
        assert typeof value is "number"
        assert.equal value, 3
        done()

      behave template(model), ->
        select = Q("select")
        # NOTE: To simulate a selection by choosing value you must pass a string
        select.value = "3"
        assert.equal select.value, "3"
        Q("select").onchange()

  it "should get the correct value when another bound input changes", ->
    t = makeTemplate("""
      %div
        %select(@value @options)
        %input(@value)
    """)
    m =
      options: [1, 2, 3]
      value: Observable 2

    behave t(m), ->
      input = Q("input")

      input.value = "3"
      input.oninput()

      assert.equal m.value(), 3

      assert.equal Q("select").value, 3
      m.value 1
      assert.equal Q("select").value, 1

  describe "with an array of objects for options", ->
    options = [
        {name: "yolo", value: "badical"}
        {name: "wat", value: "noice"}
      ]
    model =
      options: options
      value: options[0]
    it "should generate options", ->
      behave template(model), ->
        assert.equal all("option").length, model.options.length
    it "option names should be the name property of the object", ->
      behave template(model), ->
        names = Array::map.call all("option"), (o) -> o.text

        names.forEach (name, i) ->
          assert.equal name, model.options[i].name

    it "option values should be the value property of the object", ->
      behave template(model), ->
        values = Array::map.call all("option"), (o) -> o.value

        values.forEach (value, i) ->
          assert.equal value, model.options[i].value
    it "should have it's value set", ->
      behave template(model), ->
        # TODO: This isn't a great check
        assert.equal Q("select")._value, model.value

    it "should trigger a call to value binding when changing", (done) ->
      model =
        options: options

      model.value = Observable options[0], model
      model.value.observe (v) ->
        assert v.name is "wat"
        done()

      behave template(model), ->
        # Simulate a selection
        Q("select").value = "noice"
        Q("select").onchange()

  describe "An observable array of objects without value properties", ->
    options = Observable [
      {name: "foo"}
      {name: "bar"}
      {name: "baz"}
    ]

    model =
      options: Observable options
      value: Observable options[0]

    it "should update the selected item when the model changes and the options don't have value properties", ->
      behave template(model), ->
        assert.equal Q("select").selectedIndex, 0
        model.value model.options.get(1)
        assert.equal Q("select").selectedIndex, 1


  describe "with objects that have an observable name property", ->
    it "should observe the name as the text of the value options", ->
      options = Observable [
        {name: Observable("Napoleon"), date: "1850 AD"}
        {name: Observable("Barrack"), date: "1995 AD"}
      ]
      model =
        options: options
        value: options.get(0)

      behave template(model), ->
        assert.equal all("option")[0].textContent, "Napoleon"
        options.get(0).name("Yolo")
        assert.equal all("option")[0].textContent, "Yolo"

  describe "with objects that have an observable value property", ->
    it "should observe the value as the value of the value options", ->
      options = Observable [
        {name: Observable("Napoleon"), value: Observable("1850 AD")}
        {name: Observable("Barrack"), value: Observable("1995 AD")}
      ]
      model =
        options: options
        value: options.get(0)

      behave template(model), ->
        assert.equal Q("select").value, "1850 AD"
        options.get(0).value "YOLO"
        assert.equal Q("select").value, "YOLO"

  describe "with an observable array for options", ->
    it "should add options added to the observable array", ->
      options = Observable [
        {name: "Napoleon", date: "1850 AD"}
        {name: "Barrack", date: "1995 AD"}
      ]
      model =
        options: options
        value: options.get(0)
      behave template(model), ->
        assert.equal all("option").length, 2
        options.push name: "Test", date: "2014 AD"
        assert.equal all("option").length, 3
    it "should remove options removed from the observable array", ->
      options = Observable [
        {name: "Napoleon", date: "1850 AD"}
        {name: "Barrack", date: "1995 AD"}
      ]
      model =
        options: options
        value: options.get(0)
      behave template(model), ->
        assert.equal all("option").length, 2
        options.remove options.get(0)
        assert.equal all("option").length, 1
    it "should have it's value set", ->
      options = Observable [
        {name: "Napoleon", date: "1850 AD"}
        {name: "Barrack", date: "1995 AD"}
      ]
      model =
        options: options
        value: options.get(0)
      behave template(model), ->
        # TODO: This isn't a great check
        assert.equal Q("select")._value, model.value
  describe "with an object for options", ->
    it "should have an option for each key"
