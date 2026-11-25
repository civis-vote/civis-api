require 'rails_helper'

RSpec.describe Constant, type: :model do
  it 'belongs to a parent constant' do
    parent = Constant.create!(name: 'Governance', constant_type: :segment)
    child = Constant.create!(name: 'Urban', constant_type: :segment, parent:)

    expect(child.parent).to eq(parent)
    expect(parent.children).to include(child)
  end

  it 'only accepts known constant types' do
    expect { Constant.create!(name: 'Odd', constant_type: :unknown_type) }.to raise_error(ArgumentError)
  end

  describe 'scopes' do
    it 'filters by constant type' do
      segment = Constant.create!(name: 'Urban', constant_type: :segment)
      Constant.create!(name: 'Taxation', constant_type: :clause_type)

      expect(Constant.constant_type_filter('segment')).to contain_exactly(segment)
    end
  end
end
