[![Build Status](https://travis-ci.org/dr-coffee-labs/hamlet.svg?branch=master)](https://travis-ci.org/dr-coffee-labs/hamlet)

Hamlet
======

Hamlet is a simple and powerful reactive templating system.

It's framework agnostic and focuses on clean declarative templating, leaving you to build your application with your favorite tools. Hamlet leverages the power of native browser APIs to keep your data model and html elements in sync.

All of this in only 3.7kb, minified and gzipped!

Getting Started
===============

1. Install Hamlet compiler CLI
2. Set up template compilation step
3. Install Hamlet runtime
4. Instantiate template with data and insert into the DOM.

Compiler
--------

Hamlet templates use a compiler to allow bindings without the directives many other templating languages require. Install Hamlet's CLI tool to compile templates

```bash
npm install -g hamlet-cli
```

Now that you have the compiler, you'll need to set up a build step to generate the compiled templates. Here's an example bash script you can use to compile all haml files in your templates directory.

```bash
#! /bin/bash

cd templates

for file in *.haml; do
  hamlet < $file > ${file/.haml}.js
done

# you can even smash all the templates together if you like
# cat *.js > ../javascripts/templates.js
```

After this, just make sure to require the compiled JavaScript files.

Runtime
-------

#### With Node.js

Add hamlet-runtime to your package.json

```bash
npm install --save-dev hamlet-runtime
```

To use the templates in a Node.js style project built with browserify you can require them normally.

```coffee-script
mainTemplate = require "./templates/main"

document.body.appendChild mainTemplate(data)
```

#### In the browser

Using `browserify` or another build tool that gives you acess to require is preferred, though you can also use the templates manually.

1. Install the Hamlet compiler as above.

2. Compile your templates into a single JS file that exposes them on a global object. 

    You can use this bash script as a starting point: https://gist.github.com/STRd6/10400709

    The script assumes that your templates are in `./templates` and named `*.haml`. It will generate a `templates.js` file in the root of your application, exporting each template as `JST[filename]`, so if you have a template named `navigation.haml` you'll be able to access it as `JST.navigation` and render it as `JST.navigation(data)`.

3. Download the Hamlet runtime script to include in your app.
    - Direct link https://raw.githubusercontent.com/dr-coffee-labs/hamlet-runtime/component/hamlet-runtime.js
    - Use bower `bower install hamlet-runtime`

4. Render them in your app: `document.querySelector("your_selector").appendChild JST.main(data)`

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
