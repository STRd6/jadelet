extend = Object.assign

CoffeeScript = require "coffee-script"

compile = require "../dist/compiler"
Runtime = require "../dist/runtime"
Observable = Runtime.Observable

{jsdom} = require("jsdom")

document = jsdom()

{Event} = window = document.defaultView

extend global,
  assert: require "assert"
  extend: extend
  Node: window.Node
  Observable: Observable
  Runtime: Runtime
  document: document
  dispatchEvent: (element, eventName, options={}) ->
    element.dispatchEvent new Event eventName, options

  Q: (args...) ->
    document.querySelector(args...)

  all: (args...) ->
    document.querySelectorAll(args...)

  makeTemplate: (code) ->
    compiled = compile code,
      runtime: "Runtime"
      compiler: CoffeeScript
      exports: false
      mode: "jade" # TODO: Jadelet will be the only mode

    Function("Runtime", "return " + compiled)(Runtime)

  empty: (node) ->
    while child = node.firstChild
      node.removeChild child

  behave: (fragment, fn) ->
    document.body.appendChild fragment
    try
      fn()
    finally
      empty document.body
