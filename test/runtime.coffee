describe "Jadelet Runtime", ->
  it "should provide Observable", ->
    assert Jadelet.Observable

  it "should throw an error on multiple root elements", ->
    assert.throws ->
      makeTemplate """
        h1 yo
        p what's my information architecture lol
      """
