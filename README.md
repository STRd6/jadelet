[![Build Status](https://travis-ci.org/STRd6/jadelet.svg)](https://travis-ci.org/STRd6/jadelet)

Jadelet
=======

Jadelet is a simple and powerful reactive templating system.

It's framework agnostic and focuses on clean declarative templating, leaving you to build your application with your favorite tools. Jadelet leverages the power of native browser APIs to keep your data model and html elements in sync.

All of this in only 2,772 bytes, minified and gzipped!

[Video Demo](http://blog.fogcreek.com/reactive-templating-demo-with-hamlet-tech-talk/)

Cool Example
------------

A simple panel with four elements all bound to the same data source. Changes in one propagate to all. Behold!

```jade
.panel
  input(type="text" value=@value)
  select(value=@value options=[@min..@max])
  input(type="range" value=@value min=@min max=@max)
  progress(value=@value max=@max)
```

```javascript
Observable = require("jadelet").Observable;
PanelTemplate = require("./templates/panel");

model = {
  min: 1,
  max: 10,
  value: Observable(5)
};

element = PanelTemplate(model);
document.body.appendChild(element);
```

Getting Started
===============

#### Using Node

Install Jadelet:

```bash
npm install --save-dev jadelet
```

Compile your templates:

```bash
node_modules/.bin/jadelet -d templates
```

To use the templates in a Node.js style project built with [browserify](https://github.com/substack/node-browserify) you can require them normally.

```javascript
// main.js
mainTemplate = require("./templates/main");

document.body.appendChild(mainTemplate(data));
```

Now use browserify to build the file you'll serve on your page.

```bash
browserify main.js > build.js
```

Resources
---------

Check out the [wiki](https://github.com/STRd6/jadelet/wiki/Development-Resources) for developer resources.

CLI
===

Command line interface for processing files with Jadelet over stdio.

Usage
-----

Jadelet in, JavaScript out.

    jadelet < template.jadelet > output.js

    echo "h1#title= @title" | jadelet

Options
-------

`-d, --directory [directory]` Compile all .jadelet files in the given directory.

```bash
jadelet -d templates
```

`--encoding [encoding]` Encoding of files being read from `--directory` (default 'utf-8')

`-e, --exports [name]` Export compiled template as (default 'module.exports')

`--runtime, -r [runtime_name]` Specifies the name of the globally available Jadelet runtime (default is 'require("jadelet")').

```bash
jadelet -r "Jadelet" < template.jadelet > output.js
```

`--ast, -a` Output a JSON AST instead of the JavaScript template function. Useful for debugging or for using the Jadelet DSL as a frontend for other renderer backends like Mithril or React. Until 1.0 this isn't guaranteed to be a stable format.

Examples
--------

Compiling all templates in a directory and packaging them for the browser, old-school:

```bash
jadelet --runtime "Jadelet" --directory templates --exports 'JST["$file"]'
cat templates/*.js > templates.js
```

Road to 1.0
===========

- [x] Still under 3kb
- [x] Don't Leak Resources
- [ ] Example Playground
- [ ] Documentation
- [x] Style Attributes
- [x] Filters
- [ ] Browserify Transform
- [ ] Require Registration

FAQ
===

Gotchas
-------

Templates must have only one root element, they will fail with multiple.

Good:

```jade
.root
  .one
  .two
```

Oopsies:

```jade
.one
.two
```
