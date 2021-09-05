describe "text", ->
  it "should do inline text", ->
    template = makeTemplate """
      p
        | hello I am a cool paragraph
        | with lots of text and stuff
        | ain't it rad?
    """

    element = template()

    assert.equal element.textContent, """
      hello I am a cool paragraph
      with lots of text and stuff
      ain't it rad?\n
    """
