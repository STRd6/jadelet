{compile, parse, exec} = Jadelet

describe "Jadelet API", ->
  it "should parse and exec", ->
    t = exec parse """
      h1 hi
    """

    assert.equal t().textContent, "hi"

  it "should compile", ->
    s = compile """
      h1 hi
    """

    assert s
