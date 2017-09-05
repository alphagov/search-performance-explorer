require 'rails_helper'

RSpec.describe Searching::Result do
  subject { described_class.new(sample_data) }

  describe "#name" do
    let(:sample_data) do
      { "link" => "/vehicle-tax" }
    end
    it "makes the link path more readable" do
      expect(subject.name).to eql("/ vehicle tax")
    end
  end

  context "returning enhanced results" do
    let(:sample_data) do
      {
        "mainstream_browse_pages" => ["driving/vehicle-tax-mot-insurance"],
        "taxons" => [
          "2b669b7d-c9d8-40b7-8b55-aa68a0615daa",
          "bb4c54b9-5b3c-4c2e-8473-a57e2442f386"
        ]
      }
    end
    it "gets mainstream browse pages out of the information hash and formats their link" do
      expected_hash = {
        "Mainstream Browse Pages" => [
          ["driving / vehicle tax mot insurance", "https://gov.uk/browse/driving/vehicle-tax-mot-insurance"]
        ]
      }
      expect(subject.enhanced_results(%w(mainstream_browse_pages))).to eql(expected_hash)
    end
    it "gets taxons out of the information hash and returns them with an empty string" do
      expected_hash = {
        "Taxons" => [
          ["2b669b7d c9d8 40b7 8b55 aa68a0615daa", ""],
          ["bb4c54b9 5b3c 4c2e 8473 a57e2442f386", ""]
        ]
      }
      expect(subject.enhanced_results(%w(taxons))).to eql(expected_hash)
    end
    it "returns an empty hash when the field isn't present" do
      expected_hash = {}
      expect(subject.enhanced_results(%w(policies))).to eql(expected_hash)
    end
  end

  context "people and organisations" do
    let(:sample_data) do
      {
        "people" => [
          {
            "title" => "The Rt Hon David Evennett MP",
            "link" => "/government/people/david-evennett"
          },
          {
            "title" => "The Rt Hon John Whittingdale",
            "link" => "/government/people/john-whittingdale"
          }
        ],
        "organisations" => [
          {
            "title" => "Driver and Vehicle Licensing Agency",
            "link" => "/government/organisations/driver-and-vehicle-licensing-agency"
          }
        ]
      }
    end
    it "returns the links for people pages and their link in an array" do
      expected_array = [
        ["The Rt Hon David Evennett MP", "https://gov.uk/government/people/david-evennett"],
        ["The Rt Hon John Whittingdale", "https://gov.uk/government/people/john-whittingdale"]
      ]
      expect(subject.second_head(%w(people))).to eql(expected_array)
    end

    it "returns the links for organisation pages and their link in an array" do
      expected_array = [
        ["Driver and Vehicle Licensing Agency", "https://gov.uk/government/organisations/driver-and-vehicle-licensing-agency"]
      ]
      expect(subject.second_head(%w(organisations))).to eql(expected_array)
    end
  end

  context "primary head information" do
    let(:sample_data) do
      {
        "format" => "answer",
        "public_timestamp" => "2015-04-03T00:01:07.000+01:00",
        "is_historic" => true,
        "popularity" => 0.0013315579
      }
    end
    it "returns the format and date in readable formats if no arguments are passed in" do
      expected_array = ["Answer", "April 2015"]
      expect(subject.get_head_info_list([])).to eql(expected_array)
    end

    it "returns a full array of all elements if is historic and popularity are passed in" do
      expected_array = ["Answer", "April 2015", "Historical", "Popularity: 0.0013315579"]
      expect(subject.get_head_info_list(%w(is_historic popularity))).to eql(expected_array)
    end
  end
end
