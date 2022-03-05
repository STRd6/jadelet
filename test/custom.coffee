describe "Custom Elements", ->
  it "should render custom elements", ->
    Jadelet.define
      Cool: (attributes, children) ->
        el = document.createElement 'x-cool'

        console.log Object.keys(attributes).map (k) ->
          [k, attributes[k]()]

        console.log children

        return el

    T = Jadelet.exec """
      Cool#myId.cl1.cl2(@rad cool wat="yo" @class @id)
        | he
        li Heyy
        @keeds
    """

    assert.equal T({
      rad: true
    }).tagName, "X-COOL"
