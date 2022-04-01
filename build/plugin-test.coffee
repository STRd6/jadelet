esbuild = require 'esbuild'
jadeletPlugin = require("../esbuild-plugin")
path = require "path"

root = path.resolve()

esbuild.build({
  entryPoints: ['test/fixtures/esbuild.js']
  globalName: "Bundle"
  bundle: true
  sourcemap: true
  external: ["jadelet"]
  platform: 'browser'
  outfile: 'test/fixtures/out/build.js'
  plugins: [
    jadeletPlugin
      runtime: "require(#{JSON.stringify(root)})"
  ]
}).catch -> process.exit 1
