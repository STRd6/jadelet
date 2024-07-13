var parse, exec, fs;
({ parse, exec } = require("./"));
fs = require("fs");

require.extensions[".jadelet"] = function (module, filename) {
  return module.exports = exec(parse(fs.readFileSync(filename, 'utf8')));
};
