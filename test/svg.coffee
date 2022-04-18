describe "svg", ->
  it "should render svg", ->
    src = """
      section
        h2 svg test
        svg(width=100 height=100)
          circle(cx=80 cy=80 r=30 fill="red")
        p awesome
    """

    template = makeTemplate src
    element = template()

    assert.equal element.querySelector('svg')?.namespaceURI, "http://www.w3.org/2000/svg"
