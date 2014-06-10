Hamlet
======

Hamlet is a simple and powerful reactive templating system.

It's framework agnostic and focuses on clean declarative templating, leaving you to build your application with your favorite tools. Hamlet leverages the power of native browser APIs to keep your data model and html elements in sync.

All of this in only 3.7kb, minified and gzipped!

Getting Started
===============

1. Compile your templates
2. Require the Hamlet runtime before you instantiate templates.

Hamlet templates use a compiler to make all the magical bindings work. As a result, you'll need to include a build step in your workflow.

Compiler
--------

Install Hamlet CLI tool to compile templates

    npm install -g hamlet-cli

Here's an example bash script you can use to compile all haml files in your templates directory.

    #! /bin/bash

    cd templates

    for file in *.haml; do
      hamlet < $file > ${file/.haml}.js
    done
    
    # you can even smash all the templates together if you like
    # cat *.js > ../javascripts/templates.js

After this, just make sure to require the compiled JavaScript files.

Runtime
-------

#### With Node.js

Add hamlet-runtime to your package.json

    npm install --save-dev hamlet-runtime

To use the templates in a Node.js style project built with browserify you can require them normally.

    mainTemplate = require "./templates/main"

    document.body.appendChild mainTemplate(data)

#### In the browser

TODO: add simple instructions for using the runtime.

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

Examples
========

### Hello World

```haml
%button(click=@hello) Say Hello!
```

```coffee-script
hello: ->
  alert "Hello World!"
```

### Simple HTML

```haml
%h1 Welcome to the world of Tomorrow!
%p Where all of your wildest dreams will come true!
```

### Corresponding Bindings

```haml
%input(type="text" value=@value)
%select(value=@value)
  - each [0..@max], (option) ->
    %option(value=option)= option
%hr
%input(type="range" value=@value min="1" max=@max)
%hr
%progress(value=@value max=@max)
```

```coffee-script
max: 10
value: Observable 5
```
