class Array
  def sequence(i)
    self[i % length]
  end
end

# rubocop:disable Metrics/BlockLength
FactoryBot.define do
  factory :method, class: 'Yarr::Query::Method' do
    sequence :flavour do |i|
      %w[class instance].sequence(i)
    end

    sequence :name do |i|
      myklass = Object.const_get(klass.name)
      case flavour
      when 'instance' then myklass.instance_methods
      when 'class' then myklass.methods
      end.sequence(i)
    end

    url do
      "Array.html#method-#{flavour[0]}-#{name}"
    end

    origin { klass.origin }
    association :klass

    to_create(&:save)
  end

  factory :origin, class: 'Yarr::Query::Origin' do
    sequence :id

    sequence :name do |i|
      %w[core mkmf].sequence(i)
    end

    to_create(&:save)
  end

  factory :klass, class: 'Yarr::Query::Klass' do
    sequence :id

    sequence :name do |i|
      %w[Array String Hash Enumerable].sequence(i)
    end

    url { "#{name}.html" }

    flavour { name == 'Enumerable' ? 'module' : 'class' }

    association :origin, name: 'core'

    to_create(&:save)
  end
end
# rubocop:enable Metrics/BlockLength
