describe "Filters", ->
  it "should provide :coffeescript", ->
    Template = makeTemplate """
      :coffeescript
        a = "jawsome"
      div(type=a)
    """

    element = Template()
    assert.equal element.getAttribute("type"), "jawsome"

  it "should provide :javascript", ->
    Template = makeTemplate """
      :javascript
        var a = "jawsome";
      div(type=a)
    """

    element = Template()
    assert.equal element.getAttribute("type"), "jawsome"

  it "should work with custom filters", ->
    Jadelet.filters.html = (content, {buffer}) ->
      div = document.createElement "div"
      div.innerHTML = content
      buffer div
      return

    Template = makeTemplate """
      :html
        <h1>2 rad</h1>
        <p>yo</p>
    """

    element = Template()
    assert.equal element.querySelector('h1').textContent, "2 rad"
    assert.equal element.querySelector('p').textContent, "yo"

  it "should work with custom filters when nested", ->
    Jadelet.filters.html = (content, {buffer}) ->
      div = document.createElement "div"
      div.innerHTML = content
      buffer div
      return

    Template = makeTemplate """
      div
        page
          :html
            <h1>2 rad</h1>
            <p>yo</p>
    """

    element = Template()
    assert.equal element.querySelector('h1').textContent, "2 rad"
    assert.equal element.querySelector('p').textContent, "yo"

  describe ":verbatim", ->
    it "should keep text verbatim", ->
      Template = makeTemplate """
        textarea
          :verbatim
            <I> am <verbatim> </text>
      """

      element = Template()
      assert.equal element.value, "<I> am <verbatim> </text>"

    it "should work with indentation", ->
      Template = makeTemplate """
        div
          :verbatim
            Hey
              It's
                Indented

      """

      element = Template()
        # TODO: This probably shouldn't have a trailing \n
      assert.equal element.textContent, "Hey\n  It's\n    Indented\n"

    it "should work with indentation without extra trailing whitespace", ->
      whitespace = "    "
      Template = makeTemplate """
        div
          :verbatim
            Hey
              It's#{whitespace}
                Indented

      """
      # TODO/NOTE: Must have blank line after filters otherwise they mess up indentation

      element = Template()
      assert.equal element.textContent, "Hey\n  It's    \n    Indented\n"

    it "should work with \"\"\"", ->
      Template = makeTemplate """
        div
          :verbatim
            sample = \"\"\"
              Hey
            \"\"\"

      """

      element = Template()
      assert.equal element.textContent, "sample = \"\"\"\n  Hey\n\"\"\"\n"
