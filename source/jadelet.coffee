"use strict"

###*
@typedef {import("../types/types").Context} Context
@typedef {import("../types/types").JadeletAttribute} JadeletAttribute
@typedef {import("../types/types").JadeletAttributes} JadeletAttributes
@typedef {import("../types/types").JadeletAST} JadeletAST
@typedef {import("../types/types").JadeletElement} JadeletElement
@typedef {typeof import("../types/main")} Jadelet
###

#
{ Observable } = require "@danielx/observable"
forEach = Array::forEach

#
###*
A map of DOM elements and what listeners are bound to them.
To dispose of an element traverse its children and clean them up too.
After we remove the listeners we remove the element from the map
@type {WeakMap<Node, Function[]>}
###
elementCleaners = new WeakMap
#
###* @type {WeakMap<Node, number>} ###
elementRefCounts = new WeakMap

retain = (###* @type {Node}### element) ->
  count = elementRefCounts.get(element) || 0
  elementRefCounts.set(element, count + 1)
  return

release = (###* @type {Node}### element) ->
  count = elementRefCounts.get(element) || 0
  count--

  if count > 0
    elementRefCounts.set(element, count)
  else
    elementRefCounts.delete element
    dispose element
  return

#
###*
Disposing an element executes the cleanup for all it's children. If a child
element should be retained you must mark it explicitly to prevent its
observables from unbinding.
@param element {Node}
###
dispose = (element) ->
  # Recurse into children
  #@ts-ignore
  children = element.children
  if children?
    forEach.call children, dispose

  elementCleaners.get(element)?.forEach (cleaner) ->
    cleaner()
    elementCleaners.delete(element)
    return
  return

#
###*
Attach a cleaner function to run when the element is disposed of.
@param element {Node}
@param cleaner {Function}
###
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
isEvent = (###* @type {string}### name, ###* @type {Node}### element) ->
  name.match(eventNames) or name of element

#
###*
Bind an attribute to an element such that when its value changes the value of
the element is updated.

@param element {JadeletElement} The element to bind to.
@param context {Context} The binding context.
@param name {string} The name of the property being bound.
@param value {JadeletAttribute} A JadeletAttribute or in the case of class, id, style, an array of attributes to bind.
###
observeAttribute = (element, context, name, value) ->
  switch name
    when "id"
      #@ts-ignore
      bindSplat element, context, value, (###* @type {string[]}### ids) ->
        length = ids.length
        if length
          element.id = ids[length-1] or ""
        else
          element.removeAttribute "id"
        return
    when "class"
      #@ts-ignore
      bindSplat element, context, value, (###* @type {string[]}### classes) ->
        className = classes.join(" ")
        if className
          element.setAttribute "class", className
        else
          element.removeAttribute "class"
        return
    when "style"
      #@ts-ignore
      bindSplat element, context, value, (###* @type {Array<string|Object>}### styles) ->
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
      if value and !isString(value)
        element.onchange = ->
          context[value.bind]? element.checked
          return

      bindObservable element, value, context, (newValue) ->
        element.checked = newValue != false
        return
    else
      # Handle click=@method
      if isEvent("on#{name}", element) and !isString(value)
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

#
###*
To bind an observable precisely to the site where it is
and to be able to clean up we need to create a fresh
Observable stack. Since the observable re-computes
when any of its dependencies change it will refresh the update
with the new value. To clean up we release the dependencies of
our computed observable. We store the observables to clean up
on a map keyed by the element.

@type {import("../types/types").bindObservable}
###
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
    observable = Observable ->
      update get context[value.bind], context
      return

  # return if no dependencies, no need to attach cleaners
  if observable._observableDependencies.size is 0
    return

  # Release the observable's dependencies when this element is cleaned up
  attachCleaner element, observable.releaseDependencies

  return

#
###* @type {(element: JadeletElement, value: JadeletAttribute, context: Context) => void} ###
bindValue = (element, value, context) ->
  # Because firing twice with the same value is idempotent just binding both
  # oninput and onchange handles the widest range of inputs and browser
  # inconsistencies.
  if value and typeof value is "object"
    element.oninput = element.onchange = ->
      context[value.bind]? element.value
      return

  bindObservable element, value, context, (newValue) ->
    unless element.value is newValue
      element.value = newValue
    return

  return

#
###* @type {(element: JadeletElement, name: string, binding: string, context: Context) => void} ###
bindEvent = (element, name, binding, context) ->
  handler = context[binding]
  if typeof handler is 'function'
    element.addEventListener name, handler.bind(context)

  return

#
###* @type {(element: JadeletElement, context: Context, sources: JadeletAttribute[], update: (value: any) => void) => void} ###
bindSplat = (element, context, sources, update) ->
  bindObservable element, (-> splat sources, context), context, update

  return

#
###* @type {(element: JadeletElement, context: Context, contentArray: JadeletAST[], namespace?: string) => void} ###
observeContent = (element, context, contentArray, namespace) ->
  # Map the content array into into an elements array (can be more or less,
  # essentially a flatmap) Keep track of observables, only update the proper
  # places when observables change.

  #
  ###* @type {number[]}###
  tracker = []
  count = 0

  contentArray.forEach (astNode, index) ->
    # Track the child index this content starts on
    tracker[index] = count
    length = 0

    # array is [tag, attributes, children]
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
        #@ts-ignore
        beforeTarget = element.childNodes[pos+length]
        toRelease = Array(length)

        # Remove previously added nodes
        i = 0
        while i < length
          #@ts-ignore
          child = element.childNodes[pos]
          element.removeChild child
          toRelease[i] = child
          i++

        # Append New
        #@ts-ignore
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
      throw Error "oof"
    return

  return

# Append nodes to an element, return the total number appended
###*
# @type { (element: JadeletElement, item: any, beforeTarget: Node | null) => number }
###
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

#
###* @type {import("../types/types").isObject} ###
isObject = (x) ->
  typeof x is "object"

#
###* @type {import("../types/types").isString} ###
isString = (x) ->
  typeof x is "string"

#
###* @type {(sources: JadeletAttribute[], context: Context) => unknown[]}###
splat = (sources, context) ->
  sources.map (source) ->
    if isString source
      source
    else
      get context[source.bind], context
  .reduce (a, b) ->
    a.concat b
  , []
  .filter (###* @type {unknown}### x) -> x?

#
###*
@param x {unknown}
@param context {Context}
###
get = (x, context) ->
  if typeof x is 'function'
    x.call(context)
  else
    x

#
###* @type {import("../types/types").last} ###
last = (array) ->
  return array[array.length-1]

#
###* @type {{
  id: (source: JadeletAttribute[], context: Context) => () => unknown
  class: (source: JadeletAttribute[], context: Context) => () => unknown[]
  style: (source: JadeletAttribute[], context: Context) => () => string | Object
}} ###
mappers =
  id:  (source, context) ->
    ->
      last splat source, context
  class: (source, context) ->
    ->
      splat source, context
  style: (source, context) ->
    ->
      result = {}
      stringResult = null
      splat(source, context).forEach (style) ->
        if isObject style
          Object.assign result, style
          stringResult = null
        else
          stringResult = style

      return stringResult or result

#
###*
# @type {(attributes: JadeletAttributes, context: Context) => Context}
###
mapAttributes = (attributes, context) ->
  Object.fromEntries Object.entries(attributes).map ([key, source]) ->
    f =
    if Array.isArray(source)
      #@ts-ignore TODO
      m = mappers[key]
      m(source, context)
    else if isString(source)
      -> source
    else
      -> get context[source.bind], context

    [key, f]

#
###*
# @type  { (ast: import("../types/types").JadeletASTNode, context: Context, namespace?: string) => JadeletElement }
###
render = (astNode, context={}, namespace) ->
  [tag, attributes, children] = astNode

  if Presenter = customElements[tag]
    return Presenter(mapAttributes(attributes, context), children)

  # This namespace is only for svg support though it may be expanded in the
  # future. The idea is to set the namespace if the tag name is 'svg' and to
  # pass that namespace down to all children of the tag. Other elements won't
  # have a namespace and will render using the usual `createElement`.
  if tag is "svg" and !namespace
    namespace = "http://www.w3.org/2000/svg"

  #
  ###* @type {JadeletElement} ###
  #@ts-ignore expand Element to JadeletElement
  element = if namespace
    document.createElementNS namespace, tag
  else
    document.createElement tag
  # We populate the content first so that value binding for `select` tags
  # works properly.
  observeContent element, context, children, namespace
  Object.entries(attributes).forEach ([name, value]) ->
    #@ts-ignore TODO
    observeAttribute element, context, name, value
    return

  return element

#
###* @type {typeof import("../types/main").parser} ###
parser = require "./parser.hera"

#
###* @type { {[Key:string]: (mappedAttributes: any, children: JadeletAST[]) => JadeletElement }}###
customElements = {}

#
###* @type {Jadelet} ###
Jadelet =
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
    if isString ast
      ast = Jadelet.parse ast

    return (context) ->
      # @ts-ignore
      render ast, context
  Observable: Observable
  _elementCleaners: elementCleaners
  define: (definitions) ->
    Object.assign customElements, definitions
    return Jadelet
  dispose: dispose
  retain: retain
  release: release

module.exports = Jadelet
