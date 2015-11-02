describe "Random tags", ->
  template = makeTemplate """
    %div
      %duder
      %yolo(radical=true)
      %sandwiches(type=@type)
  """
  model =
    type: Observable "ham"

  it "should be have those tags and atrtibutes", ->
    behave template(model), ->
      assert Q "duder"
      assert Q("yolo").getAttribute("radical")
      assert.equal Q("sandwiches").getAttribute("type"), "ham"

  it "should reflect changes in observables", ->
    behave template(model), ->
      assert.equal Q("sandwiches").getAttribute("type"), "ham"
      model.type "pastrami"
      assert.equal Q("sandwiches").getAttribute("type"), "pastrami"
