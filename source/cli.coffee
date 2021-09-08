fs = require "fs"
{compile} = require '../dist/jadelet'
md5 = require 'md5'

{ readdir } = fs.promises
{ resolve, sep:fileSeparator } = require "path"

getFiles = (dir, ext) ->
  entities = await readdir dir,
    withFileTypes: true

  for entity from entities
    res = resolve dir, entity.name
    if entity.isDirectory()
      yield from getFiles(res, ext)
    else if res.match ext
      yield res

{program} = require("commander")
program
  .version(require('../package.json').version)
  .option("-d, --directory [directory]", "Compile all .jadelet files in the given directory")
  .option("--encoding [encoding]", "Encoding of files being read from --directory (default 'utf-8')")
  .option("-e, --exports [name]", "Export compiled template as (default 'module.exports'")
  .option("--extension [extension]", "Extension to compile")
  .option("-r, --runtime [provider]", "Runtime provider")
  .parse(process.argv)
options = program.opts()

encoding = options.encoding or "utf-8"
optionsJSON = JSON.stringify options

if options.extension
  extension = new RegExp "\\.#{options.extension}$"
else
  extension = /\.jade(let)?$/

if (dir = options.directory)
  # Ensure exactly one trailing slash
  dir = resolve(dir)

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
      currMD5 = md5(input + optionsJSON)
      if currMD5 != prevMD5
        console.log "Compiling #{path} to #{outPath}"
        # Replace $file in exports with path
        if options.exports
          key = basePath.replace(dir + fileSeparator, "")
          if fileSeparator is "\\"
            key = key.replace /\\/g, "/"
          exports = options.exports.replace("$file", JSON.stringify(key))

        program = compile input,
          runtime: options.runtime
          exports: exports

        fs.writeFileSync(outPath, program)
        fs.writeFileSync(md5Path, currMD5)
      else
        console.log "Skipping #{path} (no changes)"

else
  input = fs.readFileSync(process.stdin.fd, encoding)

  process.stdout.write compile input,
    mode: options.mode
    runtime: options.runtime
    exports: options.exports
