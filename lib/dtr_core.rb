# frozen_string_literal: true

# Core logic for consuming Digicus Textual Representation (DTR) files.
module DTRCore
  autoload :Contract, 'dtr_core/contract'
  autoload :Function, 'dtr_core/function'
  autoload :Number, 'dtr_core/number'
  autoload :Parser, 'dtr_core/parser'
  autoload :State, 'dtr_core/state'
  autoload :SupportedAttributes, 'dtr_core/supported_attributes'
  autoload :TypeValidator, 'dtr_core/type_validator'
  autoload :InstructionValidator, 'dtr_core/instruction_validator'
  autoload :Instruction, 'dtr_core/instruction'
  autoload :UserDefinedType, 'dtr_core/user_defined_type'

  # A graph is a collection of nodes and edges representing the structure of a DTR file.
  module Graph
    autoload :LCPBT_Forrest, 'dtr_core/graph/lcpbt_forrest'
    autoload :LeftChildPreferentialBinaryTree, 'dtr_core/graph/left_child_preferential_binary_tree'
    autoload :Silviculturist, 'dtr_core/graph/silviculturist'
  end
end
