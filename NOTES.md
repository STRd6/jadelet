TypeScript
==========

esbuild is a real stickler with extensions so it is necessary to require "parser.hera".
TypeScript then needs a parser.hera.d.ts to work with CoffeeSense. Alternatively
an esbuild resolver plugin could be used.

So far the clean way of handling it is to declare all the types in `./types/`
and import then `export = SomeType` in the individual .d.ts files adjacent
to the sources.

Building with `tsc` is not necessary if we're only using CoffeeScript sources
since `./types/main.d.ts` is pointed to by the `type` field in `package.json`.
If there are other TypeScript sources then `tsc` will need to be involved in the
build process.

`export =` vs `export default`
---

`export = Something` is necessary for `Something = require('...')` to get picked
up properly. `export default Something` works with `{default:Something} = require...`

`export =` cannot be used with `export {something}`.

Ambient Declarations
---

A typescript file that exports will ignore ambient `declare` statements. In
order to have ambient they must all be `declare`.

Ambient declarations also cannot import other types but a work around is to use
`declare global` and put vars inside there. See [./types/ambient.d.ts](./types/ambient.d.ts)

Namespaces as types
---

Cannot use namespace 'Observable' as type.

use `typeof Observable`

JSDoc
---

JS written with JSDoc type annotations and compiled with `tsc -d --allowJs` will
output type declarations.

CoffeeSense + TypeScript
---

Need to set `checkJs` to true or add `#@ts-check` to enable type checking in
CoffeeSense.

It is possible to alias a bunch of imported types at the top to make using
comments for inline types easier inside the file.

```coffee
###*
@typedef {import("../types/types").Element} El
@typedef {import("../types/types").Context} Context
@typedef {import("../types/types").JadeletAttribute} JadeletAttribute
@typedef {import("../types/types").JadeletAST} JadeletAST
###
```
