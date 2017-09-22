require 'rails_helper'

RSpec.feature 'visiting the homepage' do
  before do
    filename = File.join(Rails.root, 'spec/fixtures/api_response.json')
    file = File.read(filename)

    stub_request(:get, /www.gov.uk/).
    to_return(status: 200, body: file.to_s, headers: {})
  end

  scenario 'the visitor sees the search title' do
    visit '/'
    expect(page).to have_text("Search")
  end

  scenario 'the visitor can input text and search result number and search' do
    visit '/'
    fill_in('search_term', with: 'car tax')
    fill_in('count', with: '20')
    click_button 'Search'
    expect(page).to have_text("car tax")
    within("table.results-table") do
      expect(page).to have_css("tr.table-row", count: 22)
    end
  end
end
