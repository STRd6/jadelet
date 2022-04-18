{JSDOM} = require("jsdom")
{window} = new JSDOM("")
{Node, document} = window
# TODO: CoffeeSense destructuring doesn't like when a var is used in a function below
Event = window.Event

Object.assign global,
  document: document
  window: window
  Node: Node

Jadelet = require "../source/jadelet"
{exec, Observable} = Jadelet

Object.assign global,
  assert: require "assert"
  Jadelet: Jadelet
  Observable: Observable

  ###* @type {dispatch} ###
  dispatch: (element, eventName, options={}) ->
    element.dispatchEvent new Event eventName, options

  makeTemplate: exec
