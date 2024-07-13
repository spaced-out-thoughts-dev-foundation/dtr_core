# frozen_string_literal: true

module DTRCore
  module Graph
    class Silviculturist
      attr_accessor :forrest

      def initialize(instructions)
        @instructions = instructions
        @forrest = LCPBT_Forrest.new
        @seen_instructions = {}
      end

      def make_forrest
        index = 0
        while index < @instructions.size
          instructions = @instructions[index..]
          scope = 0
          tree = plant_trees(scope, instructions)
          @forrest.add_tree(tree)

          seen = true
          while seen && index < @instructions.size
            index += 1
            seen = @instructions[index].nil? || @seen_instructions[@instructions[index].id]
          end
        end
      end

      def plant_trees(scope, instructions, from_id: nil, indentation: 0)
        cur_instruction = instructions[0]

        return nil if cur_instruction.nil?

        if cur_instruction.scope != scope
          return plant_trees(scope, instructions[1..], from_id: cur_instruction.id,
                                                       indentation:)
        end

        return @seen_instructions[cur_instruction.id] if @seen_instructions[cur_instruction.id]

        down_jump = cur_instruction.instruction == 'jump' && (
          (cur_instruction.inputs.size == 1 && cur_instruction.inputs[0].to_i < scope) ||
          (cur_instruction.inputs.size == 2 && cur_instruction.inputs[1].to_i < scope))

        rest_of_instructions = instructions[1..]

        tree = LeftChildPreferentialBinaryTree.new(cur_instruction,
                                                   indentation: if down_jump
                                                                  indentation - 1
                                                                else
                                                                  indentation
                                                                end)
        @seen_instructions[cur_instruction.id] = tree

        case cur_instruction.instruction
        when 'jump'
          case cur_instruction.inputs.size
          # unconditional jump
          when 1
            new_scope = cur_instruction.inputs[0].to_i

            # halt when going back to 0
            return tree if new_scope.zero?

            tree.set_left_child(plant_trees(new_scope, rest_of_instructions, from_id: cur_instruction.id,
                                                                             indentation: down_jump ? indentation - 1 : indentation + 1))
          # conditional jump
          when 2
            # detour
            new_scope = cur_instruction.inputs[1].to_i

            tree.set_left_child(plant_trees(new_scope, rest_of_instructions,
                                            from_id: cur_instruction.id, indentation: down_jump ? indentation - 1 : indentation + 1))
            # continue
            tree.set_right_child(plant_trees(scope, rest_of_instructions, from_id: cur_instruction.id,
                                                                          indentation:))
          # if-let
          when 3
            raise 'We do not yet support if-let statements'
          end
        # the way a goto works is that you want to drop out of the loop back to the scope you were at
        # when you started the loop
        when 'goto'
          goto_target_id = cur_instruction.inputs[0].to_i
          return_scope = @instructions.find { |x| x.id == goto_target_id }.scope

          return tree if return_scope.zero?

          # TODO: fix indentation
          tree.set_left_child(plant_trees(return_scope.to_i, rest_of_instructions, from_id: cur_instruction.id,
                                                                                   indentation:))
        else
          # left_child
          tree.set_left_child(plant_trees(scope, rest_of_instructions, from_id: cur_instruction.id,
                                                                       indentation:))
        end

        tree
      end
    end
  end
end