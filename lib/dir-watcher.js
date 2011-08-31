(function() {
  var dwh, fs, inotify, inotifyFactory, path, util;
  var __indexOf = Array.prototype.indexOf || function(item) {
    for (var i = 0, l = this.length; i < l; i++) {
      if (this[i] === item) return i;
    }
    return -1;
  };
  dwh = require('./dir-watcher-helper');
  fs = require('fs');
  inotifyFactory = require('inotify-plusplus');
  path = require('path');
  util = require('util');
  inotify = void 0;
  exports.create = function(fileChangedCallback) {
    var addDirectory, watchedDirectories;
    watchedDirectories = [];
    addDirectory = function(dir) {
      dir = path.resolve(dir);
      return dwh.walkDirectory(dir, function(entry) {
        if (__indexOf.call(watchedDirectories, entry) < 0) {
          return watchedDirectories[entry] = inotify.watch({
            close_write: function(e) {
              return fileChangedCallback(path.resolve(e.watch, e.name));
            },
            create: function(e) {
              return addDirectory(path.resolve(e.watch, e.name));
            },
            moved_to: function(e) {
              var file;
              file = path.resolve(e.watch, e.name);
              return dwh.isFile(file, function(isFile) {
                if (isFile) {
                  return fileChangedCallback(path.resolve(e.watch, e.name));
                }
              });
            }
          }, entry);
        }
      });
    };
    return {
      get: function() {
        var key, value, _results;
        _results = [];
        for (key in watchedDirectories) {
          value = watchedDirectories[key];
          _results.push(key);
        }
        return _results;
      },
      watch: function(dir) {
        return addDirectory(dir);
      }
    };
  };
  exports.iterateFilesOnly = dwh.iterateFilesOnly;
  exports.setup = function(persist) {
    return inotify = inotifyFactory.create(persist);
  };
  exports.walkDirectory = dwh.walkDirectory;
}).call(this);
