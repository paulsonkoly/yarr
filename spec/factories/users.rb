# User double
User = Struct.new :nick, :host_unsynced, :online?

FactoryBot.define do
  factory :user do
    nick { Faker::Internet.username(nil, ['_']) }
    host_unsynced { Faker::Internet.domain_name }
    factory :operator do
      host_unsynced { "#{Yarr.config.ops_host_mask}#{nick.delete('_')}" }
    end
    online? { true }
  end
end
