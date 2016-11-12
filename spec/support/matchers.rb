require 'rspec/expectations'

RSpec::Matchers.define :deserialize_as do |expected|
  match do |actual|
    ActiveFeed::Serializable::Deserializer.klass_instance(actual).eql?(expected)
  end
end

RSpec::Matchers.define :serialize_to do |expected|
  match do |actual|
    actual.to_af == expected
  end
end
