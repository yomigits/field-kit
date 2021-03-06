'use strict';

Object.defineProperty(exports, '__esModule', {
  value: true
});

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ('value' in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

var _get = function get(_x, _x2, _x3) { var _again = true; _function: while (_again) { var object = _x, property = _x2, receiver = _x3; desc = parent = getter = undefined; _again = false; if (object === null) object = Function.prototype; var desc = Object.getOwnPropertyDescriptor(object, property); if (desc === undefined) { var parent = Object.getPrototypeOf(object); if (parent === null) { return undefined; } else { _x = parent; _x2 = property; _x3 = receiver; _again = true; continue _function; } } else if ('value' in desc) { return desc.value; } else { var getter = desc.get; if (getter === undefined) { return undefined; } return getter.call(receiver); } } };

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { 'default': obj }; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError('Cannot call a class as a function'); } }

function _inherits(subClass, superClass) { if (typeof superClass !== 'function' && superClass !== null) { throw new TypeError('Super expression must either be null or a function, not ' + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

var _delimited_text_formatter = require('./delimited_text_formatter');

var _delimited_text_formatter2 = _interopRequireDefault(_delimited_text_formatter);

/**
 * @const
 * @private
 */
var NANPPhoneDelimiters = {
  0: '(',
  4: ')',
  5: ' ',
  9: '-'
};

/**
 * @const
 * @private
 */
var NANPPhoneDelimitersWithOne = {
  1: ' ',
  2: '(',
  6: ')',
  7: ' ',
  11: '-'
};

/**
 * @const
 * @private
 */
var NANPPhoneDelimitersWithPlus = {
  2: ' ',
  3: '(',
  7: ')',
  8: ' ',
  12: '-'
};

/**
 * This should match any characters in the maps above.
 *
 * @const
 * @private
 */
var DELIMITER_PATTERN = /[-\(\) ]/g;

/**
 * @extends DelimitedTextFormatter
 */

var PhoneFormatter = (function (_DelimitedTextFormatter) {
  _inherits(PhoneFormatter, _DelimitedTextFormatter);

  /**
   * @throws {Error} if anything is passed in
   * @param {Array} args
   */

  function PhoneFormatter() {
    _classCallCheck(this, PhoneFormatter);

    _get(Object.getPrototypeOf(PhoneFormatter.prototype), 'constructor', this).call(this);

    for (var _len = arguments.length, args = Array(_len), _key = 0; _key < _len; _key++) {
      args[_key] = arguments[_key];
    }

    if (args.length !== 0) {
      throw new Error('were you trying to set a delimiter (' + args[0] + ')?');
    }
  }

  /**
   * @param {string} chr
   * @returns {boolean}
   */

  _createClass(PhoneFormatter, [{
    key: 'isDelimiter',
    value: function isDelimiter(chr) {
      var map = this.delimiterMap;
      for (var index in map) {
        if (map.hasOwnProperty(index)) {
          if (map[index] === chr) {
            return true;
          }
        }
      }
      return false;
    }

    /**
     * @param {number} index
     * @returns {?string}
     */
  }, {
    key: 'delimiterAt',
    value: function delimiterAt(index) {
      return this.delimiterMap[index];
    }

    /**
     * @param {number} index
     * @returns {boolean}
     */
  }, {
    key: 'hasDelimiterAtIndex',
    value: function hasDelimiterAtIndex(index) {
      var delimiter = this.delimiterAt(index);
      return delimiter !== undefined && delimiter !== null;
    }

    /**
     * Will call parse on the formatter.
     *
     * @param {string} text
     * @param {function(string)} error
     * @returns {string} returns value with delimiters removed
     */
  }, {
    key: 'parse',
    value: function parse(text, error) {
      if (!error) {
        error = function () {};
      }
      var digits = this.digitsWithoutCountryCode(text);
      // Source: http://en.wikipedia.org/wiki/North_American_Numbering_Plan
      //
      // Area Code
      if (text.length < 10) {
        error('phone-formatter.number-too-short');
      }
      if (digits[0] === '0') {
        error('phone-formatter.area-code-zero');
      }
      if (digits[0] === '1') {
        error('phone-formatter.area-code-one');
      }
      if (digits[1] === '9') {
        error('phone-formatter.area-code-n9n');
      }
      // Central Office Code
      if (digits[3] === '1') {
        error('phone-formatter.central-office-one');
      }
      if (digits.slice(4, 6) === '11') {
        error('phone-formatter.central-office-n11');
      }
      return _get(Object.getPrototypeOf(PhoneFormatter.prototype), 'parse', this).call(this, text, error);
    }

    /**
     * @param {string} value
     * @returns {string}
     */
  }, {
    key: 'format',
    value: function format(value) {
      this.guessFormatFromText(value);
      return _get(Object.getPrototypeOf(PhoneFormatter.prototype), 'format', this).call(this, this.removeDelimiterMapChars(value));
    }

    /**
     * Determines whether the given change should be allowed and, if so, whether
     * it should be altered.
     *
     * @param {TextFieldStateChange} change
     * @param {function(string)} error
     * @returns {boolean}
     */
  }, {
    key: 'isChangeValid',
    value: function isChangeValid(change, error) {
      this.guessFormatFromText(change.proposed.text);

      if (change.inserted.text.length > 1) {
        // handle pastes
        var text = change.current.text;
        var selectedRange = change.current.selectedRange;
        var toInsert = change.inserted.text;

        // Replace the selection with the new text, remove non-digits, then format.
        var formatted = this.format((text.slice(0, selectedRange.start) + toInsert + text.slice(selectedRange.start + selectedRange.length)).replace(/[^\d]/g, ''));

        change.proposed = {
          text: formatted,
          selectedRange: {
            start: formatted.length - (text.length - (selectedRange.start + selectedRange.length)),
            length: 0
          }
        };

        return _get(Object.getPrototypeOf(PhoneFormatter.prototype), 'isChangeValid', this).call(this, change, error);
      }

      if (/^\d*$/.test(change.inserted.text) || change.proposed.text.indexOf('+') === 0) {
        return _get(Object.getPrototypeOf(PhoneFormatter.prototype), 'isChangeValid', this).call(this, change, error);
      } else {
        return false;
      }
    }

    /**
     * Re-configures this formatter to use the delimiters appropriate
     * for the given text.
     *
     * @param {string} text A potentially formatted string containing a phone number.
     * @private
     */
  }, {
    key: 'guessFormatFromText',
    value: function guessFormatFromText(text) {
      if (text && text[0] === '+') {
        this.delimiterMap = NANPPhoneDelimitersWithPlus;
        this.maximumLength = 1 + 1 + 10 + 5;
      } else if (text && text[0] === '1') {
        this.delimiterMap = NANPPhoneDelimitersWithOne;
        this.maximumLength = 1 + 10 + 5;
      } else {
        this.delimiterMap = NANPPhoneDelimiters;
        this.maximumLength = 10 + 4;
      }
    }

    /**
     * Gives back just the phone number digits as a string without the
     * country code. Future-proofing internationalization where the country code
     * isn't just +1.
     *
     * @param {string} text
     * @private
     */
  }, {
    key: 'digitsWithoutCountryCode',
    value: function digitsWithoutCountryCode(text) {
      var digits = (text || '').replace(/[^\d]/g, '');
      var extraDigits = digits.length - 10;
      if (extraDigits > 0) {
        digits = digits.substr(extraDigits);
      }
      return digits;
    }

    /**
     * Removes characters from the phone number that will be added
     * by the formatter.
     *
     * @param {string} text
     * @private
     */
  }, {
    key: 'removeDelimiterMapChars',
    value: function removeDelimiterMapChars(text) {
      return (text || '').replace(DELIMITER_PATTERN, '');
    }
  }]);

  return PhoneFormatter;
})(_delimited_text_formatter2['default']);

exports['default'] = PhoneFormatter;
module.exports = exports['default'];