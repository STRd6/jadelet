[![Coverage Status](https://coveralls.io/repos/github/STRd6/jadelet/badge.svg?branch=master)](https://coveralls.io/github/STRd6/jadelet?branch=master)

Jadelet
=======

*Pure and simple clientside templates*

Jadelet is the cleanest and simplest way to describe your templates. It is a
breeze to learn. Jadelet attributes correspond directly with HTML attributes.
If you know HTML then you already know Jadelet.

Other libraries and frameworks put up barriers between you and the DOM. Like a
dutiful servant, Jadelet brings the power of the DOM into _your_ hands.

Jadelet is the smallest of all clientside templating libraries (< 5.8kb). But
don't let its size fool you: it contains tremendous power.

Jadelet is free, MIT licensed, open source, non-GMO, and production ready.

- [Jadelet Homepage](https://danielx.net/jadelet/)
- [Source](https://github.com/STRd6/jadelet)

Examples
--------

#### Header

```jade
h1 @title
```

```javascript
const HeaderTemplate = require("./header")
const headerElement = HeaderTemplate({
  title: "Hello world"
})
```

#### Button

```jade
button(@click) Say Hey
```

```javascript
ButtonTemplate = require("./button")
buttonElement = ButtonTemplate({
  click: function() {
    alert("heyy")
  }
})
```

[More examples](https://danielx.net/jadelet/)

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

Require your templates normally and let webpack or whatever other godforsaken
bundler you use do its magic.

```javascript
// main.js
mainTemplate = require("./templates/main");

document.body.appendChild(mainTemplate(data));
```

Road to 1.0
-----------

- [x] Still under 2.5kb
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

FAQ
---

#### Is Jadelet safe from XSS?

Yes. Jadelet uses native DOM APIs to write string output as text nodes.

#### How do I use Jadelet to render HTML Elements?

Jadelet knows the type of objects it renders. When you pass an `HTMLElement`
(or any other descendent of `window.Node`) it will insert it into the DOM as is.

```jade
.content
  h1 My Canvas
    @canvasElement
```

```javascript
Template({
  canvasElement: document.createElement('canvas')
})
```

#### Is it production ready?

Yes, Jadelet's been used for years in production by glitch.com, whimsy.space,
and danielx.net.

#### Is it performant?

Yes! And because it's just DOM stuff you can easily drop down to the native DOM
APIs for the pieces of your app that need special optimization.

#### How can I contribute?

Open some issues, open some pull requests, let's talk it out :)

History
-------

Jadelet was inspired by Haml and Jade. I kept removing features over the years
until it was fast and simple enough for my tastes.

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

    echo "h1#title @title" | jadelet

Options
-------

`-d, --directory [directory]` Compile all .jadelet files in the given directory.

```bash
jadelet -d templates
```

`--encoding [encoding]` Encoding of files being read from `--directory` (default `'utf-8'`)

`--exports, -e [name]` Export compiled template as (default `"module.exports"`)

When used with `-d` you can use $file to take on the stringified name of the
current file. For example:

```bash
jadelet -d templates/ -e 'T[$file]'
```

The files will export as:
```javascript
T["folder/subfolder/file"] = require('jadelet').exec(...)
```

`--runtime, -r [runtime_name]` Specifies the name of the globally available Jadelet runtime (default is `"require('jadelet')"`).

If you are using `jadelet-brower.js` you'll want to replace this with 'Jadelet' so
it can use the global in the browser.

```bash
jadelet -r "Jadelet" < template.jadelet > output.js
```
