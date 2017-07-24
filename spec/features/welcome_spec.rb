require 'rails_helper'

feature 'visiting the homepage' do
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
