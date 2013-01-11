NumberFormatter = require '../lib/number_formatter'

describe 'NumberFormatter', ->
  formatter = null

  beforeEach ->
    formatter = new NumberFormatter()

  describe 'by default', ->
    it 'has US-standard number prefixes and suffixes', ->
      expect(formatter.positivePrefix()).toEqual("")
      expect(formatter.positiveSuffix()).toEqual("")
      expect(formatter.negativePrefix()).toEqual("-")
      expect(formatter.negativeSuffix()).toEqual("")

    it 'has no fraction digits', ->
      expect(formatter.minimumFractionDigits()).toEqual(0)
      expect(formatter.maximumFractionDigits()).toEqual(0)

    it 'does not always show the decimal separator', ->
      expect(formatter.alwaysShowsDecimalSeparator()).toBeFalsy()

    it 'has the US-standard decimal separator', ->
      expect(formatter.decimalSeparator()).toEqual('.')

    it 'rounds half even', ->
      expect(formatter.roundingMode()).toEqual(NumberFormatter.Rounding.HALF_EVEN)

    it 'has no minimum', ->
      expect(formatter.minimum()).toBeNull()

    it 'has no maximum', ->
      expect(formatter.maximum()).toBeNull()

  describe '#numberFromString', ->
    it 'is an alias for #parse', ->
      expect(formatter.numberFromString).toBe(formatter.parse)

  describe '#minusSign', ->
    it 'is an alias for #negativePrefix', ->
      expect(formatter.minusSign).toBe(formatter.negativePrefix)
      expect(formatter.setMinusSign).toBe(formatter.setNegativePrefix)

  describe '#format', ->
    describe 'given a positive number', ->
      describe 'with custom prefix and suffix', ->
        beforeEach ->
          formatter.setPositivePrefix '<POS>'
          formatter.setPositiveSuffix '</POS>'

        it 'adds them', ->
          expect(formatter.format 8).toEqual('<POS>8</POS>')

      describe 'with maximumFractionDigits = 0', ->
        beforeEach ->
          formatter.setMaximumFractionDigits 0

        it 'formats integers without a fractional part', ->
          expect(formatter.format 50).toEqual('50')

        it 'formats floats without a fractional part', ->
          expect(formatter.format 50.8).toEqual('50')

      describe 'with maximumFractionDigits = 1', ->
        beforeEach ->
          formatter.setMaximumFractionDigits 1

        it 'formats integers without a fractional part', ->
          expect(formatter.format 50).toEqual('50')

        it 'formats floats truncating the fractional part if needed', ->
          expect(formatter.format 50.8).toEqual('50.8')
          expect(formatter.format 50.87).toEqual('50.8')

      describe 'with maximumFractionDigits > 1', ->
        beforeEach ->
          formatter.setMaximumFractionDigits 2

        it 'formats integers without a fractional part', ->
          expect(formatter.format 50).toEqual('50')

        it 'formats floats truncating the fractional part if needed', ->
          expect(formatter.format 3.1).toEqual('3.1')
          expect(formatter.format 3.14).toEqual('3.14')
          expect(formatter.format 3.141).toEqual('3.14')

        describe 'with minimumFractionDigits = 1', ->
          beforeEach ->
            formatter.setMinimumFractionDigits 1

          it 'formats integers with a fractional 0', ->
            expect(formatter.format 50).toEqual('50.0')

          it 'formats floats as normal', ->
            expect(formatter.format 50.4).toEqual('50.4')

      describe 'with alwaysShowsDecimalSeparator = true', ->
        beforeEach ->
          formatter.setAlwaysShowsDecimalSeparator yes

        it 'formats integers with a decimal separator', ->
          expect(formatter.format 9).toEqual('9.')

        it 'formats floats as normal', ->
          formatter.setMaximumFractionDigits 1
          expect(formatter.format 8.1).toEqual('8.1')

      describe 'with a custom decimal separator', ->
        beforeEach ->
          formatter.setDecimalSeparator 'SEP'
          formatter.setMaximumFractionDigits 1

        it 'formats integers without the separator', ->
          expect(formatter.format 77).toEqual('77')

        it 'formats floats with the separator', ->
          expect(formatter.format 77.7).toEqual('77SEP7')

      describe 'with ceiling rounding', ->
        beforeEach ->
          formatter.setRoundingMode NumberFormatter.Rounding.CEILING
          formatter.setMaximumFractionDigits 1

        it 'does not round integers', ->
          expect(formatter.format 4).toEqual('4')

        it 'does not round floats with fraction digits less than or the same as the maximum', ->
          expect(formatter.format 3.1).toEqual('3.1')

        it 'rounds floats with non-zero digits past the maximum', ->
          expect(formatter.format 3.14).toEqual('3.2')
          expect(formatter.format 3.01).toEqual('3.1')

        it 'rounds to the next integer if no fraction digits are allowed', ->
          formatter.setMaximumFractionDigits 0
          expect(formatter.format 1.1).toEqual('2')
          expect(formatter.format 1.01).toEqual('2')

      describe 'with floor rounding', ->
        beforeEach ->
          formatter.setRoundingMode NumberFormatter.Rounding.FLOOR
          formatter.setMaximumFractionDigits 1

        it 'does not round integers', ->
          expect(formatter.format 4).toEqual('4')

        it 'does not round floats with fraction digits less than or the same as the maximum', ->
          expect(formatter.format 3.1).toEqual('3.1')

        it 'rounds floats with non-zero digits past the maximum', ->
          expect(formatter.format 1.11).toEqual('1.1')
          expect(formatter.format 1.19).toEqual('1.1')

      describe 'with half-even rounding', ->
        beforeEach ->
          formatter.setRoundingMode NumberFormatter.Rounding.HALF_EVEN
          formatter.setMaximumFractionDigits 1

        it 'does not round integers', ->
          expect(formatter.format 4).toEqual('4')

        it 'does not round floats with fraction digits less than or the same as the maximum', ->
          expect(formatter.format 0.1).toEqual('0.1')

        it 'rounds floats with non-zero digits past the maximum', ->
          expect(formatter.format 0.35).toEqual('0.4')
          expect(formatter.format 0.25).toEqual('0.2')

        describe 'rounding to integers', ->
          beforeEach ->
            formatter.setMaximumFractionDigits 0

          it 'rounds toward even integers', ->
            expect(formatter.format 0.5).toEqual('0')
            expect(formatter.format 1.5).toEqual('2')

    describe 'given a negative number', ->
      describe 'with custom prefix and suffix', ->
        beforeEach ->
          formatter.setNegativePrefix '<NEG>'
          formatter.setNegativeSuffix '</NEG>'

        it 'adds them', ->
          expect(formatter.format -8).toEqual('<NEG>8</NEG>')

      describe 'with ceiling rounding', ->
        beforeEach ->
          formatter.setRoundingMode NumberFormatter.Rounding.CEILING
          formatter.setMaximumFractionDigits 1

        it 'does not round integers', ->
          expect(formatter.format -4).toEqual('-4')

        it 'does not round floats with no non-zero fraction digits past the maximum', ->
          expect(formatter.format -3.10).toEqual('-3.1')

        it 'rounds floats with non-zero digits past the maximum', ->
          expect(formatter.format -3.19).toEqual('-3.1')

      describe 'with floor rounding', ->
        beforeEach ->
          formatter.setRoundingMode NumberFormatter.Rounding.FLOOR
          formatter.setMaximumFractionDigits 1

        it 'does not round integers', ->
          expect(formatter.format -4).toEqual('-4')

        it 'does not round floats with no non-zero fraction digits past the maximum', ->
          expect(formatter.format -3.10).toEqual('-3.1')

        it 'rounds floats with non-zero digits past the maximum', ->
          expect(formatter.format -3.11).toEqual('-3.2')

      describe 'with half-even rounding', ->
        beforeEach ->
          formatter.setRoundingMode NumberFormatter.Rounding.HALF_EVEN
          formatter.setMaximumFractionDigits 1

        it 'does not round integers', ->
          expect(formatter.format -4).toEqual('-4')

        it 'does not round floats with fraction digits less than or the same as the maximum', ->
          expect(formatter.format -0.1).toEqual('-0.1')

        it 'rounds floats with non-zero digits past the maximum', ->
          expect(formatter.format -0.35).toEqual('-0.4')
          expect(formatter.format -0.25).toEqual('-0.2')

    describe '#parse', ->
      it 'parses normal positive numbers', ->
        expect(formatter.parse '8').toEqual(8)

      it 'parses normal negative numbers', ->
        expect(formatter.parse '-8').toEqual(-8)

      describe 'with a minimum value', ->
        beforeEach ->
          formatter.setMinimum 1

        it 'fails to parse the string when below the minimum', ->
          expect(formatter.parse '0').toBeNull()

        it 'has a specific error type when the string is below the minimum', ->
          errorCallback = jasmine.createSpy('errorCallback')
          formatter.parse '0', errorCallback
          expect(errorCallback).toHaveBeenCalledWith('number-formatter.out-of-bounds.below-minimum')

        it 'parses the string when above the minimum', ->
          expect(formatter.parse '2').toEqual(2)

      describe 'with a maximum value', ->
        beforeEach ->
          formatter.setMaximum 5

        it 'fails to parse the string when above the maximum', ->
          expect(formatter.parse '7').toBeNull()

        it 'has a specific error type when the string is above the maximum', ->
          errorCallback = jasmine.createSpy('errorCallback')
          formatter.parse '7', errorCallback
          expect(errorCallback).toHaveBeenCalledWith('number-formatter.out-of-bounds.above-maximum')

        it 'parses the string when below the maximum', ->
          expect(formatter.parse '2').toEqual(2)

      describe 'with allowsFloats = true', ->
        beforeEach ->
          formatter.setAllowsFloats yes

        it 'parses integers', ->
          expect(formatter.parse '4').toEqual(4)

        it 'parses floats', ->
          expect(formatter.parse '2.5').toEqual(2.5)

      describe 'with allowsFloats = false', ->
        beforeEach ->
          formatter.setAllowsFloats no

        it 'parses integers', ->
          expect(formatter.parse '4').toEqual(4)

        it 'fails to parse floats', ->
          expect(formatter.parse '2.5').toBeNull()

        it 'has a specific error type when trying to parse floats', ->
          errorCallback = jasmine.createSpy('errorCallback')
          formatter.parse '2.5', errorCallback
          expect(errorCallback).toHaveBeenCalledWith('number-formatter.floats-not-allowed')

      describe 'with a custom decimal separator', ->
        beforeEach ->
          formatter.setDecimalSeparator 'SEP'

        it 'parses floats with the custom decimal separator', ->
          expect(formatter.parse '2SEP5').toEqual(2.5)

        it 'fails to parse strings with multiple decimal separators', ->
          errorCallback = jasmine.createSpy('errorCallback')
          expect(formatter.parse '1SEP3SEP5', errorCallback).toBeNull()
          expect(errorCallback).toHaveBeenCalledWith('number-formatter.invalid-format')

      describe 'with a custom positive prefix and suffix', ->
        beforeEach ->
          formatter.setPositivePrefix('+').setPositiveSuffix('=)')

        it 'fails to parse the "typical" positive format', ->
          errorCallback = jasmine.createSpy('errorCallback')
          expect(formatter.parse '3', errorCallback).toBeNull()
          expect(errorCallback).toHaveBeenCalledWith('number-formatter.invalid-format')

        it 'parses strings with the custom positive prefix and suffix', ->
          expect(formatter.parse '+3=)').toEqual(3)

      describe 'with a custom negative prefix and suffix', ->
        beforeEach ->
          formatter.setNegativePrefix('(').setNegativeSuffix(')')

        it 'fails to parse the "typical" negative format', ->
          errorCallback = jasmine.createSpy('errorCallback')
          expect(formatter.parse '-3', errorCallback).toBeNull()
          expect(errorCallback).toHaveBeenCalledWith('number-formatter.invalid-format')

        it 'parses strings with the custom negative prefix and suffix', ->
          expect(formatter.parse '(3)').toEqual(-3)
