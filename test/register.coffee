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
    require "../register"

    T = require "./samples/simple_class"
    assert T()
