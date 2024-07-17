# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe DTRCore::Common do
  describe 'paren_contents' do
    context 'when a string is given' do
      it 'returns the contents of the parens' do
        actual = described_class.paren_contents('(10, (11))')
        expected = ['10', '(11)']

        expect(actual).to eq(expected)
      end

      it 'returns the contents of the parens when the contents are slightly more complex' do
        actual = described_class.paren_contents('(10, (11, (12, 13), 14), 15)')
        expected = ['10', '(11, (12, 13), 14)', '15']

        expect(actual).to eq(expected)
      end

      it 'returns the contents of the parens when the contents are a real example' do
        actual = described_class.paren_contents('("hello", Some(1), Foo(10, (11)))')
        expected = ['"hello"', 'Some(1)', 'Foo(10, (11))']

        expect(actual).to eq(expected)
      end

      it 'does not encroach on content after the parens' do
        actual = described_class.paren_contents('(10, (11)), 12')
        expected = ['10', '(11)']

        expect(actual).to eq(expected)
      end

      it 'does not split on commas within brackets and strings' do
        actual = described_class.paren_contents('(10, (11, "hello, world"), [12, 13, 14], {15, {16}})')
        expected = ['10', '(11, "hello, world")', '[12, 13, 14]', '{15, {16}}']

        expect(actual).to eq(expected)
      end
    end
  end

  describe 'get_input_content' do
    context 'when a string is given' do
      it 'returns the input content' do
        actual = described_class.get_input_content('input:(true, "hello", 11, 10.1)')
        expected = ['true', '"hello"', '11', '10.1']

        expect(actual).to eq(expected)
      end
    end
  end

  describe 'parse_instruction_input' do
    context 'when no instruction is given' do
      it 'returns nil' do
        expect(described_class.parse_instruction_input('input:()')).to be_nil
      end
    end

    context 'when simple instructions are given' do
      it 'returns an array with bool, string, int, float' do
        actual = described_class.parse_instruction_input('input:(true, "hello", 11, 10.1)')
        expected = %w[true hello 11 10.1]

        expect(actual).to eq(expected)
      end
    end

    context 'when instruction with parens is given' do
      it 'returns nested inputs' do
        actual = described_class.parse_instruction_input('input:("hello", Some(1), Foo(10, (11)))')
        expected = ['"hello"', 'Some(1)', 'Foo(10, (11))']

        expect(actual).to eq(expected)
      end
    end
  end
end
