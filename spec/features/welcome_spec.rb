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
end
