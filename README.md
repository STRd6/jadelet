[![Build Status](https://travis-ci.org/STRd6/jadelet.svg)](https://travis-ci.org/STRd6/jadelet)

Jadelet
=======

*Pure and simple clientside templates*

Jadelet is the cleanest and simplest way to describe your templates. It is a breeze to learn. Jadelet attributes correspond directly with HTML attributes. If you know HTML then you already know Jadelet.

Other libraries and frameworks put up barriers between you and the DOM. Like a dutiful servant, Jadelet brings the power of the DOM into _your_ hands.

Jadelet is the smallest of all clientside templating libraries (< 2.5kb). But don't let its size fool you: it contains tremendous power.

Jadelet is free, MIT licensed, open source, non-GMO, and production ready.

- [Jadelet.com](https://jadelet.com)
- [Source](https://github.com/STRd6/jadelet)
- [Example Playground](https://jadelet.glitch.me)
- [Video Demo](http://blog.fogcreek.com/reactive-templating-demo-with-hamlet-tech-talk/)

[![Jadelet Hello](https://danielx.whimsy.space/images/jadelet-hello.png)](https://jadelet.glitch.me)

Examples
--------

#### Header

```jade
h1= @title
```

```coffee
HeaderTemplate = require "./header"
headerElement = HeaderTemplate
  title: "Hello world"
```

#### Button

```jade
button(click=@sayHey)
```

```coffee
ButtonTemplate = require "./button"
buttonElement = ButtonTemplate
  sayHey: ->
    alert "heyy"
```

See more in the [Example Playground](https://jadelet.glitch.me)

Getting Started
---------------

Install Jadelet:

```bash
npm install jadelet
```

Compile your templates:

```bash
node_modules/.bin/jadelet -d templates
```

This will create a .js version of each template in your templates directory.

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

Road to 1.0
-----------

- [x] Still under 3kb
- [x] Don't Leak Resources
- [x] Style Attributes
- [x] Filters
- [x] Changelog
- [x] Example Playground
- [x] | for text content
- [x] Remove :filters
- [x] Updated README.md
- [ ] jadelet.com
- [ ] Documentation
- [ ] Getting Started Guide
- [ ] Browserify Transform
- [ ] Require Registration

FAQ
---

#### Ewww... CoffeeScript

That's not a question.

#### Is Jadelet safe from XSS?

Yes. Jadelet uses native DOM APIs to write string output as text nodes.

#### How do I use Jadelet to render HTML Elements?

Jadelet knows the type of objects it renders. When you pass an `HTMLElement` it will insert it into the DOM.

```jade
.content
  h1 My Canvas
  = @canvas
```

```coffee
Template
  canvas: document.createElement('canvas')
```

#### Is it production ready?

Yes, we're currently using Jadelet to power glitch.com. (Though we still have a 'Beta' sticker up... ¯\\\_(ツ)_/¯)

#### Is it performant?

Yes! And because it's just DOM stuff you can easily drop down to the native DOM APIs for the pieces of your app that need special optimization.

#### How can I contribute?

Open some issues, open some pull requests, let's talk it out :)

History
-------

Jadelet was inspired by Haml and Jade.

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

CLI
===

Command line interface for compiling templates.

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

`--exports, -e [name]` Export compiled template as (default 'module.exports')

`--extension [ext]` Extension to compile when compiling files from a directory. Default is `jade(let)?` so it should pick up both .jade and .jadelet files.

`--runtime, -r [runtime_name]` Specifies the name of the globally available Jadelet runtime (default is 'require("jadelet")').

```bash
jadelet -r "Jadelet" < template.jadelet > output.js
```

`--ast, -a` Output a JSON AST instead of the JavaScript template function. Useful for debugging or for using the Jadelet DSL as a frontend for other renderer backends like Mithril or React. Until 1.0 this isn't guaranteed to be a stable format.
