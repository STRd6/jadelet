Change Log
==========

2.0.0
-----

!!Breaking Changes!!

- Remove `- <code>` and `= <code returned as content>`.
This simplifies the templates much further but is not necessarily a strict upgrade if you like using code in your templates.

---

- Using hera for parsing
- Dropped CoffeeScript dependency
- Removed `- <code>`
- Deprecated `h1= @content` in favor of `h1 @content` syntax
- Faster
- Parser and runtime combined in less than 10kb

1.0.0
-----

(TODO: fill out 1.0 changelog)

0.8.0
-----

- Added `|` for plain text
- Improved style attribute handling
- Fixed unnecessary memory leakage in complex templates
- Runtime size down to < 2.5kb minified and gzipped
- Removed dependence on deprecated `Observable.concat`
- Removed dependence on deprecated `Observable#each`
- Removed Jadelet.VERSION property
- Removed :filters
- Added CHANGELOG.md

0.7.0
-----

- Renamed from Hamlet to Jadelet
- Merged parser and compiler into `jadelet` repository
