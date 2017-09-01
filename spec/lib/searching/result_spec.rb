require 'rails_helper'

RSpec.describe Searching::Result do
  let(:sample_data) do
    {
      "title": "Tax your vehicle",
      "link": "/vehicle-tax",
      "popularity": 0.07692308,
      "description": "Renew or tax your vehicle for the first time using a reminder letter, your log book, the 'new keeper's details' section of a log book - and how to tax if you don't have any documents",
      "format": "transaction",
      "content_id": "fa748fae-3de4-4266-ae85-0797ada3f40c",
      "mainstream_browse_pages": [
        "driving/vehicle-tax-mot-insurance"
      ],
      "policies": [
        "personal-tax-reform",
        "business-tax-reform"
      ],
      "taxons": [
        "2b669b7d-c9d8-40b7-8b55-aa68a0615daa",
        "bb4c54b9-5b3c-4c2e-8473-a57e2442f386"
      ],
      "organisations": [
        {
          "title": "Department for Transport",
          "link": "/government/organisations/department-for-transport",
        },
        {
          "title": "Driver and Vehicle Licensing Agency",
          "link": "/government/organisations/driver-and-vehicle-licensing-agency",
        }
      ]
    }
  end
  subject do
    described_class.new(sample_data)
  end

  describe "#date_format" do
    let(:sample_data) do
      {"public_timestamp": "2014-12-09T16:21:03.000+00:00"}
    end
    it 'can return the date in a more readable fashion' do
      expect(subject.date_format(subject[:public_timestamp])).to eq("December 2014")
      expect(subject.date_format("2035-04-09T16:21:03.000+00:00")).to eq("April 2035")
    end
  end

  describe "#historical_or_current" do
    it 'returns "Current" if given false' do
      expect(subject.historical_or_current(false)).to eq("Current")
    end

    it 'returns "Historical" if given true' do
      expect(subject.historical_or_current(true)).to eq("Historical")
    end
  end

  describe "#link_format" do
    it 'returns an unchanged link if it starts with http or https' do
      expect(subject.link_format("http://www.example.com")).to eq("http://www.example.com")
      expect(subject.link_format("https://www.exampletron.com")).to eq("https://www.exampletron.com")
    end

    it 'adds https if the link starts with www.' do
      expect(subject.link_format("www.example.com")).to eq("https://www.example.com")
    end

    it 'adds https://gov.uk if the it\'s not an external link' do
      expect(subject.link_format("/example")).to eq("https://gov.uk/example")
    end
  end

  describe "#make_readable" do
    it "removes hyphons" do
      expect(subject.make_readable("test-the-readability-improver")).to eql("test the readability improver")
    end

    it "adds a space around each side of a /" do
      expect(subject.make_readable("gov.uk/browse/benifits")).to eql("gov.uk / browse / benifits")
    end
  end

  describe "#name" do
    it "takes a gov.uk link, removes \"https://www.gov.uk/\" and makes the result more readable" do

      expect(subject.name).to
    end
  end

  context "returning enhanced results" do
#    it "gets data out of the information hash" do
#      expected_hash = {
#        "mainstream_browse_pages" =>
#      }
#      expect()
#    end
  end
end
