describe "Jadelet API", ->
  it "should parse and exec", ->
    {parse, exec} = Jadelet

    t = exec parse """
      h1 hi
    """

    assert.equal t().textContent, "hi"

  it "should compile", ->
    {compile} = Jadelet

    s = compile """
      h1 hi
    """

    assert s
