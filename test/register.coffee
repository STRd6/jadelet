path = require "path"

# Kind of a hack to override the exported runtime to work in the tests
getRootModule = (module) ->
  return module unless module.parent
  getRootModule module.parent

m = getRootModule(module)
m.options =
  runtime: "require(#{JSON.stringify(path.join(__dirname, "..", "source", "jadelet"))})"

describe "register", ->
  it "should register", ->
    require "../source/register"

    T = require "./samples/simple_class"
    assert T()

  it "should transform", (done) ->
    Transform = require "../source/register"

    transform = Transform(path.join(__dirname, "samples", "simple_class"))
    transform.on "finish", ->
      done()

    transform.end """
      ul
        li Hi
    """

  it "should error when invalid", (done) ->
    Transform = require "../source/register"

    transform = Transform(path.join(__dirname, "samples", "simple_class"))
    transform.on "error", (e) ->
      assert e
      done()

    transform.end """
      #id#li#wat Hi
    """

    return
