describe "ast", ->
  it "should fail on a corrupted ast", ->
    assert.throws ->
      ###* @type {any} ###
      ast = ["h1", {}, [5]]
      T = Jadelet.exec(ast)
      T()
    , /oof/
