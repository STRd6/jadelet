"use strict"

Observable = require "o_0"

# To clean up listeners we need to keep a map of dom elements and what listeners are bound to them
# when we dispose an element we must traverse its children and clean them up too
# After we remove the listeners we must then remove the element from the map

elementCleaners = new Map

dispose = (element) ->
  elementCleaners.get(element)?.forEach (cleaner) ->
    cleaner()
    elementCleaners.delete(element)
    # Recurse into children
    Array::forEach.call element.children, dispose

attachCleaner = (element, cleaner) ->
  cleaners = elementCleaners.get(element)
  if cleaners
    cleaners.push cleaner
  else
    elementCleaners.set element, [cleaner]

valueBind = (element, value, context) ->
  Observable -> # TODO: Not sure if this is absolutely necessary or the best place for this
    value = Observable value, context

    switch element.nodeName
      when "SELECT"
        element.oninput = element.onchange = ->
          {value:optionValue, _value} = @children[@selectedIndex]

          value(_value or optionValue)

        update = (newValue) ->
          # This is so we can hold a non-string object as a value of the select element
          element._value = newValue

          if (options = element._options)
            if newValue.value?
              # TODO: Handle observable value attributes
              element.value = newValue.value?() or newValue.value
            else
              element.selectedIndex = valueIndexOf options, newValue
          else
            element.value = newValue

        bindObservable element, value, context, update
      else
        # Because firing twice with the same value is idempotent just binding both
        # oninput and onchange handles the widest range of inputs and browser
        # inconsistencies.
        element.oninput = element.onchange = ->
          value(element.value)

        bindObservable element, value, context, (newValue) ->
          unless element.value is newValue
            element.value = newValue

  return

specialBindings =
  INPUT:
    checked: (element, value, context) ->
      element.onchange = ->
        value? element.checked

      bindObservable element, value, context, (newValue) ->
        element.checked = newValue
  SELECT:
    options: (element, values, context) ->
      values = Observable values, context

      updateValues = (values) ->
        empty(element)
        element._options = values

        # TODO: Handle key: value... style options
        values.map (value, index) ->
          option = createElement("option")
          option._value = value
          if typeof value is "object"
            optionValue = value?.value or index
          else
            optionValue = value.toString()

          bindObservable option, optionValue, value, (newValue) ->
            option.value = newValue

          optionName = value?.name or value
          bindObservable option, optionName, value, (newValue) ->
            # Ideally this should only be option.textContent
            # but that fails in IE8
            option.textContent = option.innerText = newValue

          element.appendChild option
          element.selectedIndex = index if value is element._value

          return option

      bindObservable element, values, context, updateValues

observeAttribute = (element, context, name, value) ->
  {nodeName} = element

  # TODO: Consolidate special bindings better than if/else
  if (name is "value")
    valueBind(element, value)
  else if binding = specialBindings[nodeName]?[name]
    binding(element, value, context)
  # Straight up onclicks, etc.
  else if name.match(/^on/) and name of element
    bindEvent(element, name, value, context)
  # Handle click=@method
  else if "on#{name}" of element
    bindEvent(element, "on#{name}", value, context)
  else
    bindObservable element, value, context, (newValue) ->
      if newValue? and newValue != false
        element.setAttribute name, newValue
      else
        element.removeAttribute name

  return element

observeAttributes = (element, context, attributes) ->
  Object.keys(attributes).forEach (name) ->
    value = attributes[name]
    observeAttribute element, context, name, value

bindObservable = (element, value, context, update) ->
  observable = Observable(value, context)

  observable.observe update
  update observable()

  unobserve = ->
    observable.releaseDependencies()
    observable.stopObserving update

  attachCleaner(element, unobserve)

  return element

bindEvent = (element, name, fn, context) ->
  element[name] = ->
    fn?.apply(context, arguments)

id = (element, context, sources) ->
  update = (newId) ->
    element.id = newId

  lastId = ->
    [..., _id] = splat sources, context

    return _id

  bindObservable(element, lastId, context, update)

classes = (element, context, sources) ->
  classNames = ->
    splat(sources, context).join(" ")

  update = (classNames) ->
    element.className = classNames

  bindObservable(element, classNames, context, update)

createElement = (name) ->
  document.createElement name

observeContent = (element, context, contentFn) ->
  # TODO: Don't even try to observe contents for empty functions
  contents = []

  contentFn.call context,
    buffer: bufferTo(context, contents)
    element: makeElement

  append = (item) ->
    if !item? # Skip nulls
    else if typeof item.forEach is "function"
      item.forEach append
    else if item instanceof Node
      element.appendChild item
    else if typeof item is "function"
      append item()
    else
      element.appendChild document.createTextNode item

  update = (contents) ->
    # TODO: Zipper merge optimization to more efficiently modify the DOM
    empty element

    contents.forEach append

  update contents

bufferTo = (context, collection) ->
  (content) ->
    if typeof content is 'function'
      content = Observable(content, context)

    collection.push content

    return content

makeElement = (name, context, attributes={}, fn) ->
  element = createElement name

  # This magic hack will encapsulate observable changes from bubling
  # outside of this element
  # Each of these Observable -> sections localizes re-renders
  # This function auto-invokes and blocks any autobinding from leaving
  # this element
  Observable ->
    if attributes.id?
      id(element, context, attributes.id)
      delete attributes.id

  Observable ->
    if attributes.class?
      classes(element, context, attributes.class)
      delete attributes.class

  # TODO: Need to ensure that attribute changes don't cause a rerender of
  # entire section!
  Observable ->
    observeAttributes(element, context, attributes)
  , context

  # TODO: Maybe have a flag for element contents that are created from
  # attributes rather than special casing this
  unless element.nodeName is "SELECT"
    Observable ->
      observeContent(element, context, fn)
    , context

  return element

Runtime = (context) ->
  self =
    # TODO: May be able to consolidate some of this with the
    # element contents stuff
    buffer: (content) ->
      if self.root
        throw "Cannot have multiple root elements"

      self.root = content

    element: makeElement

    filter: (name, content) ->
      ; # TODO self.filters[name](content)

  return self

Runtime.VERSION = require("../package.json").version
Runtime.Observable = Observable
Runtime._elementCleaners = elementCleaners
Runtime._dispose = dispose
module.exports = Runtime

empty = (node) ->
  while child = node.firstChild
    node.removeChild(child)
    dispose(child)

  return

# A helper to find the index of a value in an array of options
# when the array may contain actual objects or strings, numbers, etc.

# NOTE: This may be too complicated, the core issue is that anything coming from an input
# will be a string, and anything coming from a regular observable can be any object type.
# Possible solutions:
#   Typed observables that auto-convert strings to the correct type.
#   OR
#   Always compare non-object inputs as strings.
valueIndexOf = (options, value) ->
  if typeof value is "object"
    options.indexOf(value)
  else
    options.map (option) ->
      option.toString()
    .indexOf value.toString()

splat = (sources, context) ->
  sources.map (source) ->
    get source, context
  .reduce (a, b) ->
    a.concat get b
  , []
  .filter (x) -> x?

get = (x, context) ->
  if typeof x is 'function'
    x.call(context)
  else
    x
