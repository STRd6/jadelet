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

  filters:
    verbatim: (content, compiler) ->
      compiler.buffer '"""' + content.replace(/(#|")/g, "\\$1") + '"""'

    plain: (content, compiler) ->
      compiler.buffer JSON.stringify(content)

    coffeescript: (content, compiler) ->
      [content]

    javascript: (content, compiler) ->
      [
        "`"
        compiler.indent(content)
        "`"
      ]

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

    if attributes
      attributes = attributes.filter ({name, value}) ->
        if name is "class"
          classes.push value

          false
        else if name is "id"
          ids.push value

          false
        else
          true

    else
      attributes = []

    idsAndClasses = []

    if ids.length
      idsAndClasses.push "id: [#{ids.join(', ')}]"

    if classes.length
      idsAndClasses.push "class: [#{classes.join(', ')}]"

    attributeLines = attributes.map ({name, value}) ->
      name = JSON.stringify(name)

      """
        #{name}: #{value}
      """

    return idsAndClasses.concat attributeLines

  render: (node) ->
    {tag, filter, text} = node

    if tag
      @tag(node)
    else if filter
      @filter(node)
    else
      @contents(node)

  filter: (node) ->
    filterName = node.filter

    if filter = @filters[filterName]
      [].concat.apply([], @filters[filterName](node.content, this))
    else
      [
        "#{ROOT_NAME}.filter(#{JSON.stringify(filterName)}, #{JSON.stringify(node.content)})"
      ]

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
