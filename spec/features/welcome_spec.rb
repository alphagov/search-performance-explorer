require 'rails_helper'

feature 'visiting the homepage' do
  scenario 'the visitor sees the search title' do
    visit '/'
    expect(page).to have_text("Search")
  end

  scenario 'the visitor can input text and search result number and search' do
    visit '/'
    fill_in('search_term_input',  with: 'water')
    fill_in('result_count', with: '50')
    click_button 'Search'
    expect(page).to have_text("water")
    within("div.ab-search-wrapper-left") do
      expect(page).to have_css("div.changeless-box", count: 50)
    end
  end

  scenario 'when "search" is clicked without search term top 10 results are displayed' do
    visit '/'
    click_button 'Search'
    within("div.ab-search-wrapper-left") do
      expect(page).to have_css("div.changeless-box", count: 10)
    end
  end
end
