fs = require "fs"
stdin = require "stdin"
compile = require '../dist/compiler'
wrench = require "wrench"
CoffeeScript = require "coffee-script"

cli = require("commander")
  .version(require('../package.json').version)
  .option("-a, --ast", "Output AST")
  .option("-d, --directory [directory]", "Compile all .jadelet files in the given directory")
  .option("--encoding [encoding]", "Encoding of files being read from --directory (default 'utf-8')")
  .option("-e, --exports [name]", "Export compiled template as (default 'module.exports'")
  .option("-r, --runtime [provider]", "Runtime provider")
  .parse(process.argv)

encoding = cli.encoding or "utf-8"

extension = /\.jadelet$/

if (dir = cli.dir)
  # Ensure exactly one trailing slash
  dir = dir.replace /\/*$/, "/"

  files = wrench.readdirSyncRecursive(dir)

  files.forEach (path) ->
    inPath = "#{dir}#{path}"

    if fs.lstatSync(inPath).isFile()
      if inPath.match(extension)
        basePath = inPath.replace extension, ""
        outPath = "#{basePath}.js"

        console.log "Compiling #{inPath} to #{outPath}"

        input = fs.readFileSync inPath,
          encoding: encoding

        # Replace $file in exports with path
        if cli.exports
          exports = cli.exports.replace("$file", basePath)

        program = compile input,
          runtime: cli.runtime
          exports: exports
          compiler: CoffeeScript

        fs.writeFileSync(outPath, program)

else
  stdin (input) ->

    if cli.ast
      process.stdout.write JSON.stringify(ast)

      return

    else
      process.stdout.write compile input,
        mode: cli.mode
        runtime: cli.runtime
        exports: cli.exports
        compiler: CoffeeScript
