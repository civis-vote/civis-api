require 'rails_helper'

RSpec.describe Queries::Constant::List, type: :graphql do
  let(:query) do
    <<~GQL
      query GetConstants($constantType: ConstantTypes, $sort: ConstantSort, $sortDirection: SortDirections) {
        constantList(constantType: $constantType, sort: $sort, sortDirection: $sortDirection) {
          data {
            id
            name
            constantType
          }
          paging {
            currentPage
            totalItems
            totalPages
          }
        }
      }
    GQL
  end

  let(:variables) { { constantType: 'area_of_impact' } }
  let(:result) { CivisApiSchema.execute(query, variables: variables, context: {}) }
  let(:constants) { result.dig('data', 'constantList', 'data') }
  let(:paging) { result.dig('data', 'constantList', 'paging') }

  describe 'constantList query' do
    it 'returns only constants of the given type' do
      area_of_impact = Constant.create!(name: 'Karnataka', constant_type: :area_of_impact)
      Constant.create!(name: 'Segment One', constant_type: :segment)

      expect(constants.map { |c| c['id'] }).to include(area_of_impact.id)
      expect(constants.all? { |c| c['constantType'] == 'area_of_impact' }).to be(true)
    end

    context 'when no constant type is provided' do
      let(:variables) { {} }

      it 'returns constants across all types' do
        Constant.create!(name: 'Karnataka', constant_type: :area_of_impact)
        Constant.create!(name: 'Segment One', constant_type: :segment)

        returned_types = constants.map { |c| c['constantType'] }.uniq
        expect(returned_types).to include('area_of_impact', 'segment')
      end
    end

    context 'when sorted by name' do
      let(:variables) { { constantType: 'area_of_impact', sort: 'name', sortDirection: 'asc' } }

      it 'returns constants in ascending order' do
        Constant.create!(name: 'Zeta', constant_type: :area_of_impact)
        Constant.create!(name: 'Alpha', constant_type: :area_of_impact)

        names = constants.map { |c| c['name'] }
        expect(names.index('Alpha')).to be < names.index('Zeta')
      end
    end

    it 'returns paging metadata' do
      Constant.create!(name: 'Karnataka', constant_type: :area_of_impact)

      expect(paging['currentPage']).to eq(1)
      expect(paging['totalItems']).to be >= 1
      expect(paging['totalPages']).to be >= 1
    end
  end
end
