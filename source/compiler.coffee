parser = require "./parser/main"

module.exports = (input, options={}) ->
  if typeof input is "string"
    input = parser.parse(input)

  return compile(input, options)

indentText = (text, indent="  ") ->
  indent + text.replace(/\n/g, "\n#{indent}")

ROOT_NAME = "__root"

util =
  indent: indentText

  element: (tag, attributes=[], contents=[]) ->
    lines = [
      "#{ROOT_NAME}.buffer #{ROOT_NAME}.element #{JSON.stringify(tag)}, this, {#{attributes.join('\n')}}, (#{ROOT_NAME}) ->"
      indentText contents.join("\n")
      "  return"
    ]

  buffer: (value) ->
    [
      "#{ROOT_NAME}.buffer #{value}"
    ]

  attributes: (node) ->
    {id, classes, attributes} = node

    if id
      ids = [JSON.stringify(id)]
    else
      ids = []

    classes = (classes || []).map JSON.stringify
    styles = []

    if attributes
      attributes = attributes.filter ({name, value}) ->
        if name is "class"
          classes.push value
          return
        else if name is "id"
          ids.push value
          return
        else if name is "style"
          styles.push value
          return
        else
          true

    else
      attributes = []

    specialAttributes = []

    if ids.length
      specialAttributes.push "id: [#{ids.join(', ')}]"

    if classes.length
      specialAttributes.push "class: [#{classes.join(', ')}]"

    if styles.length
      specialAttributes.push "style: [#{styles.join(', ')}]"

    attributeLines = attributes.map ({name, value}) ->
      name = JSON.stringify(name)

      """
        #{name}: #{value}
      """

    return specialAttributes.concat attributeLines

  render: (node) ->
    if node.tag
      @tag(node)
    else
      @contents(node)

  contents: (node) ->
    {children, bufferedCode, unbufferedCode, text} = node

    if unbufferedCode
      indent = true

      contents = [unbufferedCode]
    else if bufferedCode
      contents = @buffer(bufferedCode)
    else if text
      contents = @buffer(JSON.stringify(text))
    else if node.tag
      contents = []
    else if node.comment
      # TODO: Create comment nodes
      return []
    else
      contents = []
      console.warn "No content for node:", node

    if children
      childContent = @renderNodes(children)

      if indent
        childContent = @indent(childContent.join("\n"))

      contents = contents.concat(childContent)

    return contents

  renderNodes: (nodes) ->
    [].concat.apply([], nodes.map(@render, this))

  tag: (node) ->
    {tag} = node

    @element tag, @attributes(node), @contents(node)

compile = (parseTree, {compiler, runtime, exports}={}) ->
  runtime ?=  "require" + "(\"jadelet\")"
  exports ?= "module.exports"

  items = util.renderNodes(parseTree)

  if exports
    exports = "#{exports} = "
  else
    exports = ""

  source = """
    #{exports}(data) ->
      "use strict"
      (->
        #{ROOT_NAME} = #{runtime}(this)
    #{util.indent(items.join("\n"), "    ")}
        return #{ROOT_NAME}.root
      ).call(data)
  """

  options = bare: true
  programSource = source

  program = compiler.compile programSource, options

  return program
