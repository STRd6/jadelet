extend = Object.assign

# This is only in the build dir right now
lexer = require "./lexer"
{parser} = require "./parser"

# Here we attach the lexer to the parser and add our methods to construct the parse tree.
oldParse = parser.parse
extend parser,
  parse: (input) ->
    parser.lexer = lexer
    # Initialize shared state for gross hacks
    extend parser.yy,
      indent: 0
      nodePath: [{children: []}]
      filterIndent: undefined

    return oldParse.call(parser, input)

extend parser.yy,
  extend: extend

  newline: ->
    lastNode = @nodePath[@nodePath.length - 1]

    # TODO: Add newline nodes to tree to maintain
    # spacing

    if lastNode.filter
      @appendFilterContent(lastNode, "")

  # If we indent a nested section multiple times we'll have a gap
  # in the nodePath array, so to find the parent we need to
  # back up until we reach an existing node.
  lastParent: (indentation) ->
    while !(parent = @nodePath[indentation])
      indentation -= 1

    return parent

  append: (node, indentation=0) ->
    if node.filterLine
      lastNode = @nodePath[@nodePath.length - 1]
      @appendFilterContent(lastNode, node.filterLine)

      return

    parent = @lastParent(indentation)
    @appendChild parent, node

    index = indentation + 1
    @nodePath[index] = node
    @nodePath.length = index + 1

    return node

  appendChild: (parent, child) ->
    unless child.filter
      @filterIndent = undefined
      # Resetting back to initial state so we can handle
      # back to back filters
      @lexer.popState()

    parent.children ||= []
    parent.children.push child

  appendFilterContent: (filter, content) ->
    filter.content ||= ""
    filter.content += "#{content}\n"

module.exports = parser
