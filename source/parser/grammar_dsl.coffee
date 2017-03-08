# Jison DSL
# ---------

# The only dependency is on the **Jison.Parser**.
{Parser} = require 'jison'

# Since we're going to be wrapped in a function by Jison in any case, if our
# action immediately returns a value, we can optimize by removing the function
# wrapper and just returning the value directly.
unwrap = /^function\s*\(\)\s*\{\s*return\s*([\s\S]*);\s*\}/

# Our handy DSL for Jison grammar generation, thanks to
# [Tim Caswell](http://github.com/creationix). For every rule in the grammar,
# we pass the pattern-defining string, the action to run, and extra options,
# optionally. If no action is specified, we simply pass the value of the
# previous nonterminal.
node = (patternString, action, options) ->
  # Convert any series of two or more whitespace characters to a single space
  patternString = patternString.replace /\s{2,}/g, ' '

  # If there is no action return the pattern string
  unless action
    return [patternString, '$$ = $1;', options]

  action = if match = unwrap.exec action then match[1] else "(#{action}())"


  # Count the patterns
  patternCount = patternString.split(' ').length

  [patternString, "$$ = #{action};", options]

module.exports =
  node: node
  create: ({grammar, operators, startSymbol}) ->
    startSymbol ?= "root"

    # Finally, now that we have our **grammar** and our **operators**, we can create
    # our **Jison.Parser**. We do this by processing all of our rules, recording all
    # terminals (every symbol which does not appear as the name of a rule above)
    # as "tokens".
    tokens = []
    for name, alternatives of grammar
      grammar[name] = for alt in alternatives
        for token in alt[0].split ' '
          tokens.push token unless grammar[token]

        # !?
        alt[1] = "return #{alt[1]}" if name is startSymbol

        alt

    # Initialize the **Parser** with our list of terminal **tokens**, our **grammar**
    # rules, and the name of the root. Reverse the operators because Jison orders
    # precedence from low to high, and we have it high to low
    # (as in [Yacc](http://dinosaur.compilertools.net/yacc/index.html)).
    new Parser
      tokens: tokens.join ' '
      bnf: grammar
      operators: operators.reverse()
      startSymbol: startSymbol
