// Generated by CoffeeScript 1.9.3
(function() {
  exports.watchTranslations = function() {
    var buildTranslations, cp, deepen, fs;
    fs = require('fs');
    cp = require('child_process');
    deepen = function(o) {
      var k, key, oo, part, parts, t, v;
      oo = {};
      for (k in o) {
        v = o[k];
        t = oo;
        parts = k.split('.');
        key = parts.pop();
        while (parts.length) {
          part = parts.shift();
          t = t[part] = t[part] || {};
        }
        t[key] = o[k];
      }
      return oo;
    };
    buildTranslations = function() {
      return fs.readFile('./src/lang/translations', function(err, res) {
        var buffer, i, inTranslation, indent, j, keys, l, langs, line, lines, m, mode, n, nextIndent, raw, ref, ref1, ref2;
        raw = res.toString();
        lines = raw.split('\n');
        lines = lines.map(function(line) {
          var i, indent, len;
          res = {};
          indent = 0;
          len = line.length;
          i = 0;
          while (i < len) {
            if (line.charAt(i) === '\t') {
              indent++;
            } else {
              if (line.charAt(i) === '#') {
                res.comment = true;
              }
              break;
            }
            i++;
          }
          res.text = line.replace(/\t/g, '');
          res.indent = indent;
          return res;
        }).filter(function(line) {
          return !line.comment;
        });
        keys = [];
        keys = [];
        langs = [{}, {}];
        mode = null;
        buffer = '';
        for (i = l = 0, ref = lines.length; 0 <= ref ? l < ref : l > ref; i = 0 <= ref ? ++l : --l) {
          line = lines[i];
          console.log('------ new line ------');
          console.log(line, inTranslation, mode);
          console.log('---');
          if (mode !== 'multi') {
            if (line.text === '------') {
              mode = 'multi';
              inTranslation = 0;
              buffer = '';
            } else {
              indent = line.indent;
              if (lines[i + 1]) {
                nextIndent = lines[i + 1].indent;
                if (nextIndent === indent) {
                  console.log('same indent as next line');
                  if (!inTranslation) {
                    console.log('appended as new translation for current key ' + keys.join('.'));
                    langs[0][keys.join('.')] = line.text;
                    inTranslation = 1;
                  } else {
                    console.log('appended as translation for current key ' + keys.join('.'));
                    langs[inTranslation][keys.join('.')] = line.text;
                    inTranslation++;
                  }
                } else {
                  if (typeof inTranslation === 'number') {
                    console.log('appnded as last translation for current key ' + keys.join('.'));
                    langs[inTranslation][keys.join('.')] = line.text;
                    inTranslation = false;
                  }
                  if (nextIndent > indent) {
                    console.log('pushing key', keys.join('.'), line.text);
                    keys.push(line.text);
                  } else {
                    for (j = m = 0, ref1 = indent - nextIndent; 0 <= ref1 ? m < ref1 : m > ref1; j = 0 <= ref1 ? ++m : --m) {
                      keys.pop();
                      console.log('poping key');
                    }
                  }
                }
              } else {
                console.log('appended as last translation');
                langs[inTranslation][keys.join('.')] = line.text;
              }
            }
          } else {
            console.log('mode is multi', inTranslation, buffer);
            if (line.text === '------') {
              langs[inTranslation][keys.join('.')] = buffer;
              mode = null;
              inTranslation = false;
              indent = line.indent;
              if (lines[i + 1]) {
                nextIndent = lines[i + 1].indent;
                for (j = n = 0, ref2 = indent - nextIndent; 0 <= ref2 ? n < ref2 : n > ref2; j = 0 <= ref2 ? ++n : --n) {
                  keys.pop();
                  console.log('poping key');
                }
              }
            } else if (line.text === '---') {
              langs[inTranslation][keys.join('.')] = buffer;
              inTranslation++;
              buffer = '';
            } else {
              buffer += line.text;
            }
          }
        }
        return langs.map(function(json, i) {
          var lang;
          if (i === 0) {
            lang = 'en';
          } else if (i === 1) {
            lang = 'fr';
          }
          return fs.writeFile('./data/lang/' + lang + '.json', JSON.stringify(deepen(json), null, 2), function(err) {
            if (err) {
              return console.log('error writing translation file', err);
            }
          });
        });
      });
    };
    fs.watch('./src/lang/translations', function(eventType) {
      var e;
      if (eventType === 'change') {
        try {
          return buildTranslations();
        } catch (_error) {
          e = _error;
          return console.log(e);
        }
      }
    });
    return buildTranslations();
  };

}).call(this);
