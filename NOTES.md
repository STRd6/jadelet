TypeScript
==========

esbuild is a real stickler with extensions so it is necessary to require "parser.hera".
TypeScript then needs a parser.hera.d.ts to work with CoffeeSense.

So far the clean way of handling it is to declare all the types publically in
types/main.d.ts then `export = SomeType` in the individual .d.ts files adjacent
to the sources.

TODO: Still need to see how building with `tsc` works with that setup.
