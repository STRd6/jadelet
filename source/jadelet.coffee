"use strict"

Observable = require "o_0"
forEach = Array::forEach

# To clean up listeners we keep a map of DOM elements and what listeners are bound to them
# when we dispose an element we must traverse its children and clean them up too
# After we remove the listeners we must then remove the element from the map
elementCleaners = new WeakMap
elementRefCounts = new WeakMap

retain = (element) ->
  count = elementRefCounts.get(element) || 0
  elementRefCounts.set(element, count + 1)
  return

release = (element) ->
  count = elementRefCounts.get(element) || 0
  count--

  if count > 0
    elementRefCounts.set(element, count)
  else
    elementRefCounts.delete element
    dispose element
  return

# Disposing an element executes the cleanup for all it's children. If a child
# element should be retained you must mark it explicitly to prevent its
# observables from unbinding.
dispose = (element) ->
  # Recurse into children
  children = element.children
  if children?
    forEach.call children, dispose

  elementCleaners.get(element)?.forEach (cleaner) ->
    cleaner()
    elementCleaners.delete(element)
    return
  return

attachCleaner = (element, cleaner) ->
  cleaners = elementCleaners.get(element)
  if cleaners
    cleaners.push cleaner
  else
    elementCleaners.set element, [cleaner]
  return

# Combined touch and animation events here even though it's sloppy it saves a few bytes
# later we should put all the smarts about what is an event or not in the compiler
eventNames = /^on(touch|animation|transition)(start|iteration|move|end|cancel)$/
isEvent = (name, element) ->
  name.match(eventNames) or name of element

# value is either a literal string or an object shaped
# bind: stringKey
# exceptions for id, class, and style. They are arrays of such strings
# literals and binding objects
observeAttribute = (element, context, name, value) ->
  switch name
    when "id"
      bindSplat element, context, value, (ids) ->
        length = ids.length
        if length
          element.id = ids[length-1]
        else
          element.removeAttribute "id"
        return
    when "class"
      bindSplat element, context, value, (classes) ->
        className = classes.join(" ")
        if className
          element.className = className
        else
          element.removeAttribute "class"
        return
    when "style"
      bindSplat element, context, value, (styles) ->
        # Remove any leftover styles
        element.removeAttribute "style"
        styles.forEach (style) ->
          if isObject style
            Object.assign element.style, style
          else
            element.setAttribute "style", style
        return
    when "value"
      bindValue(element, value, context)
    when "checked"
      if value and isObject(value)
        {bind} = value
        element.onchange = ->
          context[bind]? element.checked
          return

      bindObservable element, value, context, (newValue) ->
        element.checked = newValue != false
        return
    else
      # Handle click=@method
      if isEvent("on#{name}", element)
        # It doesn't make sense for events to not be bound
        bindEvent(element, name, value.bind, context)
      else
        bindObservable element, value, context, (newValue) ->
          if newValue? and newValue != false
            element.setAttribute name, newValue
          else
            element.removeAttribute name
          return

  return

# To bind an observable precisely to the site where it is
# and to be able to clean up we need to create a fresh
# Observable stack. Since the observable re-computes
# when any of its dependencies change it will refresh the update
# with the new value. To clean up we release the dependencies of
# our computed observable. We store the observables to clean up
# on a map keyed by the element.
bindObservable = (element, value, context, update) ->
  # If the value is a simple string then simply set it and exit
  # No point in creating an observable if it isn't a binding
  if isString value
    return update(value)
  else if typeof value is 'function'
    observable = Observable ->
      update value.call context
      return
  else
    {bind} = value
    observable = Observable ->
      update get context[bind], context
      return

  # return if no dependencies, no need to attach cleaners
  if observable._observableDependencies.size is 0
    return

  # Release the observable's dependencies when this element is cleaned up
  attachCleaner element, observable.releaseDependencies

  return

bindValue = (element, value, context) ->
  # Because firing twice with the same value is idempotent just binding both
  # oninput and onchange handles the widest range of inputs and browser
  # inconsistencies.
  if value and typeof value is "object"
    {bind} = value
    element.oninput = element.onchange = ->
      context[bind]? element.value
      return

  bindObservable element, value, context, (newValue) ->
    unless element.value is newValue
      element.value = newValue
    return

  return

