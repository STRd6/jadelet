#! /bin/bash

set -eoux pipefail

rm -rf dist

# build
civet build/build.civet

# adjust .d.ts files: point .civet imports at .js and drop the .civet infix.
# find + a redirect rather than globstar + `sed -i`: macOS ships bash 3.2 and
# BSD sed, which have neither.
find dist -name '*.civet.d.ts' | while read -r f; do
  sed 's/\.civet"/.js"/g' "$f" > "${f%.civet.d.ts}.d.ts"
  rm "$f"
done

sed 's/\.civet"/.mjs"/g' dist/esbuild.mjs > dist/esbuild.mjs.tmp
mv dist/esbuild.mjs.tmp dist/esbuild.mjs

# cli
BIN="dist/jadelet"
{ echo "#!/usr/bin/env node"; sed 's/\.civet"/.mjs"/g' dist/cli.mjs; } > "$BIN"
chmod +x "$BIN"
rm dist/cli.mjs
