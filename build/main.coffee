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
  sourcemap
  minify
  watch
  platform: 'node'
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
  watch
  platform: 'node'
  outfile: 'dist/cli.js'
  plugins: [
    coffeeScriptPlugin
      bare: true
      inlineMap: sourcemap
  ]
}).catch -> process.exit 1

esbuild.build({
  entryPoints: ['source/jadelet.coffee']
  globalName: "Jadelet"
  bundle: true
  sourcemap
  watch
  platform: 'browser'
  outfile: 'dist/browser.js'
  plugins: [
    coffeeScriptPlugin
      bare: true
      inlineMap: sourcemap
    heraPlugin
  ]
}).catch -> process.exit 1

esbuild.build({
  entryPoints: ['source/jadelet.coffee']
  globalName: "Jadelet"
  bundle: true
  sourcemap
  watch
  platform: 'browser'
  minify: true
  outfile: 'dist/browser.min.js'
  plugins: [
    coffeeScriptPlugin
      bare: true
      inlineMap: sourcemap
    heraPlugin
  ]
}).catch -> process.exit 1
