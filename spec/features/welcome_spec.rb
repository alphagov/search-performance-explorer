require 'rails_helper'

feature 'visiting the homepage' do
  scenario 'the visitor sees the search title' do
    visit root_path
    expect(page).to have_text("Search")
  end
end
