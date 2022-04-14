describe "Custom Elements", ->
  it "should render custom elements", ->
    # TODO: Need to figure out observable bindings for attributes and children
    Jadelet.define
      Cool: (attributes, children) ->
        el = document.createElement 'x-cool'

        console.log Object.keys(attributes).map (k) ->
          [k, attributes[k]()]

        console.log children

        return el

    T = Jadelet.exec """
      Cool#myId.cl1.cl2(@rad cool wat="yo" @class @id @style)
        | he
        li Heyy
        @keeds
    """

    assert.equal T({
      rad: true
      class: Observable "c1"
      style: [
        "color: green",
        {"font-size": "2rem"}
      ]
    }).tagName, "X-COOL"

    T = Jadelet.exec """
      Cool(@id)
    """

    assert.equal T({}).id, ''
