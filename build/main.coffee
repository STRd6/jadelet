esbuild = require 'esbuild'
coffeeScriptPlugin = require 'esbuild-coffeescript'
heraPlugin = require "@danielx/hera/esbuild-plugin"

watch = process.argv.includes '--watch'
minify = !watch || process.argv.includes '--minify'
sourcemap = true

esbuild.build({
  entryPoints: ['source/jadelet.coffee']
  tsconfig: "./tsconfig.json"
  bundle: true
  format: "cjs"
  sourcemap
  minify
  watch
  platform: 'browser'
  outfile: 'dist/main.js'
  plugins: [
    coffeeScriptPlugin
      bare: true
      inlineMap: sourcemap
    heraPlugin
  ]
}).catch -> process.exit 1

esbuild.build({
  entryPoints: ['source/cli.coffee']
  format: "cjs"
  watch
  platform: 'browser'
  outfile: 'dist/cli.js'
  plugins: [
    coffeeScriptPlugin
      bare: true
      inlineMap: sourcemap
  ]
}).catch -> process.exit 1