bindEvent = (element, name, binding, context) ->
  handler = context[binding]
  if typeof handler is 'function'
    element.addEventListener name, handler.bind(context)

  return

bindSplat = (element, context, sources, update) ->
  bindObservable element, (-> splat sources, context), context, update

  return

observeContent = (element, context, contentArray, namespace) ->
  # Map the content array into into an elements array (can be more or less,
  # essentially a flatmap) Keep track of observables, only update the proper
  # places when observables change.

  tracker = []
  count = 0

  contentArray.forEach (astNode, index) ->
    # Track the child index this content starts on
    tracker[index] = count

    if Array.isArray(astNode)
      element.appendChild render astNode, context, namespace
      count++

    else if isString astNode
      element.appendChild document.createTextNode astNode
      count++

    # Content Binding
    else if isObject(astNode)
      # Total number of items added
      # how many we need to remove on cleanup
      length = previousLength = 0
      # track element indices
      # update and rebase index on change

      bindObservable element, astNode, context, (value) ->
        previousLength = length
        pos = tracker[index]
        beforeTarget = element.childNodes[pos+length]
        toRelease = new Array(length)

        # Remove previously added nodes
        i = 0
        while i < length
          child = element.childNodes[pos]
          element.removeChild child
          toRelease[i] = child
          i++

        # Append New
        length = append element, value, beforeTarget

        # Relase after appending so if a node was re-added it won't hit zero
        # in its refcount and be prematurely disposed
        i = 0
        while i < previousLength
          child = toRelease[i]
          release child
          i++

        # Rebase downstream indices
        delta = length - previousLength
        i = index+1
        while i < tracker.length
          tracker[i] += delta
          i++

        return

      count += length
    else
      throw new Error "oof"
    return

  return

# Append nodes to an element, return the total number appended
append = (element, item, beforeTarget) ->
  if !item? # Skip nulls
    return 0
  else if Array.isArray(item)
    return item.map (item) ->
      append element, item, beforeTarget
    .reduce (a, b) ->
      a + b
    , 0
  else if item instanceof Node
    retain item
    element.insertBefore item, beforeTarget
  else if (el = item.element) instanceof Node
    retain el
    element.insertBefore el, beforeTarget
  else
    element.insertBefore document.createTextNode(item), beforeTarget

  return 1

isObject = (x) ->
  typeof x is "object"

isString = (x) ->
  typeof x is "string"

splat = (sources, context) ->
  sources.map (source) ->
    if isString source
      source
    else
      get context[source.bind], context
  .reduce (a, b) ->
    a.concat b
  , []
  .filter (x) -> x?

get = (x, context) ->
  if typeof x is 'function'
    x.call(context)
  else
    x

render = (astNode, context={}, namespace) ->
  [tag, attributes, children] = astNode

  # This namespace is only for svg support though it may be expanded in the
  # future. The idea is to set the namespace if the tag name is 'svg' and to
  # pass that namespace down to all children of the tag. Other elements won't
  # have a namespace and will render using the usual `createElement`.
  if tag is "svg" and !namespace
    namespace = "http://www.w3.org/2000/svg"

  if namespace
    element = document.createElementNS namespace, tag
  else
    element = document.createElement tag
  # We populate the content first so that value binding for `select` tags
  # works properly.
  observeContent element, context, children, namespace
  Object.keys(attributes).forEach (name) ->
    observeAttribute element, context, name, attributes[name]
    return

  return element

parser = require "./jadelet-parser"

module.exports = Jadelet =
  compile: (source, opts={}) ->
    ast = Jadelet.parse(source)
    runtime = opts.runtime or "require('jadelet')"
    exports = opts.exports or "module.exports"

    """
      #{exports} = #{runtime}.exec(#{JSON.stringify(ast)});
    """
  parse: parser.parse
  parser: parser
  exec: (ast) ->
    if typeof ast is "string"
      ast = Jadelet.parse ast

    return (context) ->
      render ast, context
  Observable: Observable
  _elementCleaners: elementCleaners
  dispose: dispose
  retain: retain
  release: release
