class CaseBuilder
  # should not use attr_reader because it makes variable available outside class ?
  attr_reader :resource

  def self.build(resource)
    @resource = resource

    
  end


end