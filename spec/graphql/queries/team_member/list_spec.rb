require 'rails_helper'

RSpec.describe Queries::TeamMember::List, type: :graphql do
  let!(:team_member) { create(:team_member, member_type: :team) }
  let!(:advisor) { create(:team_member, member_type: :advisory) }
  let!(:inactive) { create(:team_member, status: :inactive) }

  let(:query) do
    <<~GQL
      query ListTeamMembers($memberTypeFilter: TeamMemberTypes, $page: Int, $perPage: Int) {
        teamMemberList(memberTypeFilter: $memberTypeFilter, page: $page, perPage: $perPage) {
          data { id name memberType }
          paging { totalItems }
        }
      }
    GQL
  end

  let(:variables) { { memberTypeFilter: 'team' } }
  let(:result) { gql_execute(query, variables: variables, context: {}) }
  let(:listed) { result.dig('data', 'teamMemberList') }
  let(:listed_ids) { listed['data'].map { |m| m['id'].to_i } }

  it 'lists active members of the requested type' do
    expect(listed_ids).to contain_exactly(team_member.id)
    expect(listed_ids).not_to include(advisor.id, inactive.id)
  end

  it 'lists advisors when asked' do
    result = gql_execute(query, variables: { memberTypeFilter: 'advisory' }, context: {})
    ids = result.dig('data', 'teamMemberList', 'data').map { |m| m['id'].to_i }

    expect(ids).to eq([advisor.id])
  end

  # Documents a gap: the argument has no default, so a query without memberTypeFilter 500s.
  it 'errors when the query omits memberTypeFilter' do
    bare_query = query.gsub('$memberTypeFilter: TeamMemberTypes, ', '').gsub('memberTypeFilter: $memberTypeFilter, ', '')
    result = gql_execute(bare_query, variables: {}, context: {})

    expect(result.dig('data', 'teamMemberList')).to be_nil
    expect(result['errors'].first['message']).to include('member_type_filter')
  end
end
