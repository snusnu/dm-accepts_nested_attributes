module ConstraintSupport

  def constraint_options(type)
    if DataMapper.const_defined?('Constraints')
      { :constraint => type }
    else
      {}
    end
  end

end
