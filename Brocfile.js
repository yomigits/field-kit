var browserify = require('broccoli-browserify');
var concat = require('broccoli-concat');
var ENV = process.env.ENVIRONMENT || 'development';
var es6class = require('es6-class');
var Filter = require('broccoli-filter');

function es6(inputTree) {
  var es6classFilter = new Filter(inputTree, {
    extensions: ['js'],
    targetExtensions: ['js']
  });
  es6classFilter.processString = function(source) {
    return es6class.compile(source);
  };
  return es6classFilter;
}

module.exports = function(broccoli) {
  var lib = broccoli.makeTree('lib');
  var test = broccoli.makeTree('test');
  var qunit = broccoli.makeTree('node_modules/qunit/support/qunit/qunit');

  var fieldKit = browserify(es6(lib), {
    entries: ['./index'],
    outputFile: '/field-kit.js',
    bundle: { debug: false, standalone: 'FieldKit' }
  });

  var testSetup = browserify(test, {
    entries: ['./test_helper'],
    outputFile: '/test/setup.js'
  });

  var allTests = concat(test, {
    inputFiles: ['**/*_test.js'],
    outputFile: '/test/all.js'
  });

  switch (ENV) {
    case 'development':
      return [es6(fieldKit), es6(testSetup), allTests, test, qunit];

    case 'production':
      return [es6(fieldKit)];
  }
};
