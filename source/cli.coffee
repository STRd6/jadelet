fs = require "fs"
{compile} = require '../dist/jadelet'
md5 = require 'md5'

{ readdir } = fs.promises
{ resolve } = require "path"

getFiles = (dir, ext) ->
  entities = await readdir dir,
    withFileTypes: true

  for entity from entities
    res = resolve dir, entity.name
    if entity.isDirectory()
      yield from getFiles(res)
    else if res.match ext
      yield res

cli = require("commander")
  .version(require('../package.json').version)
  .option("-a, --ast", "Output AST")
  .option("-d, --directory [directory]", "Compile all .jadelet files in the given directory")
  .option("--encoding [encoding]", "Encoding of files being read from --directory (default 'utf-8')")
  .option("-e, --exports [name]", "Export compiled template as (default 'module.exports'")
  .option("--extension [extension]", "Extension to compile")
  .option("-r, --runtime [provider]", "Runtime provider")
  .parse(process.argv)

encoding = cli.encoding or "utf-8"
cliJSON = JSON.stringify cli

if cli.extension
  extension = new RegExp "\\.#{cli.extension}$"
else
  extension = /\.jade(let)?$/

if (dir = cli.directory)
  # Ensure exactly one trailing slash
  dir = dir.replace /\/*$/, "/"

  do ->
    for await path from getFiles(dir, extension)
      basePath = path.replace extension, ""
      outPath = "#{basePath}.js"
      md5Path = "#{basePath}.md5"

      # ignore md5 if the output does not exist
      if fs.existsSync(outPath) and fs.existsSync(md5Path)
        prevMD5 = fs.readFileSync md5Path, encoding: encoding

      input = fs.readFileSync path,
        encoding: encoding

      # if the options change, the prevMD5 is invalid
      currMD5 = md5(input + cliJSON)
      if currMD5 != prevMD5
        console.log "Compiling #{path} to #{outPath}"
        # Replace $file in exports with path
        if cli.exports
          exports = cli.exports.replace("$file", basePath)

        program = compile input,
          runtime: cli.runtime
          exports: exports

        fs.writeFileSync(outPath, program)
        fs.writeFileSync(md5Path, currMD5)
      else
        console.log "Skipping #{path} (no changes)"

else
  input = fs.readFileSync(process.stdin.fd, encoding)

  if cli.ast
    process.stdout.write JSON.stringify(ast)

    return

  else
    process.stdout.write compile input,
      mode: cli.mode
      runtime: cli.runtime
      exports: cli.exports
