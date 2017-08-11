require 'display_format_helper'
require 'rails_helper'

describe DisplayFormatHelper do
  describe "#date_format" do
    it 'responds to the mehtod' do
      expect(helper.respond_to?(:date_format)).to eq(true)
    end
    it 'returns nil if no date is given' do
      expect(helper.date_format(nil)).to eq(nil)
    end
    it 'returns the date in a readable format' do
      expect(helper.date_format("2014-12-09T16:21:03.000+00:00")).to eq("December 2014")
    end
  end

  describe "#link_format" do
    it 'returns an unchanged link if it starts with http or https' do
      expect(helper.link_format("http://www.example.com")).to eq("http://www.example.com")
      expect(helper.link_format("https://www.exampletron.com")).to eq("https://www.exampletron.com")
    end
    it 'adds https if the link starts with www.' do
      expect(helper.link_format("www.example.com")).to eq("https://www.example.com")
    end
    it 'adds https://gov.uk if the it\'s not an external link' do
      expect(helper.link_format("/example")).to eq("https://gov.uk/example")
    end
  end
end
