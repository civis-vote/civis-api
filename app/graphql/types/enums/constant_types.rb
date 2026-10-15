class Types::Enums::ConstantTypes < Types::BaseEnum
  ::CONSTANT_TYPES.each do |constant_type|
    value constant_type.to_s
  end
end
