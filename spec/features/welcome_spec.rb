require 'rails_helper'

feature 'visiting the homepage' do
  scenario 'the visitor sees the search title' do
    visit '/'
    expect(page).to have_text("Search")
  end

  scenario 'the visitor can input text and search result number and search' do
    visit '/'
    fill_in('search_term',  with: 'water')
    fill_in('count', with: '50')
    click_button 'Search'
    expect(page).to have_text("water")
    within("table.results-table") do
      expect(page).to have_css("tr.table-row", count: 52)
    end
  end

  scenario 'when "search" is clicked without search term top 10 results are displayed' do
    visit '/'
    click_button 'Search'
    within("table.results-table") do
      expect(page).to have_css("tr.table-row", count: 12)
      # => 10 rows for the results, one header and a result count at the bottom
    end
  end

  scenario 'the search function accepts search terms of different lengths' do
    visit '/'
    fill_in('search_term',  with: 'apple gds')
    fill_in('count', with: '50')
    expect(page.status_code).to eq(200)

    visit '/'
    fill_in('search_term',  with: 'jonathan james hallam')
    fill_in('count', with: '50')
    expect(page.status_code).to eq(200)

    visit '/'
    fill_in('search_term',  with: 'water system control')
    fill_in('count', with: '50')
    expect(page.status_code).to eq(200)

    visit '/'
    fill_in('search_term',  with: 'I recently smuggled a cheetah to the UK from Ethiopia, unfortunately it won\'t fit in my flat and I would like somebody to come and collect it')
    fill_in('count', with: '50')
    expect(page.status_code).to eq(200)
  end

end
