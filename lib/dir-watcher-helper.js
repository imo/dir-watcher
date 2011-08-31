(function() {
  var fs, isDirectory, isFile, iterateDirectory, iterateFilesOnly, path, walkDirectory;
  fs = require('fs');
  path = require('path');
  isDirectory = function(dir, callback) {
    return fs.stat(dir, function(err, stats) {
      if (err != null) {
        throw err;
      }
      return callback(stats.isDirectory());
    });
  };
  isFile = function(file, callback) {
    return fs.stat(file, function(err, stats) {
      if (err != null) {
        throw err;
      }
      return callback(stats.isFile());
    });
  };
  iterateDirectory = function(dir, iterator) {
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
  iterateFilesOnly = function(dir, iterator) {
    return fs.readdir(dir, function(err, entries) {
      var entry, file, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = entries.length; _i < _len; _i++) {
        entry = entries[_i];
        file = path.resolve(dir, entry);
        _results.push(isFile(file, function(isFileBoolean) {
          if (isFileBoolean) {
            return iterator(file);
          }
        }));
      }
      return _results;
    });
  };
  walkDirectory = function(dir, iterator) {
    return isDirectory(dir, function(isDir) {
      if (isDir) {
        iterator(dir);
        return iterateDirectory(dir, function(entry) {
          return walkDirectory(entry, iterator);
        });
      }
    });
  };
  exports.isDirectory = isDirectory;
  exports.isFile = isFile;
  exports.iterateDirectory = iterateDirectory;
  exports.iterateFilesOnly = iterateFilesOnly;
  exports.walkDirectory = walkDirectory;
}).call(this);
