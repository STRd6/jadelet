extend = Object.assign

Jadelet = require "../dist/jadelet"
{exec, Observable} = Jadelet

{jsdom} = require("jsdom")

document = jsdom()

{Event} = window = document.defaultView

extend global,
  assert: require "assert"
  extend: extend
  Jadelet: Jadelet
  Node: window.Node
  Observable: Observable
  document: document
  dispatchEvent: (element, eventName, options={}) ->
    element.dispatchEvent new Event eventName, options

  Q: (args...) ->
    document.querySelector(args...)

  all: (selectors, base=document) ->
    base.querySelectorAll(selectors)

  makeTemplate: exec
 