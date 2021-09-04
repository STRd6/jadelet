(function () {
  var Observable = (function () {
    "use strict";
    var Observable, PROXY_LENGTH, copy, global, last, magicDependency, noop, remove,
      __slice = [].slice;

    global = self;

    Observable = function (value, context) {
      var changed, fn, listeners, notify, self;
      if (typeof (value != null ? value.observe : void 0) === "function") {
        return value;
      }
      listeners = [];
      notify = function (newValue) {
        self._value = newValue;
        return copy(listeners).forEach(function (listener) {
          return listener(newValue);
        });
      };
      if (typeof value === 'function') {
        fn = value;
        self = function () {
          magicDependency(self);
          return value;
        };
        self.releaseDependencies = function () {
          var _ref;
          return (_ref = self._observableDependencies) != null ? _ref.forEach(function (observable) {
            return observable.stopObserving(changed);
          }) : void 0;
        };
        changed = function () {
          var observableDependencies;
          observableDependencies = new Set;
          global.OBSERVABLE_ROOT_HACK.push(observableDependencies);
          try {
            value = fn.call(context);
          } finally {
            global.OBSERVABLE_ROOT_HACK.pop();
          }
          self.releaseDependencies();
          self._observableDependencies = observableDependencies;
          observableDependencies.forEach(function (observable) {
            return observable.observe(changed);
          });
          return notify(value);
        };
        changed();
      } else {
        self = function (newValue) {
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
        self._value = value;
      }
      if (Array.isArray(value)) {
        ["concat", "every", "filter", "forEach", "indexOf", "join", "lastIndexOf", "map", "reduce", "reduceRight", "slice", "some"].forEach(function (method) {
          return self[method] = function () {
            var args;
            args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
            magicDependency(self);
            return value[method].apply(value, args);
          };
        });
        ["pop", "push", "reverse", "shift", "splice", "sort", "unshift"].forEach(function (method) {
          return self[method] = function () {
            var args, returnValue;
            args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
            returnValue = value[method].apply(value, args);
            notify(value);
            return returnValue;
          };
        });
        if (PROXY_LENGTH) {
          Object.defineProperty(self, 'length', {
            get: function () {
              magicDependency(self);
              return value.length;
            },
            set: function (length) {
              var returnValue;
              returnValue = value.length = length;
              notify(value);
              return returnValue;
            }
          });
        }
        Object.assign(self, {
          remove: function (object) {
            var index, returnValue;
            index = value.indexOf(object);
            if (index >= 0) {
              returnValue = value.splice(index, 1)[0];
              notify(value);
              return returnValue;
            }
          },
          get: function (index) {
            magicDependency(self);
            return value[index];
          },
          first: function () {
            magicDependency(self);
            return value[0];
          },
          last: function () {
            magicDependency(self);
            return value[value.length - 1];
          },
          size: function () {
            magicDependency(self);
            return value.length;
          }
        });
      }
      Object.assign(self, {
        listeners: listeners,
        observe: function (listener) {
          return listeners.push(listener);
        },
        stopObserving: function (fn) {
          return remove(listeners, fn);
        },
        toggle: function () {
          return self(!value);
        },
        increment: function (n) {
          if (n == null) {
            n = 1;
          }
          return self(Number(value) + n);
        },
        decrement: function (n) {
          if (n == null) {
            n = 1;
          }
          return self(Number(value) - n);
        },
        toString: function () {
          return "Observable(" + value + ")";
        }
      });
      return self;
    };

    self.OBSERVABLE_ROOT_HACK = [];

    magicDependency = function (self) {
      var observerSet;
      observerSet = last(self.OBSERVABLE_ROOT_HACK);
      if (observerSet) {
        return observerSet.add(self);
      }
    };

    remove = function (array, value) {
      var index;
      index = array.indexOf(value);
      if (index >= 0) {
        return array.splice(index, 1)[0];
      }
    };

    copy = function (array) {
      return array.concat([]);
    };

    last = function (array) {
      return array[array.length - 1];
    };

    noop = function () { };

    try {
      Object.defineProperty((function () { }), 'length', {
        get: noop,
        set: noop
      });
      PROXY_LENGTH = true;
    } catch (_error) {
      PROXY_LENGTH = false;
    }

    return Observable;

  })();

  var parser = (function (create, rules) {
    return create(create, rules);
  }(function (create, rules) {
    var RE_FLAGS, decompile, fail, failExpected, failIndex, fns, generate, getValue, hToS, invoke, loc, mapValue, maxFailPos, noteName, parse, preComputedRules, precompileHandler, precompute, precomputeRule, prettyPrint, toS, tokenHandler, validate, _names;
    failExpected = Array(16);
    failIndex = 0;
    maxFailPos = 0;
    fail = function (pos, expected) {
      if (pos < maxFailPos) {
        return;
      }
      if (pos > maxFailPos) {
        maxFailPos = pos;
        failIndex = 0;
      }
      failExpected[failIndex++] = expected;
    };
    RE_FLAGS = "uy";
    prettyPrint = function (v) {
      var name, pv, s;
      pv = v instanceof RegExp ? (s = v.toString(), s.slice(0, s.lastIndexOf('/') + 1)) : typeof v === "string" ? v === "" ? "EOF" : JSON.stringify(v) : v;
      if (name = _names.get(v)) {
        return "" + name + " " + pv;
      } else {
        return pv;
      }
    };
    _names = new Map;
    noteName = function (name, value) {
      if (name) {
        _names.set(value, name);
      }
      return value;
    };
    preComputedRules = null;
    precomputeRule = function (rule, out, name, compile) {
      var arg, data, handler, op, placeholder, result;
      if (Array.isArray(rule)) {
        op = rule[0], arg = rule[1], handler = rule[2];
        result = [
          fns[op], (function () {
            switch (op) {
              case "/":
              case "S":
                return arg.map(function (x) {
                  return precomputeRule(x, null, name, compile);
                });
              case "*":
              case "+":
              case "?":
              case "!":
              case "&":
                return precomputeRule(arg, null, name + op, compile);
              case "R":
                return noteName(name, RegExp(arg, RE_FLAGS));
              case "L":
                return noteName(name, JSON.parse("\"" + arg + "\""));
              default:
                throw new Error("Don't know how to pre-compute " + (JSON.stringify(op)));
            }
          })(), compile(handler, op, name)
        ];
        if (out) {
          out[0] = result[0];
          out[1] = result[1];
          out[2] = result[2];
          return out;
        }
        return result;
      } else {
        if (preComputedRules[rule]) {
          return preComputedRules[rule];
        } else {
          preComputedRules[rule] = placeholder = out || [];
          data = rules[rule];
          if (data == null) {
            throw new Error("No rule with name " + (JSON.stringify(rule)));
          }
          return precomputeRule(data, placeholder, rule, compile);
        }
      }
    };
    getValue = function (x) {
      return x.value;
    };
    precompileHandler = function (handler, op) {
      var fn;
      if (handler != null ? handler.f : void 0) {
        fn = Function("$loc", "$0", "$1", "$2", "$3", "$4", "$5", "$6", "$7", "$8", "$9", handler.f);
        if (op === "S") {
          return function (s) {
            return fn.apply(null, [s.loc, s.value].concat(s.value));
          };
        } else if (op === "R") {
          return function (s) {
            return fn.apply(null, [s.loc].concat(s.value));
          };
        } else {
          return function (s) {
            return fn(s.loc, s.value, s.value);
          };
        }
      } else {
        if (op === "R") {
          if (handler != null) {
            return function (s) {
              return mapValue(handler, s.value);
            };
          } else {
            return function (s) {
              return s.value[0];
            };
          }
        } else if (op === "S") {
          if (handler != null) {
            return function (s) {
              return mapValue(handler, [s.value].concat(s.value));
            };
          } else {
            return function (s) {
              return s.value;
            };
          }
        } else {
          return function (s) {
            return mapValue(handler, s.value);
          };
        }
      }
    };
    precompute = function (rules, compile) {
      var first;
      preComputedRules = {};
      first = Object.keys(rules)[0];
      preComputedRules[first] = precomputeRule(first, null, first, compile);
      return preComputedRules;
    };
    invoke = function (state, data) {
      var arg, fn, mapping, result;
      fn = data[0], arg = data[1], mapping = data[2];
      result = fn(state, arg);
      if (mapping == null) {
        mapping = getValue;
      }
      if (result) {
        result.value = mapping(result);
      }
      return result;
    };
    mapValue = function (mapping, value) {
      switch (typeof mapping) {
        case "number":
          return value[mapping];
        case "string":
          return mapping;
        case "object":
          if (Array.isArray(mapping)) {
            return mapping.map(function (n) {
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
    fns = {
      L: function (state, str) {
        var input, length, pos;
        input = state.input, pos = state.pos;
        length = str.length;
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
      R: function (state, regExp) {
        var input, l, m, pos, v;
        input = state.input, pos = state.pos;
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
      S: function (state, terms) {
        var i, input, l, pos, r, results, s, value;
        input = state.input, pos = state.pos;
        results = [];
        s = pos;
        i = 0;
        l = terms.length;
        while (true) {
          r = invoke({
            input: input,
            pos: pos
          }, terms[i++]);
          if (r) {
            pos = r.pos, value = r.value;
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
      "/": function (state, terms) {
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
      "?": function (state, term) {
        return invoke(state, term) || state;
      },
      "*": function (state, term) {
        var input, pos, prevPos, r, results, s, value;
        input = state.input, pos = state.pos;
        s = pos;
        results = [];
        while (true) {
          prevPos = pos;
          r = invoke({
            input: input,
            pos: pos
          }, term);
          if (r == null) {
            break;
          }
          pos = r.pos, value = r.value;
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
      "+": function (state, term) {
        var first, input, pos, rest, s;
        input = state.input, s = state.pos;
        first = invoke(state, term);
        if (first == null) {
          return;
        }
        pos = first.pos;
        pos = (rest = invoke({
          input: input,
          pos: pos
        }, [fns["*"], term])).pos;
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
      "!": function (state, term) {
        var newState;
        newState = invoke(state, term);
        if (newState != null) {

        } else {
          return state;
        }
      },
      "&": function (state, term) {
        var newState;
        newState = invoke(state, term);
        if (newState.pos === state.pos) {

        } else {
          return state;
        }
      }
    };
    loc = function (input, pos) {
      var column, line, rawPos, _ref;
      rawPos = pos;
      _ref = input.split(/\n|\r\n|\r/).reduce(function (_arg, line) {
        var col, l, row;
        row = _arg[0], col = _arg[1];
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
      }, [1, 1]), line = _ref[0], column = _ref[1];
      return "" + line + ":" + column;
    };
    validate = function (input, result, _arg) {
      var expectations, filename, l;
      filename = _arg.filename;
      if ((result != null) && result.pos === input.length) {
        return result.value;
      }
      expectations = Array.from(new Set(failExpected.slice(0, failIndex)));
      l = loc(input, maxFailPos);
      if ((result != null) && result.pos > maxFailPos) {
        l = loc(input, result.pos);
        throw new Error("Unconsumed input at " + l + "\n\n" + (input.slice(result.pos)) + "\n");
      } else if (expectations.length) {
        throw new Error("" + filename + ":" + l + " Failed to parse\nExpected:\n\t" + (expectations.map(prettyPrint).join("\n\t")) + "\nFound: " + (prettyPrint(input.substr(maxFailPos, 5))));
      } else {
        throw new Error("Unconsumed input at " + l + "\n\n" + (input.slice(result.pos)) + "\n");
      }
    };
    parse = function (input, opts) {
      var result, state;
      if (opts == null) {
        opts = {};
      }
      if (typeof input !== "string") {
        throw new Error("Input must be a string");
      }
      if (opts.filename == null) {
        opts.filename = "[stdin]";
      }
      failIndex = 0;
      maxFailPos = 0;
      state = {
        input: input,
        pos: 0
      };
      if (opts.tokenize) {
        precompute(rules, tokenHandler);
      }
      result = invoke(state, Object.values(preComputedRules)[0]);
      return validate(input, result, opts);
    };
    tokenHandler = function (handler, op, name) {
      return function (_arg) {
        var value;
        value = _arg.value;
        if (value == null) {
          return value;
        }
        switch (op) {
          case "S":
            return {
              type: name,
              value: value.filter(function (v) {
                return v != null;
              }).reduce(function (a, b) {
                return a.concat(b);
              }, [])
            };
          case "L":
          case "R":
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
    generate = function (rules, vivify) {
      var m, src;
      src = "(function(create, rules) {\n  create(create, rules);\n}(" + (create.toString()) + ", " + (JSON.stringify(rules)) + "));\n";
      if (vivify) {
        m = {};
        Function("module", src)(m);
        return m.exports;
      } else {
        return src;
      }
    };
    hToS = function (h) {
      if (h == null) {
        return "";
      }
      return " -> " + (function () {
        switch (typeof h) {
          case "number":
            return h;
          case "string":
            return JSON.stringify(h);
          case "object":
            if (Array.isArray(h)) {
              return JSON.stringify(h);
            } else {
              return "\n" + (h.f.replace(/^|\n/g, "$&    "));
            }
        }
      })();
    };
    toS = function (rule, depth) {
      var f, h, terms;
      if (depth == null) {
        depth = 0;
      }
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
            terms = rule[1].map(function (i) {
              return toS(i, depth + 1);
            });
            if (depth < 1) {
              return terms.join(" ") + hToS(h);
            } else {
              return "( " + terms.join(" ") + " )";
            }
            break;
          case "/":
            terms = rule[1].map(function (i) {
              return toS(i, depth && depth + 1);
            });
            if (depth === 0 && !h) {
              return terms.join("\n  ");
            } else {
              return "( " + terms.join(" / ") + " )" + hToS(h);
            }
        }
      } else {
        return rule;
      }
    };
    decompile = function (rules) {
      return Object.keys(rules).map(function (name) {
        var value;
        value = toS(rules[name]);
        return "" + name + "\n  " + value + "\n";
      }).join("\n");
    };
    precompute(rules, precompileHandler);
    return {
      decompile: decompile,
      parse: parse,
      generate: generate,
      rules: rules
    };
  }, { "Template": ["S", [["?", "__"], ["*", "Line"]], { "f": "var top = a => a[a.length-1];\nfunction reduceLines(lines) {\n  var depth = 0;\n  var stack = [[]];\n  lines.forEach( ([indent, line]) => {\n    if (Array.isArray(line)) {\n      line[1] = collectAttributes(line[1])\n    }\n    if (depth+1 === indent) {\n      // We're adding to the content of the last element in the current stack\n      stack.push(top(top(stack))[2])\n    } else if ( indent > depth) {\n      throw new Error(\"Indented too far\")\n    } else if (indent < depth) {\n      stack = stack.slice(0, indent + 1)\n    }\n    depth = indent\n    top(stack).push(line)\n  })\n  return stack[0]\n}\nfunction collectAttributes(attributesArray) {\n  return attributesArray.reduce((o, [key, value]) => {\n    if (key === \"id\" || key === \"class\" || key === \"style\") {\n      var p = o[key] || (o[key] = [])\n      p.push(value)\n    } else {\n      o[key] = value\n    }\n    return o\n  }, {})\n}\nfunction pretty(lines) {\n  return lines.map(line =>\n    JSON.stringify(line)\n  )\n}\nvar reduced = reduceLines($2);\nif (reduced.length != 1) {\n  throw new Error(\"Must have exactly one root node.\");\n}\nreturn reduced[0];" }], "Line": ["S", ["Indent", "LineBody", "EOS"], [1, 2]], "LineBody": ["/", [["S", ["Tag", ["?", "DeprecatedEquals"], "_", "RestOfLine"], { "f": "$1[2].push($4)\nreturn $1" }], ["S", ["Tag", ["?", "_"]], 1], ["S", [["L", "|"], ["?", ["L", " "]], "RestOfLine"], { "f": "return $3 + \"\\n\";" }], ["S", [["?", ["S", ["DeprecatedEquals", "_"]]], "RestOfLine"], 2]]], "RestOfLine": ["R", "[^\\n\\r]*", { "f": "// TODO: Handle runs of text with bound content inside\nif ($0.slice(0,1) === \"@\") {\n  return {\n    bind: $0.slice(1)\n  }\n} else {\n  return $0\n}" }], "DeprecatedEquals": ["L", "=", { "f": "console.warn(\"'= <content>' is deprecated, you can remove the '=' without issue.\")" }], "Tag": ["/", [["S", ["TagName", "OptionalIds", "OptionalClasses", "OptionalAttributes"], { "f": "return [\n  $1,\n  $2.concat($3, $4),\n  [],\n]" }], ["S", ["Ids", "OptionalClasses", "OptionalAttributes"], { "f": "return [\n  \"div\",\n  $1.concat($2, $3),\n  [],\n]" }], ["S", ["Classes", "OptionalAttributes"], { "f": "return [\n  \"div\",\n  $1.concat($2),\n  [],\n]" }]]], "OptionalClasses": ["/", ["Classes", ["L", "", { "f": "return []" }]]], "Classes": ["+", "Class"], "Class": ["/", [["S", [["L", "."], "Identifier"], { "f": "return [\"class\", $2]" }], ["S", [["L", "."], ["!", "Identifier"]], { "f": "throw \"Expected a class name\"" }], "IdError"]], "OptionalIds": ["?", "Ids", { "f": "return $1 || []" }], "Ids": ["S", ["Id"], { "f": "return [ $1 ]" }], "Id": ["/", [["S", [["L", "#"], "Identifier"], { "f": "return [\"id\", $2]" }], ["S", [["L", "#"], ["!", "Identifier"]], { "f": "throw \"Expected an id name\"" }]]], "IdError": ["L", "#", { "f": "throw \"Ids must appear before classes and attributes. Elements can only have one id.\"" }], "ClassError": ["L", ".", { "f": "throw \"Classes cannot appear after attributes.\"" }], "TagName": "Identifier", "OptionalAttributes": ["/", [["S", [["L", "("], ["?", "__"], ["+", "Attribute"], ["L", ")"], ["?", "IdError"], ["?", "ClassError"]], { "f": "return $3" }], ["L", "(", { "f": "throw \"Invalid attributes\"" }], ["L", "", { "f": "return []" }]]], "Attribute": ["/", [["S", ["AtIdentifier", ["?", "__"]], { "f": "return [$1.bind, $1]" }], ["S", ["EqBinding", ["?", "__"]], 1], ["S", ["Identifier", ["?", "__"]], { "f": "return [$1, \"\"]" }]]], "AtIdentifier": ["S", [["L", "@"], "Identifier"], { "f": "return {\n  bind: $2\n}" }], "EqBinding": ["S", ["Identifier", ["L", "="], ["/", ["AtIdentifier", "Value"]]], [1, 3]], "Identifier": ["R", "[a-zA-Z][a-zA-Z0-9-]*"], "Indent": ["*", ["/", [["L", "  "], ["L", "\\t"]]], { "f": "return $1.length" }], "_": ["R", "[ \\t]+"], "__": ["+", ["/", [["R", "[ \\t]"], "EOL"]]], "Value": ["/", [["S", [["L", "\\\""], ["*", "DoubleStringCharacter"], ["L", "\\\""]], { "f": "return $2.join(\"\")" }], ["S", [["L", "'"], ["*", "SingleStringCharacter"], ["L", "'"]], { "f": "return $2.join(\"\")" }], "Number"]], "DoubleStringCharacter": ["/", [["S", [["!", ["/", [["L", "\\\""], ["L", "\\\\"]]]], ["R", "."]], 2], ["S", [["L", "\\\\"], "EscapeSequence"], 2]]], "SingleStringCharacter": ["/", [["S", [["!", ["/", [["L", "'"], ["L", "\\\\"]]]], ["R", "."]], 2], ["S", [["L", "\\\\"], "EscapeSequence"], 2]]], "EscapeSequence": ["/", [["L", "'"], ["L", "\\\""], ["L", "\\\\"], ["R", ".", { "f": "return \"\\\\\" + $0" }]]], "Number": ["/", [["R", "-?[0-9]+\\.[0-9]+"], ["R", "-?[0-9]+"]]], "EOS": ["/", [["S", [["+", ["S", [["?", "_"], "EOL"]]], "_", "EOF"]], ["+", ["S", [["?", "_"], "EOL"]]], "EOF"]], "EOL": ["/", [["L", "\\r\\n"], ["L", "\\n"], ["L", "\\r"]]], "EOF": ["!", ["R", "[\\s\\S]"]] }));

  var Jadelet2, Observable, append, attachCleaner, bindEvent, bindObservable, bindSplat, bindValue, dispose, elementCleaners, elementRefCounts, eventNames, forEach, get, isEvent, isObject, isString, observeAttribute, observeContent, parser, release, remove, render, retain, splat;

  forEach = Array.prototype.forEach;

  elementCleaners = new WeakMap;

  elementRefCounts = new WeakMap;

  retain = function (element) {
    var count;
    count = elementRefCounts.get(element) || 0;
    elementRefCounts.set(element, count + 1);
  };

  release = function (element) {
    var count;
    count = elementRefCounts.get(element) || 0;
    count--;
    if (count > 0) {
      elementRefCounts.set(element, count);
    } else {
      elementRefCounts["delete"](element);
      dispose(element);
    }
  };

  dispose = function (element) {
    var children, _ref;
    children = element.children;
    if (children != null) {
      forEach.call(children, dispose);
    }
    if ((_ref = elementCleaners.get(element)) != null) {
      _ref.forEach(function (cleaner) {
        cleaner();
        elementCleaners["delete"](element);
      });
    }
  };

  attachCleaner = function (element, cleaner) {
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

  eventNames = /^on(touch|animation|transition)(start|iteration|move|end|cancel)$/;

  isEvent = function (name, element) {
    return name.match(eventNames) || name in element;
  };

  observeAttribute = function (element, context, name, value) {
    var bind;
    switch (name) {
      case "id":
        bindSplat(element, context, value, function (ids) {
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
        bindSplat(element, context, value, function (classes) {
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
        bindSplat(element, context, value, function (styles) {
          element.removeAttribute("style");
          styles.forEach(function (style) {
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
          bind = value.bind;
          element.onchange = function () {
            if (typeof context[bind] === "function") {
              context[bind](element.checked);
            }
          };
        }
        bindObservable(element, value, context, function (newValue) {
          element.checked = newValue;
        });
        break;
      default:
        if (isEvent("on" + name, element)) {
          bindEvent(element, name, value.bind, context);
        } else {
          bindObservable(element, value, context, function (newValue) {
            if ((newValue != null) && newValue !== false) {
              element.setAttribute(name, newValue);
            } else {
              element.removeAttribute(name);
            }
          });
        }
    }
  };

  bindObservable = function (element, value, context, update) {
    var bind, observable;
    if (isString(value)) {
      return update(value);
    } else if (typeof value === 'function') {
      observable = Observable(function () {
        update(value.call(context));
      });
    } else {
      bind = value.bind;
      observable = Observable(function () {
        update(get(context[bind], context));
      });
    }
    if (observable._observableDependencies.size === 0) {
      return;
    }
    attachCleaner(element, observable.releaseDependencies);
  };

  bindValue = function (element, value, context) {
    var bind;
    if (value && typeof value === "object") {
      bind = value.bind;
      element.oninput = element.onchange = function () {
        if (typeof context[bind] === "function") {
          context[bind](element.value);
        }
      };
    }
    bindObservable(element, value, context, function (newValue) {
      if (element.value !== newValue) {
        element.value = newValue;
      }
    });
  };

  bindEvent = function (element, name, binding, context) {
    var handler;
    handler = context[binding];
    if (typeof handler === 'function') {
      element.addEventListener(name, handler.bind(context));
    }
  };

  bindSplat = function (element, context, sources, update) {
    bindObservable(element, (function () {
      return splat(sources, context);
    }), context, update);
  };

  observeContent = function (element, context, contentArray, namespace) {
    var count, tracker;
    tracker = [];
    count = 0;
    contentArray.forEach(function (astNode, index) {
      var length, previousLength;
      tracker[index] = count;
      if (Array.isArray(astNode)) {
        element.appendChild(render(astNode, context, namespace));
        count++;
      } else if (isString(astNode)) {
        element.appendChild(document.createTextNode(astNode));
        count++;
      } else if (isObject(astNode)) {
        length = previousLength = 0;
        bindObservable(element, astNode, context, function (value) {
          var beforeTarget, child, delta, i, pos, toRelease;
          previousLength = length;
          pos = tracker[index];
          beforeTarget = element.childNodes[pos + length];
          toRelease = new Array(length);
          i = 0;
          while (i < length) {
            child = element.childNodes[pos];
            element.removeChild(child);
            toRelease[i] = child;
            i++;
          }
          length = append(element, value, beforeTarget);
          i = 0;
          while (i < previousLength) {
            child = toRelease[i];
            release(child);
            i++;
          }
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

  append = function (element, item, beforeTarget) {
    var el;
    if (item == null) {
      return 0;
    } else if (Array.isArray(item)) {
      return item.map(function (item) {
        return append(element, item, beforeTarget);
      }).reduce(function (a, b) {
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

  remove = function (element, child) {
    element.removeChild(child);
    return release(child);
  };

  isObject = function (x) {
    return typeof x === "object";
  };

  isString = function (x) {
    return typeof x === "string";
  };

  splat = function (sources, context) {
    return sources.map(function (source) {
      if (isString(source)) {
        return source;
      } else {
        return get(context[source.bind], context);
      }
    }).reduce(function (a, b) {
      return a.concat(b);
    }, []).filter(function (x) {
      return x != null;
    });
  };

  get = function (x, context) {
    if (typeof x === 'function') {
      return x.call(context);
    } else {
      return x;
    }
  };

  render = function (astNode, context, namespace) {
    var attributes, children, element, tag;
    if (context == null) {
      context = {};
    }
    tag = astNode[0], attributes = astNode[1], children = astNode[2];
    if (tag === "svg" && !namespace) {
      namespace = "http://www.w3.org/2000/svg";
    }
    if (namespace) {
      element = document.createElementNS(namespace, tag);
    } else {
      element = document.createElement(tag);
    }
    observeContent(element, context, children, namespace);
    Object.keys(attributes).forEach(function (name) {
      observeAttribute(element, context, name, attributes[name]);
    });
    return element;
  };

  self.Jadelet2 = Jadelet2 = {
    compile: function (source, opts) {
      var ast, exports, runtime;
      if (opts == null) {
        opts = {};
      }
      ast = Jadelet2.parse(source);
      runtime = opts.runtime || "Jadelet2";
      exports = opts.exports || "module.exports";
      return "" + exports + " = " + runtime + ".exec(" + (JSON.stringify(ast)) + ");";
    },
    parse: parser.parse,
    parser: parser,
    exec: function (ast) {
      if (typeof ast === "function") {
        return ast;
      }
      if (typeof ast === "string") {
        ast = Jadelet2.parse(ast);
      }
      return function (context) {
        return render(ast, context);
      };
    },
    Observable: Observable,
    _elementCleaners: elementCleaners,
    dispose: dispose,
    retain: retain,
    release: release
  };

})();
