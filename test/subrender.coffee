describe "subrender", ->
  describe "rendering simple text", ->
    template = makeTemplate """
      %span.count= @count
    """

    it "should render numbers as strings", ->
      model =
        count: 5

      behave template(model), ->
        assert.equal Q(".count").textContent, "5"

    it "should update when observable changes", ->
      model =
        count: Observable 5

      behave template(model), ->
        assert.equal Q(".count").textContent, "5"
        model.count 2
        assert.equal Q(".count").textContent, "2"

  describe "with root node", ->
    template = makeTemplate """
      %div
        = @generateItem
    """

    it "should render elements in-line", ->
      model =
        generateItem: ->
          document.createElement("li")

      behave template(model), ->
        assert Q("li")

    it "should render lists of nodes", ->
      model =
        generateItem: ->
          [
            document.createElement("li")
            document.createElement("li")
            document.createElement("p")
          ]

      behave template(model), ->
        assert all("li").length, 2
        assert all("p").length, 1

    it "should work with a node with children", ->
      model =
        generateItem: ->
          div = document.createElement "div"

          div.innerHTML = "<p>Yo</p><ol><li>Yolo</li><li>Broheim</li></ol>"

          div

      behave template(model), ->
        assert all("li").length, 2
        assert all("p").length, 1
        assert all("ol").length, 1

    it "should work with observables", ->
      model =
        name: Observable "wat"
        generateItem: ->
          item = document.createElement("li")

          item.textContent = @name()

          item

      behave template(model), ->
        assert.equal all("li").length, 1

        assert.equal Q("li").textContent, "wat"

        model.name "yo"

        assert.equal Q("li").textContent, "yo"

  describe "rendering subtemplates", ->
    describe "mixing and matching", ->
      subtemplate = makeTemplate """
        %span Hello
      """
      template = makeTemplate """
        %div
          %a Radical
          = @subtemplate()
          = @observable
          = @nullable
      """

      it "shouldn't lose any nodes", ->
        model =
          observable: Observable "wat"
          subtemplate: subtemplate
          nullable: null

        behave template(model), ->
          assert.equal Q("div").textContent, "Radical\nHello\nwat"
          model.observable "duder"
          assert.equal Q("div").textContent, "Radical\nHello\nduder"

    describe "mapping array to subtemplates", ->
      template = makeTemplate """
        - subtemplate = @subtemplate

        %table
          = @rows.map subtemplate
      """

      it "should render subtemplates", ->
        model =
          rows: [
            "Wat"
            "is"
            "up"
          ]
          subtemplate: makeTemplate """
            %tr
              %td= this
          """

        behave template(model), ->
          assert.equal all("tr").length, 3

      it "should maintain observables in subtemplates", ->
        model =
          rows: Observable [
            Observable "Wat"
            Observable "is"
            Observable "up"
          ]
          subtemplate: makeTemplate """
            %tr
              %td= this
          """

        behave template(model), ->
          assert.equal all("tr").length, 3
          assert.equal Q("td").textContent, "Wat"

          model.rows()[0] "yo"

          assert.equal Q("td").textContent, "yo"

          model.rows.push Observable("dude")

          assert.equal all("tr").length, 4
          assert.equal Q("td").textContent, "yo"

          model.rows()[0] "holla"
          assert.equal Q("td").textContent, "holla"

    describe "without root node", ->
      template = makeTemplate """
        %div
          = @sub1()
          = @sub2()
      """

      it "should render both subtemplates", ->
        model =
          sub1: makeTemplate ".yolo Hi"
          sub2: makeTemplate "%h2 There"

        behave template(model), ->
          assert.equal all("h2").length, 1
          assert.equal all(".yolo").length, 1
