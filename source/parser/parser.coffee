# We generate a parser because we don't want to pull in the entirety of
# jison for the browser environment.

{node:o, create} = require "./grammar_dsl"

grammar =
  root: [
    o "lines",                                       -> yy.nodePath[0].children
  ]

  lines: [
    o "lines line"
    o "line"
  ]

  indentation: [
    o "",                                            -> 0
    o "indentationLevel"
  ]

  indentationLevel: [
    o "indentationLevel INDENT",                     -> $1 + 1
    o "INDENT",                                      -> 1
  ]

  line: [
    o "indentation lineMain end",                    -> yy.append($lineMain, $indentation)
    o "end",                                         -> yy.newline() if $end.newline
  ]

  lineMain: [
    o "tag rest",                                    -> yy.extend $tag, $rest
    o "tag",                                         -> $tag
    o "rest",                                        -> $rest
    o "COMMENT",                                     -> comment: $1
    o "FILTER",                                      -> filter: $1
    o "FILTER_LINE",                                 -> filterLine: $1
  ]

  end: [
    o "NEWLINE",                                     -> newline: true
  ]

  tag: [
    o "name tagComponents",                          -> $tagComponents.tag = $name; $tagComponents
    o "name attributes",                             -> tag: $name, attributes: $attributes
    o "name",                                        -> tag: $name
    o "tagComponents",                               -> yy.extend $tagComponents, tag: "div"
  ]

  tagComponents: [
    o "idComponent classComponents attributes",      -> id: $idComponent, classes: $classComponents, attributes: $attributes
    o "idComponent attributes",                      -> id: $idComponent, attributes: $attributes
    o "classComponents attributes",                  -> classes: $classComponents, attributes: $attributes
    o "idComponent classComponents",                 -> id: $idComponent, classes: $classComponents
    o "idComponent",                                 -> id: $idComponent
    o "classComponents",                             -> classes: $classComponents
  ]

  idComponent: [
    o "ID"
  ]

  classComponents: [
    o "classComponents CLASS",                       -> $1.concat $2
    o "CLASS",                                       -> [$1]
  ]

  attributes: [
    o "LEFT_PARENTHESIS attributePairs RIGHT_PARENTHESIS", -> $2
  ]

  attributePairs: [
    o "attributePairs SEPARATOR attributePair",      -> $attributePairs.concat $attributePair
    o "attributePair",                               -> [$attributePair]
  ]

  attributePair: [
    o "ATTRIBUTE EQUAL ATTRIBUTE_VALUE",             -> name: $1, value: $3
    o "AT_ATTRIBUTE",                                -> name: $1.substring(1), value: $1
  ]

  name: [
    o "TAG"
  ]

  rest: [
    o "BUFFERED_CODE",                               -> { bufferedCode: $BUFFERED_CODE }
    o "UNBUFFERED_CODE",                             -> { unbufferedCode: $UNBUFFERED_CODE }
    o "TEXT",                                        -> { text: $TEXT + "\n" }
  ]

operators = []

parser = create
  grammar: grammar
  operators: operators
  startSymbol: "root"

# The parser is incomplete at this stage, it needs to be fused with the yy runtime
# to operate.
exports.parser = parser
