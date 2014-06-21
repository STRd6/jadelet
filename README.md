[![Build Status](https://travis-ci.org/dr-coffee-labs/hamlet.svg?branch=master)](https://travis-ci.org/dr-coffee-labs/hamlet)

Hamlet
======

Hamlet is a simple and powerful reactive templating system.

It's framework agnostic and focuses on clean declarative templating, leaving you to build your application with your favorite tools. Hamlet leverages the power of native browser APIs to keep your data model and html elements in sync.

All of this in only 3.7kb, minified and gzipped!

Getting Started
===============

#### Using Node.js

* Install the command line Hamlet compiler
 
```bash
npm install -g hamlet-cli
```

* Compile your templates and export them

```bash
#! /bin/bash

cd templates

for file in *.haml; do
  hamlet < $file > ${file/.haml}.js
done

for file in *.js; do
  echo "module.exports = " > tmpfile
  cat $file >> tmpfile
  mv tmpfile $file
done
```

* Add hamlet-runtime to your package.json

```bash
npm install --save-dev hamlet-runtime
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

#### In the browser

* Install the command line Hamlet compiler
* Compile your templates and expose them to the global browser scope.

```bash
#! /bin/bash
 
cd templates
 
for file in *.haml; do
  # Here we specify the name of the global variable where we'll be storing the Hamlet runtime with the -r option.
  # Otherwise, it's assumed that a node style require workflow will be used.
  hamlet < $file -r "Hamlet" > ${file/.haml}.js
done
 
for file in *.js; do
  echo "(window.JST || (window.JST = {}))['${file/.js}'] = " > tmpfile
  cat $file >> tmpfile
  mv tmpfile $file
done
 
cat *.js > ../templates.js
```

* Download the Hamlet runtime script to include in your app.
    - Direct link https://raw.githubusercontent.com/dr-coffee-labs/hamlet-runtime/component/hamlet-runtime.js
    - Use bower `bower install hamlet-runtime`

* Render them to the DOM: `document.body.appendChild(JST.main(data))`

Gotchas
-------

TLDR: If you are experiencing unexpected behavior in your templates make sure you have a root element,
and any each iteration has a root element.

Templates that lack root elements or root elements in iterators can be problematic.

Problematic Example:

```haml
.row
  - each @items, ->
    .first
    .second
```

Safe solution:

```haml
.row
  - each @items, ->
    .item
      .first
      .second
```

Problematic example:

```haml
.one
.two
.three
.four
```

Safe solution:

```haml
.root
  .one
  .two
  .three
  .four
```

Some of the problematic examples may work in simple situations, but if they are used as subtemplates or as observable changes take effect errors may occur. In theory it will be possible to correct this in a later version, but for now it remains a concern.
