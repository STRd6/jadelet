const { readFile } = require('fs/promises');
const { compile } = require('./');

module.exports = (options = {}) => ({
  name: 'jadelet',
  setup: function (build) {
    return build.onLoad({
      filter: /.\.jadelet$/
    }, function (args) {
      return readFile(args.path, 'utf8').then(function (source) {
        return {
          contents: compile(source, options)
        };
      }).catch(function (e) {
        return {
          errors: [
            {
              text: e.message
            }
          ]
        };
      });
    });
  }
});
