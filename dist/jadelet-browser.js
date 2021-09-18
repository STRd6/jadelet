(function(f){if(typeof exports==="object"&&typeof module!=="undefined"){module.exports=f()}else if(typeof define==="function"&&define.amd){define([],f)}else{var g;if(typeof window!=="undefined"){g=window}else if(typeof global!=="undefined"){g=global}else if(typeof self!=="undefined"){g=self}else{g=this}g.Jadelet = f()}})(function(){var define,module,exports;return (function(){function r(e,n,t){function o(i,f){if(!n[i]){if(!e[i]){var c="function"==typeof require&&require;if(!f&&c)return c(i,!0);if(u)return u(i,!0);var a=new Error("Cannot find module '"+i+"'");throw a.code="MODULE_NOT_FOUND",a}var p=n[i]={exports:{}};e[i][0].call(p.exports,function(r){var n=e[i][1][r];return o(n||r)},p,p.exports,r,e,n,t)}return n[i].exports}for(var u="function"==typeof require&&require,i=0;i<t.length;i++)o(t[i]);return o}return r})()({1:[function(require,module,exports){
(function(create, rules) {
  create(create, rules);
}(function(create, rules) {
  var RE_FLAGS, _names, decompile, fail, failExpected, failHintRegex, failIndex, fns, generate, getValue, hToS, invoke, loc, mapValue, maxFailPos, noteName, parse, preComputedRules, precompileHandler, precompute, precomputeRule, prettyPrint, toS, tokenHandler, validate;
  // Error tracking
  // Goal is zero allocations
  failExpected = Array(16);
  failIndex = 0;
  failHintRegex = /\S+|[^\S]+|$/y;
  maxFailPos = 0;
  fail = function(pos, expected) {
    if (pos < maxFailPos) {
      return;
    }
    if (pos > maxFailPos) {
      maxFailPos = pos;
      failIndex = 0;
    }
    failExpected[failIndex++] = expected;
  };
  // RegExp Flags
  // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp/RegExp
  // Would like to add 's', but that kills IE11
  RE_FLAGS = "uy";
  // Pretty print a string or RegExp literal
  // TODO: could expand to all rules?
  // Includes looking up the name
  prettyPrint = function(v) {
    var name, pv, s;
    // Would prefer to use -v.flags.length, but IE doesn't support .flags
    pv = v instanceof RegExp ? (s = v.toString(), s.slice(0, s.lastIndexOf('/') + 1)) : typeof v === "string" ? v === "" ? "EOF" : JSON.stringify(v) : v;
    if (name = _names.get(v)) {
      return `${name} ${pv}`;
    } else {
      return pv;
    }
  };
  // Lookup to get Rule names from precomputed rules
  _names = new Map();
  noteName = function(name, value) {
    if (name) {
      _names.set(value, name);
    }
    return value;
  };
  // Transforming Rules into a pre-computed form
  preComputedRules = null;
  precomputeRule = function(rule, out, name, compile) {
    var arg, data, handler, op, placeholder, result;
    // Replace fn lookup with actual reference
    if (Array.isArray(rule)) { // op, arg, handler triplet or pair
      [op, arg, handler] = rule;
      result = [
        fns[op],
        (function() {
          switch (op) {
            case "/":
            case "S":
              return arg.map(function(x) {
                return precomputeRule(x,
        null,
        name,
        compile);
              });
            case "*":
            case "+":
            case "?":
            case "!":
            case "&":
              return precomputeRule(arg,
        null,
        name + op,
        compile);
            case "R":
              return noteName(name,
        RegExp(arg,
        RE_FLAGS));
            case "L":
              return noteName(name,
        JSON.parse("\"" + arg + "\""));
            default:
              throw new Error(`Don't know how to pre-compute ${JSON.stringify(op)}`);
          }
        })(),
        compile(handler,
        op,
        name)
      ];
      if (out) {
        // Replace placeholder content with actual content
        out[0] = result[0];
        out[1] = result[1];
        out[2] = result[2];
        return out;
      }
      return result; // rule name as a string
    } else {
      // Replace rulename string lookup with actual reference
      if (preComputedRules[rule]) {
        return preComputedRules[rule];
      } else {
        preComputedRules[rule] = placeholder = out || [];
        data = rules[rule];
        if (data == null) {
          throw new Error(`No rule with name ${JSON.stringify(rule)}`);
        }
        return precomputeRule(data, placeholder, rule, compile);
      }
    }
  };
  getValue = function(x) {
    return x.value;
  };
  // Return a function precompiled for the given handler
  // Handlers map result values into language primitives
  precompileHandler = function(handler, op) {
    var fn;
    if (handler != null ? handler.f : void 0) {
      fn = Function("$loc", "$0", "$1", "$2", "$3", "$4", "$5", "$6", "$7", "$8", "$9", handler.f);
      // Sequence spreads arguments out, all others only have one match
      // (terminals, choice, assertions, ?) or receive a single array (+, *)
      if (op === "S") {
        return function(s) {
          return fn.apply(null, [s.loc, s.value].concat(s.value));
        };
      } else if (op === "R") {
        return function(s) {
          return fn.apply(null, [s.loc].concat(s.value));
        };
      } else {
        return function(s) {
          return fn(s.loc, s.value, s.value);
        };
      }
    } else {
      if (op === "R") {
        if (handler != null) {
          return function(s) {
            return mapValue(handler, s.value); // Whole match
          };
        } else {
          return function(s) {
            return s.value[0];
          };
        }
      } else if (op === "S") {
        if (handler != null) {
          return function(s) {
            return mapValue(handler, [s.value].concat(s.value));
          };
        } else {
          return function(s) {
            return s.value;
          };
        }
      } else {
        return function(s) {
          return mapValue(handler, s.value);
        };
      }
    }
  };
  precompute = function(rules, compile) {
    var first;
    preComputedRules = {};
    first = Object.keys(rules)[0];
    preComputedRules[first] = precomputeRule(first, null, first, compile);
    return preComputedRules;
  };
  invoke = function(state, data) {
    var arg, fn, mapping, result;
    // console.log state.pos, prettyPrint data[1]
    [fn, arg, mapping] = data;
    result = fn(state, arg);
    if (mapping == null) {
      mapping = getValue;
    }
    if (result) {
      result.value = mapping(result);
    }
    return result;
  };
  // Converts a handler mapping structure into the mapped value
  // -> 1 (first item of sequence)
  // -> [2, 1] (array containing second and first item in that order)
  // -> [1, [4, 3]] (pair containing first, and a pair with 4th and 3rd item)
  // -> "yo" (literal "yo)
  // TODO: Map to object literals in a similar way?
  mapValue = function(mapping, value) {
    switch (typeof mapping) {
      case "number":
        return value[mapping];
      case "string":
        return mapping;
      case "object":
        if (Array.isArray(mapping)) {
          return mapping.map(function(n) {
            return mapValue(n, value);
          });
        } else {
          throw new Error("non-array object mapping");
        }
        break;
      case "undefined":
        return value;
      default:
        throw new Error("Unknown mapping type");
    }
  };
  // These are primitive functions that rules refer to
  fns = {
    L: function(state, str) { // String literal
      var input, length, pos;
      ({input, pos} = state);
      ({length} = str);
      if (input.substr(pos, length) === str) {
        return {
          loc: {
            pos: pos,
            length: length
          },
          pos: pos + length,
          value: str
        };
      } else {
        return fail(pos, str);
      }
    },
    // Match a regexp at state's position in the input
    // returns new position and value of matching string
    R: function(state, regExp) { // Regexp Literal
      var input, l, m, pos, v;
      ({input, pos} = state);
      regExp.lastIndex = state.pos;
      if (m = input.match(regExp)) {
        v = m[0];
      }
      if (v != null) {
        l = v.length;
        return {
          loc: {
            pos: pos,
            length: l
          },
          pos: pos + l,
          value: m
        };
      } else {
        return fail(pos, regExp);
      }
    },
    // a b c ...
    // a followed by b ...
    S: function(state, terms) {
      var i, input, l, pos, r, results, s, value;
      ({input, pos} = state);
      results = [];
      s = pos;
      i = 0;
      l = terms.length;
      while (true) {
        r = invoke({input, pos}, terms[i++]);
        if (r) {
          ({pos, value} = r);
          results.push(value);
        } else {
          return;
        }
        if (i >= l) {
          break;
        }
      }
      return {
        loc: {
          pos: s,
          length: pos - s
        },
        pos: pos,
        value: results
      };
    },
    // a / b / c / ...
    // Proioritized choice
    // roughly a(...) || b(...) in JS, generalized to reduce, optimized to loop
    "/": function(state, terms) {
      var i, l, r;
      i = 0;
      l = terms.length;
      while (true) {
        r = invoke(state, terms[i++]);
        if (r) {
          return r;
        }
        if (i >= l) {
          break;
        }
      }
    },
    // a? zero or one
    "?": function(state, term) {
      return invoke(state, term) || state;
    },
    // a*
    // NOTE: zero length repetitions (where position doesn't advance) return
    // an empty array of values. A repetition where the position doesn't advance
    // would be an infinite loop, so this avoids that problem cleanly.
    // TODO: Think through how this interacts with & and ! predicates
    "*": function(state, term) {
      var input, pos, prevPos, r, results, s, value;
      ({input, pos} = state);
      s = pos;
      results = [];
      while (true) {
        prevPos = pos;
        r = invoke({input, pos}, term);
        if (r == null) {
          break;
        }
        ({pos, value} = r);
        if (pos === prevPos) {
          break;
        } else {
          results.push(value);
        }
      }
      return {
        loc: {
          pos: s,
          length: pos - s
        },
        pos: pos,
        value: results
      };
    },
    // a+ one or more
    "+": function(state, term) {
      var first, input, pos, rest, s;
      ({
        input,
        pos: s
      } = state);
      first = invoke(state, term);
      if (first == null) {
        return;
      }
      ({pos} = first);
      ({pos} = rest = invoke({input, pos}, [fns["*"], term]));
      rest.value.unshift(first.value);
      return {
        loc: {
          pos: s,
          length: pos - s
        },
        value: rest.value,
        pos: pos
      };
    },
    "!": function(state, term) {
      var newState;
      newState = invoke(state, term);
      if (newState != null) {

      } else {
        return state;
      }
    },
    "&": function(state, term) {
      var newState;
      newState = invoke(state, term);
      // If the assertion doesn't advance the position then it is failed.
      // A zero width assertion always succeeds and is useless
      if (newState.pos === state.pos) {

      } else {
        return state;
      }
    }
  };
  // Compute the line and column number of a position (used in error reporting)
  loc = function(input, pos) {
    var column, line, rawPos;
    rawPos = pos;
    [line, column] = input.split(/\n|\r\n|\r/).reduce(function([row, col], line) {
      var l;
      l = line.length + 1;
      if (pos > l) {
        pos -= l;
        return [row + 1, 1];
      } else if (pos >= 0) {
        col += pos;
        pos = -1;
        return [row, col];
      } else {
        return [row, col];
      }
    }, [1, 1]);
    return `${line}:${column}`;
  };
  validate = function(input, result, {filename}) {
    var expectations, hint, l;
    if ((result != null) && result.pos === input.length) {
      return result.value;
    }
    expectations = Array.from(new Set(failExpected.slice(0, failIndex)));
    l = loc(input, maxFailPos);
    // The parse completed with a result but there is still input
    if ((result != null) && result.pos > maxFailPos) {
      l = loc(input, result.pos);
      throw new Error(`Unconsumed input at ${l}

${input.slice(result.pos)}
`);
    } else if (expectations.length) {
      failHintRegex.lastIndex = maxFailPos;
      [hint] = input.match(failHintRegex);
      if (hint.length) {
        hint = prettyPrint(hint);
      } else {
        hint = "EOF";
      }
      throw new Error(`${filename}:${l} Failed to parse
Expected:
\t${expectations.map(prettyPrint).join("\n\t")}
Found: ${hint}`);
    } else {
      throw new Error(`Unconsumed input at ${l}

${input.slice(result.pos)}
`);
    }
  };
  parse = function(input, opts = {}) {
    var result, state;
    if (typeof input !== "string") {
      throw new Error("Input must be a string");
    }
    if (opts.filename == null) {
      opts.filename = "[stdin]";
    }
    // Init error tracking
    failIndex = 0;
    maxFailPos = 0;
    state = {
      input,
      pos: 0
    };
    // TODO: This breaks pre-computed rules for subsequent non-tokenized calls
    if (opts.tokenize) {
      precompute(rules, tokenHandler);
    }
    result = invoke(state, Object.values(preComputedRules)[0]);
    return validate(input, result, opts);
  };
  // Ignore result handlers and return type tokens based on rule names
  tokenHandler = function(handler, op, name) {
    return function({value}) {
      if (value == null) {
        return value;
      }
      switch (op) {
        case "S":
          return {
            type: name,
            value: value.filter(function(v) {
              return v != null;
            }).reduce(function(a, b) {
              return a.concat(b);
            }, [])
          };
        case "L":
        case "R": // Terminals
          return {
            type: name,
            value: value
          };
        case "*":
        case "+":
          return {
            type: op,
            value: value
          };
        case "?":
        case "/":
          return value;
        case "!":
        case "&":
          return {
            type: op + name,
            value: value
          };
      }
    };
  };
  // Generate the source for a new parser for the given rules
  // if vivify is true return a parser object from the evaluated source
  generate = function(rules, vivify) {
    var m, src;
    src = `(function(create, rules) {
  create(create, rules);
}(${create.toString()}, ${JSON.stringify(rules)}));
`;
    if (vivify) {
      m = {};
      Function("module", src)(m);
      return m.exports;
    } else {
      return src;
    }
  };
  // handler to source
  hToS = function(h) {
    if (h == null) {
      return "";
    }
    return " -> " + (function() {
      switch (typeof h) {
        case "number":
          return h;
        case "string":
          return JSON.stringify(h);
        case "object":
          if (Array.isArray(h)) {
            return JSON.stringify(h);
          } else {
            return `\n${h.f.replace(/^|\n/g, "$&    ")}`;
          }
      }
    })();
  };
  // toS and decompile generate a source document from the rules AST
  toS = function(rule, depth = 0) {
    var f, h, terms;
    if (Array.isArray(rule)) {
      f = rule[0];
      h = rule[2];
      switch (f) {
        case "*":
        case "+":
        case "?":
          return toS(rule[1], depth + 1) + f + hToS(h);
        case "&":
        case "!":
          return f + toS(rule[1], depth + 1);
        case "L":
          return '"' + rule[1] + '"' + hToS(h);
        case "R":
          return '/' + rule[1] + '/' + hToS(h);
        case "S":
          terms = rule[1].map(function(i) {
            return toS(i, depth + 1);
          });
          if (depth < 1) {
            return terms.join(" ") + hToS(h);
          } else {
            return "( " + terms.join(" ") + " )";
          }
          break;
        case "/":
          terms = rule[1].map(function(i) {
            return toS(i, depth && depth + 1);
          });
          if (depth === 0 && !h) {
            return terms.join("\n  ");
          } else {
            return "( " + terms.join(" / ") + " )" + hToS(h); // String name of the rule
          }
      }
    } else {
      return rule;
    }
  };
  // Convert the rules to source text in hera grammar
  decompile = function(rules) {
    return Object.keys(rules).map(function(name) {
      var value;
      value = toS(rules[name]);
      return `${name}\n  ${value}\n`;
    }).join("\n");
  };
  // Pre compile the rules and handler functions
  precompute(rules, precompileHandler);
  return module.exports = {
    decompile: decompile,
    parse: parse,
    generate: generate,
    rules: rules
  };
}, {"Template":["S",[["?","__"],["*","Line"]],{"f":"var top = a => a[a.length-1];\nfunction reduceLines(lines) {\n  var depth = 0;\n  var stack = [[]];\n  var firstIndent = 0;\n  lines.forEach( ([indent, line]) => {\n    if (firstIndent === 0 && indent > depth + 1) {\n      firstIndent = indent;\n      indent = 1;\n    }\n    indent = indent > firstIndent ? indent - firstIndent : indent;\n    if (Array.isArray(line)) {\n      line[1] = collectAttributes(line[1])\n    }\n    if (depth+1 === indent) {\n      // We're adding to the content of the last element in the current stack\n      stack.push(top(top(stack))[2])\n    } else if ( indent > depth) {\n      throw new Error(\"Indented too far\")\n    } else if (indent < depth) {\n      stack = stack.slice(0, indent + 1)\n    }\n    depth = indent\n    top(stack).push(line)\n  })\n  return stack[0]\n}\nfunction collectAttributes(attributesArray) {\n  return attributesArray.reduce((o, [key, value]) => {\n    if (key === \"id\" || key === \"class\" || key === \"style\") {\n      var p = o[key] || (o[key] = [])\n      p.push(value)\n    } else {\n      o[key] = value\n    }\n    return o\n  }, {})\n}\nfunction pretty(lines) {\n  return lines.map(line =>\n    JSON.stringify(line)\n  )\n}\nvar reduced = reduceLines($2);\nif (reduced.length != 1) {\n  throw new Error(\"Must have exactly one root node.\");\n}\nreturn reduced[0];"}],"Line":["S",["Indent","LineBody","EOS"],[1,2]],"LineBody":["/",[["S",["Tag",["?","DeprecatedEquals"],"_","RestOfLine"],{"f":"$1[2].push($4)\nreturn $1"}],["S",["Tag",["?","_"]],1],["S",[["L","|"],["?",["L"," "]],"RestOfLine"],{"f":"return $3 + \"\\n\";"}],["S",[["?",["S",["DeprecatedEquals","_"]]],"RestOfLine"],2]]],"RestOfLine":["R","[^\\n\\r]*",{"f":"// TODO: Handle runs of text with bound content inside\nif ($0.slice(0,1) === \"@\") {\n  return {\n    bind: $0.slice(1)\n  }\n} else {\n  return $0\n}"}],"DeprecatedEquals":["L","=",{"f":"console.warn(\"'= <content>' is deprecated, you can remove the '=' without issue.\")"}],"Tag":["/",[["S",["TagName","OptionalIds","OptionalClasses","OptionalAttributes"],{"f":"return [\n  $1,\n  $2.concat($3, $4),\n  [],\n]"}],["S",["Ids","OptionalClasses","OptionalAttributes"],{"f":"return [\n  \"div\",\n  $1.concat($2, $3),\n  [],\n]"}],["S",["Classes","OptionalAttributes"],{"f":"return [\n  \"div\",\n  $1.concat($2),\n  [],\n]"}]]],"OptionalClasses":["/",["Classes",["L","",{"f":"return []"}]]],"Classes":["+","Class"],"Class":["/",[["S",[["L","."],"Identifier"],{"f":"return [\"class\", $2]"}],["S",[["L","."],["!","Identifier"]],{"f":"throw \"Expected a class name\""}],"IdError"]],"OptionalIds":["?","Ids",{"f":"return $1 || []"}],"Ids":["S",["Id"],{"f":"return [ $1 ]"}],"Id":["/",[["S",[["L","#"],"Identifier"],{"f":"return [\"id\", $2]"}],["S",[["L","#"],["!","Identifier"]],{"f":"throw \"Expected an id name\""}]]],"IdError":["L","#",{"f":"throw \"Ids must appear before classes and attributes. Elements can only have one id.\""}],"ClassError":["L",".",{"f":"throw \"Classes cannot appear after attributes.\""}],"TagName":["/",[["S",["Identifier"],1],["S",[["L"," "],"Identifier"],2]]],"OptionalAttributes":["/",[["S",[["L","("],["?","__"],["+","Attribute"],["L",")"],["?","IdError"],["?","ClassError"]],{"f":"return $3"}],["L","(",{"f":"throw \"Invalid attributes\""}],["L","",{"f":"return []"}]]],"Attribute":["/",[["S",["AtIdentifier",["?","__"]],{"f":"return [$1.bind, $1]"}],["S",["EqBinding",["?","__"]],1],["S",["Identifier",["?","__"]],{"f":"return [$1, \"\"]"}]]],"AtIdentifier":["S",[["L","@"],"Identifier"],{"f":"return {\n  bind: $2\n}"}],"EqBinding":["S",["Identifier",["L","="],["/",["AtIdentifier","Value"]]],[1,3]],"Identifier":["R","[a-zA-Z][a-zA-Z0-9-]*"],"Indent":["*",["/",[["L","  "],["L","\\t"]]],{"f":"return $1.length"}],"_":["R","[ \\t]+"],"__":["+",["/",[["R","[ \\t]"],"EOL"]]],"Value":["/",[["S",[["L","\\\""],["*","DoubleStringCharacter"],["L","\\\""]],{"f":"return $2.join(\"\")"}],["S",[["L","'"],["*","SingleStringCharacter"],["L","'"]],{"f":"return $2.join(\"\")"}],"Number"]],"DoubleStringCharacter":["/",[["S",[["!",["/",[["L","\\\""],["L","\\\\"]]]],["R","."]],2],["S",[["L","\\\\"],"EscapeSequence"],2]]],"SingleStringCharacter":["/",[["S",[["!",["/",[["L","'"],["L","\\\\"]]]],["R","."]],2],["S",[["L","\\\\"],"EscapeSequence"],2]]],"EscapeSequence":["/",[["L","'"],["L","\\\""],["L","\\\\"],["R",".",{"f":"return \"\\\\\" + $0"}]]],"Number":["/",[["R","-?[0-9]+\\.[0-9]+"],["R","-?[0-9]+"]]],"EOS":["/",[["S",[["+",["S",[["?","_"],"EOL"]]],"_","EOF"]],["+",["S",[["?","_"],"EOL"]]],"EOF"]],"EOL":["/",[["L","\\r\\n"],["L","\\n"],["L","\\r"]]],"EOF":["!",["R","[\\s\\S]"]]}));

},{}],2:[function(require,module,exports){
// Generated by CoffeeScript 2.5.1
"use strict";
var Jadelet, Observable, append, attachCleaner, bindEvent, bindObservable, bindSplat, bindValue, dispose, elementCleaners, elementRefCounts, eventNames, forEach, get, isEvent, isObject, isString, observeAttribute, observeContent, parser, release, remove, render, retain, splat;

Observable = require("o_0");

forEach = Array.prototype.forEach;

// To clean up listeners we keep a map of DOM elements and what listeners are bound to them
// when we dispose an element we must traverse its children and clean them up too
// After we remove the listeners we must then remove the element from the map
elementCleaners = new WeakMap();

elementRefCounts = new WeakMap();

retain = function(element) {
  var count;
  count = elementRefCounts.get(element) || 0;
  elementRefCounts.set(element, count + 1);
};

release = function(element) {
  var count;
  count = elementRefCounts.get(element) || 0;
  count--;
  if (count > 0) {
    elementRefCounts.set(element, count);
  } else {
    elementRefCounts.delete(element);
    dispose(element);
  }
};

// Disposing an element executes the cleanup for all it's children. If a child
// element should be retained you must mark it explicitly to prevent its
// observables from unbinding.
dispose = function(element) {
  var children, ref;
  // Recurse into children
  children = element.children;
  if (children != null) {
    forEach.call(children, dispose);
  }
  if ((ref = elementCleaners.get(element)) != null) {
    ref.forEach(function(cleaner) {
      cleaner();
      elementCleaners.delete(element);
    });
  }
};

attachCleaner = function(element, cleaner) {
  var cleaners;
  if (typeof cleaner !== 'function') {
    throw new Error("whoops");
  }
  cleaners = elementCleaners.get(element);
  if (cleaners) {
    cleaners.push(cleaner);
  } else {
    elementCleaners.set(element, [cleaner]);
  }
};

// Combined touch and animation events here even though it's sloppy it saves a few bytes
// later we should put all the smarts about what is an event or not in the compiler
eventNames = /^on(touch|animation|transition)(start|iteration|move|end|cancel)$/;

isEvent = function(name, element) {
  return name.match(eventNames) || name in element;
};

// value is either a literal string or an object shaped
// bind: stringKey
// exceptions for id, class, and style. They are arrays of such strings
// literals and binding objects
observeAttribute = function(element, context, name, value) {
  var bind;
  switch (name) {
    case "id":
      bindSplat(element, context, value, function(ids) {
        var length;
        length = ids.length;
        if (length) {
          element.id = ids[length - 1];
        } else {
          element.removeAttribute("id");
        }
      });
      break;
    case "class":
      bindSplat(element, context, value, function(classes) {
        var className;
        className = classes.join(" ");
        if (className) {
          element.className = className;
        } else {
          element.removeAttribute("class");
        }
      });
      break;
    case "style":
      bindSplat(element, context, value, function(styles) {
        // Remove any leftover styles
        element.removeAttribute("style");
        styles.forEach(function(style) {
          if (isObject(style)) {
            return Object.assign(element.style, style);
          } else {
            return element.setAttribute("style", style);
          }
        });
      });
      break;
    case "value":
      bindValue(element, value, context);
      break;
    case "checked":
      if (value && isObject(value)) {
        ({bind} = value);
        element.onchange = function() {
          if (typeof context[bind] === "function") {
            context[bind](element.checked);
          }
        };
      }
      bindObservable(element, value, context, function(newValue) {
        element.checked = newValue;
      });
      break;
    default:
      // Handle click=@method
      if (isEvent(`on${name}`, element)) {
        // It doesn't make sense for events to not be bound
        bindEvent(element, name, value.bind, context);
      } else {
        bindObservable(element, value, context, function(newValue) {
          if ((newValue != null) && newValue !== false) {
            element.setAttribute(name, newValue);
          } else {
            element.removeAttribute(name);
          }
        });
      }
  }
};

// To bind an observable precisely to the site where it is
// and to be able to clean up we need to create a fresh
// Observable stack. Since the observable re-computes
// when any of its dependencies change it will refresh the update
// with the new value. To clean up we release the dependencies of
// our computed observable. We store the observables to clean up
// on a map keyed by the element.
bindObservable = function(element, value, context, update) {
  var bind, observable;
  // If the value is a simple string then simply set it and exit
  // No point in creating an observable if it isn't a binding
  if (isString(value)) {
    return update(value);
  } else if (typeof value === 'function') {
    observable = Observable(function() {
      update(value.call(context));
    });
  } else {
    ({bind} = value);
    observable = Observable(function() {
      update(get(context[bind], context));
    });
  }
  // return if no dependencies, no need to attach cleaners
  if (observable._observableDependencies.size === 0) {
    return;
  }
  // Release the observable's dependencies when this element is cleaned up
  attachCleaner(element, observable.releaseDependencies);
};

bindValue = function(element, value, context) {
  var bind;
  // Because firing twice with the same value is idempotent just binding both
  // oninput and onchange handles the widest range of inputs and browser
  // inconsistencies.
  if (value && typeof value === "object") {
    ({bind} = value);
    element.oninput = element.onchange = function() {
      if (typeof context[bind] === "function") {
        context[bind](element.value);
      }
    };
  }
  bindObservable(element, value, context, function(newValue) {
    if (element.value !== newValue) {
      element.value = newValue;
    }
  });
};

bindEvent = function(element, name, binding, context) {
  var handler;
  handler = context[binding];
  if (typeof handler === 'function') {
    element.addEventListener(name, handler.bind(context));
  }
};

bindSplat = function(element, context, sources, update) {
  bindObservable(element, (function() {
    return splat(sources, context);
  }), context, update);
};

observeContent = function(element, context, contentArray, namespace) {
  var count, tracker;
  // Map the content array into into an elements array (can be more or less,
  // essentially a flatmap) Keep track of observables, only update the proper
  // places when observables change.
  tracker = [];
  count = 0;
  contentArray.forEach(function(astNode, index) {
    var length, previousLength;
    // Track the child index this content starts on
    tracker[index] = count;
    if (Array.isArray(astNode)) {
      element.appendChild(render(astNode, context, namespace));
      count++;
    } else if (isString(astNode)) {
      element.appendChild(document.createTextNode(astNode));
      count++;
    // Content Binding
    } else if (isObject(astNode)) {
      // Total number of items added
      // how many we need to remove on cleanup
      length = previousLength = 0;
      // track element indices
      // update and rebase index on change
      bindObservable(element, astNode, context, function(value) {
        var beforeTarget, child, delta, i, pos, toRelease;
        previousLength = length;
        pos = tracker[index];
        beforeTarget = element.childNodes[pos + length];
        toRelease = new Array(length);
        // Remove previously added nodes
        i = 0;
        while (i < length) {
          child = element.childNodes[pos];
          element.removeChild(child);
          toRelease[i] = child;
          i++;
        }
        // Append New
        length = append(element, value, beforeTarget);
        // Relase after appending so if a node was re-added it won't hit zero
        // in its refcount and be prematurely disposed
        i = 0;
        while (i < previousLength) {
          child = toRelease[i];
          release(child);
          i++;
        }
        // Rebase downstream indices
        delta = length - previousLength;
        i = index + 1;
        while (i < tracker.length) {
          tracker[i] += delta;
          i++;
        }
      });
      count += length;
    } else {
      throw new Error("oof");
    }
  });
};

// Append nodes to an element, return the total number appended
append = function(element, item, beforeTarget) {
  var el;
  if (item == null) { // Skip nulls
    return 0;
  } else if (Array.isArray(item)) {
    return item.map(function(item) {
      return append(element, item, beforeTarget);
    }).reduce(function(a, b) {
      return a + b;
    }, 0);
  } else if (item instanceof Node) {
    retain(item);
    element.insertBefore(item, beforeTarget);
  } else if ((el = item.element) instanceof Node) {
    retain(el);
    element.insertBefore(el, beforeTarget);
  } else {
    element.insertBefore(document.createTextNode(item), beforeTarget);
  }
  return 1;
};

remove = function(element, child) {
  element.removeChild(child);
  return release(child);
};

isObject = function(x) {
  return typeof x === "object";
};

isString = function(x) {
  return typeof x === "string";
};

splat = function(sources, context) {
  return sources.map(function(source) {
    if (isString(source)) {
      return source;
    } else {
      return get(context[source.bind], context);
    }
  }).reduce(function(a, b) {
    return a.concat(b);
  }, []).filter(function(x) {
    return x != null;
  });
};

get = function(x, context) {
  if (typeof x === 'function') {
    return x.call(context);
  } else {
    return x;
  }
};

render = function(astNode, context = {}, namespace) {
  var attributes, children, element, tag;
  [tag, attributes, children] = astNode;
  // This namespace is only for svg support though it may be expanded in the
  // future. The idea is to set the namespace if the tag name is 'svg' and to
  // pass that namespace down to all children of the tag. Other elements won't
  // have a namespace and will render using the usual `createElement`.
  if (tag === "svg" && !namespace) {
    namespace = "http://www.w3.org/2000/svg";
  }
  if (namespace) {
    element = document.createElementNS(namespace, tag);
  } else {
    element = document.createElement(tag);
  }
  // We populate the content first so that value binding for `select` tags
  // works properly.
  observeContent(element, context, children, namespace);
  Object.keys(attributes).forEach(function(name) {
    observeAttribute(element, context, name, attributes[name]);
  });
  return element;
};

parser = require("./jadelet-parser");

module.exports = Jadelet = {
  compile: function(source, opts = {}) {
    var ast, exports, runtime;
    ast = Jadelet.parse(source);
    runtime = opts.runtime || "require('jadelet')";
    exports = opts.exports || "module.exports";
    return `${exports} = ${runtime}.exec(${JSON.stringify(ast)});`;
  },
  parse: parser.parse,
  parser: parser,
  exec: function(ast) {
    if (typeof ast === "function") {
      return ast;
    }
    if (typeof ast === "string") {
      ast = Jadelet.parse(ast);
    }
    return function(context) {
      return render(ast, context);
    };
  },
  Observable: Observable,
  _elementCleaners: elementCleaners,
  dispose: dispose,
  retain: retain,
  release: release
};

},{"./jadelet-parser":1,"o_0":3}],3:[function(require,module,exports){
(function (global){(function (){
// Generated by CoffeeScript 1.12.6

/*
Observable
==========

`Observable` allows for observing arrays, functions, and objects.

Function dependencies are automagically observed.

Standard array methods are proxied through to the underlying array.
 */

(function() {
  "use strict";
  var Observable, PROXY_LENGTH, copy, extend, last, magicDependency, noop, remove, tryCallWithFinallyPop,
    slice = [].slice;

  module.exports = Observable = function(value, context) {
    var changed, fn, listeners, notify, self;
    if (typeof (value != null ? value.observe : void 0) === "function") {
      return value;
    }
    listeners = [];
    notify = function(newValue) {
      return copy(listeners).forEach(function(listener) {
        return listener(newValue);
      });
    };
    if (typeof value === 'function') {
      fn = value;
      self = function() {
        magicDependency(self);
        return value;
      };
      self.releaseDependencies = function() {
        var ref;
        return (ref = self._observableDependencies) != null ? ref.forEach(function(observable) {
          return observable.stopObserving(changed);
        }) : void 0;
      };
      changed = function() {
        var observableDependencies;
        observableDependencies = new Set;
        value = tryCallWithFinallyPop(observableDependencies, fn, context);
        self.releaseDependencies();
        self._observableDependencies = observableDependencies;
        observableDependencies.forEach(function(observable) {
          return observable.observe(changed);
        });
        return notify(value);
      };
      changed();
    } else {
      self = function(newValue) {
        if (arguments.length > 0) {
          if (value !== newValue) {
            value = newValue;
            notify(newValue);
          }
        } else {
          magicDependency(self);
        }
        return value;
      };
      self.releaseDependencies = noop;
    }
    if (Array.isArray(value)) {
      ["concat", "every", "filter", "forEach", "indexOf", "join", "lastIndexOf", "map", "reduce", "reduceRight", "slice", "some"].forEach(function(method) {
        return self[method] = function() {
          var args;
          args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
          magicDependency(self);
          return value[method].apply(value, args);
        };
      });
      ["pop", "push", "reverse", "shift", "splice", "sort", "unshift"].forEach(function(method) {
        return self[method] = function() {
          var args, returnValue;
          args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
          returnValue = value[method].apply(value, args);
          notify(value);
          return returnValue;
        };
      });
      if (PROXY_LENGTH) {
        Object.defineProperty(self, 'length', {
          get: function() {
            magicDependency(self);
            return value.length;
          },
          set: function(length) {
            var returnValue;
            returnValue = value.length = length;
            notify(value);
            return returnValue;
          }
        });
      }
      extend(self, {
        remove: function(object) {
          var index, returnValue;
          index = value.indexOf(object);
          if (index >= 0) {
            returnValue = value.splice(index, 1)[0];
            notify(value);
            return returnValue;
          }
        },
        get: function(index) {
          magicDependency(self);
          return value[index];
        },
        first: function() {
          magicDependency(self);
          return value[0];
        },
        last: function() {
          magicDependency(self);
          return value[value.length - 1];
        },
        size: function() {
          magicDependency(self);
          return value.length;
        }
      });
    }
    extend(self, {
      listeners: listeners,
      observe: function(listener) {
        return listeners.push(listener);
      },
      stopObserving: function(fn) {
        return remove(listeners, fn);
      },
      toggle: function() {
        return self(!value);
      },
      increment: function(n) {
        if (n == null) {
          n = 1;
        }
        return self(value + n);
      },
      decrement: function(n) {
        if (n == null) {
          n = 1;
        }
        return self(value - n);
      },
      toString: function() {
        return "Observable(" + value + ")";
      }
    });
    return self;
  };

  extend = Object.assign;

  global.OBSERVABLE_ROOT_HACK = [];

  magicDependency = function(self) {
    var observerSet;
    observerSet = last(global.OBSERVABLE_ROOT_HACK);
    if (observerSet) {
      return observerSet.add(self);
    }
  };

  tryCallWithFinallyPop = function(observableDependencies, fn, context) {
    global.OBSERVABLE_ROOT_HACK.push(observableDependencies);
    try {
      return fn.call(context);
    } finally {
      global.OBSERVABLE_ROOT_HACK.pop();
    }
  };

  remove = function(array, value) {
    var index;
    index = array.indexOf(value);
    if (index >= 0) {
      return array.splice(index, 1)[0];
    }
  };

  copy = function(array) {
    return array.concat([]);
  };

  last = function(array) {
    return array[array.length - 1];
  };

  noop = function() {};

  try {
    Object.defineProperty((function() {}), 'length', {
      get: noop,
      set: noop
    });
    PROXY_LENGTH = true;
  } catch (error) {
    PROXY_LENGTH = false;
  }

}).call(this);

}).call(this)}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{}]},{},[2])(2)
});
