describe "elements", ->
  it "should render dom elements", ->
    div = document.createElement "div"
    div.innerText = "hello"

    T = Jadelet.exec """
      section
        @el
    """

    section = T
      el: div

    assert.equal section.children[0]?.innerText, "hello"
    assert section.children[0] instanceof window.HTMLDivElement

  it "should render 'view-like' elements", ->
    div = document.createElement "div"
    div.innerText = "hello"

    T = Jadelet.exec """
      section
        @view
    """

    section = T
      view:
        element: div

    assert.equal section.children[0]?.innerText, "hello"
    assert section.children[0] instanceof window.HTMLDivElement
