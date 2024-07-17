# frozen_string_literal: true

module DTRCore
  # Common methods used by the DTRCore module.
  module Common
    def split_strip_select(some_list)
      some_list&.split("\n")&.map(&:strip)&.select { |x| x.length.positive? }
    end

    def capture_section(pattern)
      captures = content.match(pattern)&.captures

      if content.scan(pattern).length > 1
        raise 'Multiple captures found for a section.'
      elsif captures
        captures&.first
      end
    end

    def clean_name(definition)
      definition.gsub(/[\*\n\[]/, '').strip
    end

    def self.get_input_content(some_string)
      start_index = some_string.index('input:')
      return nil if start_index.nil?

      start_parse_parent_index = some_string.index('(', start_index)

      paren_contents(some_string[start_parse_parent_index..])
    end

    def self.paren_contents(some_string)
      cur_word = ''
      index = 0
      cur_words = []
      how_many_deep_soft_brackets = 0
      how_many_deep_hard_brackets = 0
      how_many_deep_square_brackets = 0
      in_string = false

      while index < some_string.length
        char = some_string[index]

        if char == ')' && !in_string
          how_many_deep_soft_brackets -= 1

          if how_many_deep_soft_brackets.zero?
            cur_words.push(cur_word.strip) unless cur_word.empty?
            return cur_words
          else
            cur_word += char
          end
        elsif char == '[' && !in_string
          how_many_deep_square_brackets += 1
          cur_word += char
        elsif char == ']' && !in_string
          how_many_deep_square_brackets -= 1
          cur_word += char
        elsif char == '{' && !in_string
          how_many_deep_hard_brackets += 1
          cur_word += char
        elsif char == '}' && !in_string
          how_many_deep_hard_brackets -= 1
          cur_word += char
        elsif ['\'', '"'].include?(char)
          in_string = in_string ? false : true
          cur_word += char
        elsif char == '(' && !in_string
          how_many_deep_soft_brackets += 1
          cur_word += char if how_many_deep_soft_brackets > 1
        elsif char == ',' && how_many_deep_soft_brackets == 1 &&
              how_many_deep_hard_brackets.zero? &&
              how_many_deep_square_brackets.zero? &&
              !in_string
          cur_words.push(cur_word.strip) unless cur_word.empty?
          cur_word = ''
        else
          cur_word += char
        end

        index += 1
      end

      raise 'No closing parenthesis found.'
    end

    def self.nested_array_to_string(array)
      # Base case: if the element is not an array, return the element as a string
      return array.to_s unless array.is_a?(Array)

      # Recursively process each element in the array and join them with commas
      elements = array.map { |element| nested_array_to_string(element) }.join(', ')

      # Wrap the joined elements with parentheses
      "(#{elements})"
    end

    def self.parse_instruction_input(instruction)
      result = get_input_content(instruction)

      result.nil? || result.empty? ? nil : result
    end
  end
end
