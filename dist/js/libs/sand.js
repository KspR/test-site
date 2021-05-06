(function(name) {
  if (typeof(window) !== 'undefined') var sand = window[name] = {};
  else var sand = global[name] = {};

  var last = function(array) {
    return array[array.length - 1];
  };

  var each = function(array, f) {
    for (var i = -1, n = array.length; ++i < n; ) f(array[i], i);
    return array;
  };

  var keys = function(o) {
    var r = [];
    for (var i in o) r.push(i);
    return r;
  };
  
  sand.grains = {};
  
  var Grain = function(name, requires, fn, options) {
    this._grains = {};
    this.exports = {};
    this.name = name;
    this.innerName = last(name.split('/'));
    this.requires = requires;
    this.fn = fn;
    if (options) for (var i in options) this[i] = options[i];
  };
  
  Grain.prototype = {
    require : function(name) {
      if (sand.grains[name] && sand.grains[name].exports) {
        return sand.grains[name].exports;
      }
      return sand.getGrain(name).use(this, this);
    },
    
    use : function(local, sandbox, options, alias) {
      if (!local) local = this;
      if (!sandbox) sandbox = local;

      if (!sandbox._grains[this.name]) {
        sandbox._grains[this.name] = this;

        for (var i = this.requires.length; i--; ) {
          var split = this.requires[i].split('->');
          sand.getGrain(split[0]).use(this, sandbox, options, split[1] || null);
        }
        
        if (this.fn) {
          this.exports = this.fn(this.exports, this) || this.exports;
        }
      }
      
      local.exports[alias || this.innerName] = this.exports;
      return this.exports;
    }
  };
  
  sand.getGrain = function(name) {
    if (sand.grains[name]) {
      return sand.grains[name];
    }
    if (last(name) === '*') { // folder
      var lvl = name.split('/').length,
        subFolders = {},
        l = name.length - 2,
        searched = name.slice(0, l);
      if (sand.grains[name.slice(0, name.length - 2)]) return sand.grains[name.slice(0, name.length - 2)];
      for (var i in this.grains) {
        if (i.slice(0, l) === searched) {
          var join = i.split('/').slice(0, lvl).join('/');
          if (!this.grains[join]) subFolders[join + '/*'] = true;
          else subFolders[join] = true;
        }
      }
      return sand.define(name.slice(0, name.length - 2), keys(subFolders));
    }
    return sand.define(name);
  };

  sand.define = function(name, requires, fn, options) {
    if (typeof(requires) === 'function') {
      fn = requires;
      requires = [];
    }
    else if (typeof(requires) === 'undefined') requires = [];
    return this.grains[name] = new Grain(name, requires, fn, options);
  };
    
  var id = 0;
  
  sand.require = function() {
    var args = Array.prototype.slice.call(arguments);
    if (args.length === 1) {
      var app = new Grain('require-' + ++id);
      return (sand.grains[args[0]].use(app, app, null));
    }
    
    //--- parsing the requires
    var requires,
      fn = last(args);
    if (typeof(fn) !== 'function') {
      requires = args;
      fn = null;
    }
    else {
      requires = args.slice(0, args.length - 1);
    }
    //---
    
    var app = new Grain('require-' + ++id);
    each(requires, function(require) {
      var split = require.split('->'); // little repetition here for performance reasons
      sand.getGrain(split[0]).use(app, app, null, split[1] || null);
    });
    if (fn) return (fn(app.exports));
  };
  
})('sand');