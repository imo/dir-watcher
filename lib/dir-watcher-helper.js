(function() {
  var fs, path;
  fs = require('fs');
  path = require('path');
  exports.isDirectory = function(dir, callback) {
    return fs.stat(dir, function(err, stats) {
      return callback(!(err != null) && stats.isDirectory());
    });
  };
  exports.isFile = function(file, callback) {
    return fs.stat(file, function(err, stats) {
      return callback(!(err != null) && stats.isFile());
    });
  };
  exports.iterateDirectory = function(dir, iterator) {
    return fs.readdir(dir, function(err, entries) {
      var entry, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = entries.length; _i < _len; _i++) {
        entry = entries[_i];
        _results.push(iterator(path.resolve(dir, entry)));
      }
      return _results;
    });
  };
}).call(this);
