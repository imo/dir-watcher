(function() {
  var fs, isDirectory, isDirectorySync, isFile, iterateDirectory, path, walkDirectory, walkDirectoryListSync;
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
  isDirectorySync = function(dir) {
    return fs.statSync(dir).isDirectory();
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
      if (err != null) {
        throw err;
      }
      _results = [];
      for (_i = 0, _len = entries.length; _i < _len; _i++) {
        entry = entries[_i];
        _results.push(iterator(path.resolve(dir, entry)));
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
  walkDirectoryListSync = function(dir) {
    var addDir, list;
    list = [];
    addDir = function(base) {
      var entry, _i, _len, _ref, _results;
      if (isDirectorySync(base)) {
        list.push(base);
        _ref = fs.readdirSync(base);
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          entry = _ref[_i];
          _results.push(addDir(path.resolve(base, entry)));
        }
        return _results;
      }
    };
    addDir(dir);
    return list;
  };
  exports.isDirectory = isDirectory;
  exports.isFile = isFile;
  exports.iterateDirectory = iterateDirectory;
  exports.walkDirectory = walkDirectory;
  exports.walkDirectoryListSync = walkDirectoryListSync;
}).call(this);
