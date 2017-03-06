describe "Filters", ->
  it "should provide :coffeescript", ->
    template = makeTemplate """
      :coffeescript
        a = "jawsome"
      div(type=a)
    """

    behave template(), ->
      assert.equal Q("div").getAttribute("type"), "jawsome"

  it "should provide :javascript", ->
    template = makeTemplate """
      :javascript
        var a = "jawsome";
      div(type=a)
    """

    behave template(), ->
      assert.equal Q("div").getAttribute("type"), "jawsome"

  describe ":verbatim", ->
    it "should keep text verbatim", ->
      template = makeTemplate """
        textarea
          :verbatim
            <I> am <verbatim> </text>
      """

      behave template(), ->
        assert.equal Q("textarea").value, "<I> am <verbatim> </text>"

    it "should work with indentation", ->
      template = makeTemplate """
        div
          :verbatim
            Hey
              It's
                Indented

      """

      behave template(), ->
        # TODO: This probably shouldn't have a trailing \n
        assert.equal Q("body").textContent, "Hey\n  It's\n    Indented\n"

    it "should work with indentation without extra trailing whitespace", ->
      whitespace = "    "
      template = makeTemplate """
        div
          :verbatim
            Hey
              It's#{whitespace}
                Indented

      """
      # TODO/NOTE: Must have blank line after filters otherwise they mess up indentation

      behave template(), ->
        assert.equal Q("body").textContent, "Hey\n  It's    \n    Indented\n"

    it "should work with \"\"\"", ->
      template = makeTemplate """
        div
          :verbatim
            sample = \"\"\"
              Hey
            \"\"\"

      """

      behave template(), ->
        assert.equal Q("body").textContent, "sample = \"\"\"\n  Hey\n\"\"\"\n"
