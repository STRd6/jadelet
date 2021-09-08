{JSDOM} = require("jsdom")
{window} = new JSDOM("")
{Event, Node, document} = window

Object.assign global,
  document: document
  window: window
  Node: Node

Jadelet = require "../dist/jadelet"
{exec, Observable} = Jadelet

Object.assign global,
  assert: require "assert"
  Jadelet: Jadelet
  Observable: Observable

  dispatchEvent: (element, eventName, options={}) ->
    element.dispatchEvent new Event eventName, options

  Q: (args...) ->
    document.querySelector(args...)

  all: (selectors, base=document) ->
    base.querySelectorAll(selectors)

  makeTemplate: exec
 