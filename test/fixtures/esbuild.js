// Test source file for esbuild plugin build/plugin-test.coffee

module.exports = {
  Simple: require("../samples/simple_class.jadelet"),
  Multiple: require("../samples/multiple.jadelet"),
  Attributes: require("../samples/attributes.jadelet"),
  Nesting: require("../samples/nesting.jadelet"),
}
