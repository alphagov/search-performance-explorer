require_relative '../../app/lib/searching.rb'
require 'spec_helper'
require 'capybara/rspec'
require 'json'

# => I think we can run rake tasks in here...

describe Searching do
  let!(:regular_search) { Searching.new("search_term" => "car tax", "count" => 20) }
  # this is the search that was used in our sample JSON file (spec/fixtures/json/api_response_a)
  # This will be our default search and any others will be used to test methods
  let!(:results_hash) { regular_search.call.results }

  describe 'initialization' do
    it "initializes properly" do
      expect(regular_search.is_a?(Searching)).to eql(true)
    end
  end

  describe 'result count' do
    it "defaults to 10 results if no count is enetered" do
      small_search = Searching.new("search_term" => "car tax", "count" => "")
      expect(small_search.count).to eql(10)
    end

    it "leaves the count as is for entered counts between 1 and 1000" do
      expect(regular_search.count).to eql(20)
    end

    it "caps the count at 1000 for very large searches" do
      large_search = Searching.new("search_term" => "car tax", "count" => 1001)
      expect(large_search.count).to eql(1000)
    end
  end

  feature 'information gathering' do
    describe 'content_id' do
      it 'returns the content id for each entry' do
        content_id = results_hash[0].left[0][0]['content_id']
        expect(results_hash[0].content_id(results_hash[0].left)).to eql(content_id)
      end
    end

    describe 'public timestamp' do
      it "returns the timestamp" do
        raw_date = results_hash[0].left[0][0]['public_timestamp']
        expect(raw_date).to eql("2014-12-09T16:21:03.000+00:00")
        expect(results_hash[0].public_timestamp(results_hash[0].left)).to eql(raw_date)
      end
    end

    describe 'description' do
      it "returns the description for each item" do
        description = results_hash[0].left[0][0]['description']
        expect(results_hash[0].description(results_hash[0].left)).to eql(description)
      end
    end

    describe 'document collections' do
      it "returns an array or nil when document_collections is called" do
        expect(results_hash[0].document_collections(results_hash[0].left)).to eql(nil)
        expect(results_hash[19].document_collections(results_hash[19].left).is_a?(Array)).to eql(true)
      end
      it "returns a multi-dimensional array when a document collection is available" do
        expect(results_hash[19].document_collections(results_hash[19].left)[0].is_a?(Array)).to eql(true)
      end
      it "contains a title and link" do
        expected_title = "Tax information and impact notes"
        expected_link = "https://www.gov.uk/government/collections/tax-information-and-impact-notes-tiins"
        expect(results_hash[19].document_collections(results_hash[19].left)[0][0]).to eql(expected_title)
        expect(results_hash[19].document_collections(results_hash[19].left)[0][1]).to eql(expected_link)
      end
    end

    describe 'format' do
      it "returns the document format" do
        document_format = results_hash[0].left[0][0]['format']
        expect(results_hash[0].doc_format(results_hash[0].left)).to eql(document_format)
      end
    end

    describe 'is historical' do
      it 'returns true, false or nil' do
        expect(results_hash[0].is_historic(results_hash[0].left)).to eql(nil)
        expect(results_hash[5].is_historic(results_hash[5].left)).to eql(true)
        expect(results_hash[19].is_historic(results_hash[19].left)).to eql(false)
      end
    end

    describe 'link' do
      it 'returns the unformatted link' do
        link1 = "/vehicle-tax"
        link2 = "https://gov.uk/check-vehicle-tax"
        link3 = "www.fake-links.com/"
        expect(results_hash[0].link(results_hash[0].left)).to eql(link1)
        expect(results_hash[1].link(results_hash[1].left)).to eql(link2)
        expect(results_hash[2].link(results_hash[2].left)).to eql(link3)
      end
    end

    describe 'mainstream browse pages' do
      it "returns an array or nil when mainstream_browse_pages is called" do
        expect(results_hash[0].mainstream_browse_pages(results_hash[0].left).is_a?(Array)).to eql(true)
        expect(results_hash[19].mainstream_browse_pages(results_hash[19].left)).to eql(nil)
      end
      it "returns a multi-dimensional array when a mainstream browse page is available" do
        expect(results_hash[0].mainstream_browse_pages(results_hash[0].left)[0].is_a?(Array)).to eql(true)
      end
      it "contains a title and link" do
        expected_title = "driving / vehicle tax mot insurance"
        expected_link = "https://gov.uk/browse/driving/vehicle-tax-mot-insurance"
        expect(results_hash[0].mainstream_browse_pages(results_hash[0].left)[0][0]).to eql(expected_title)
        expect(results_hash[0].mainstream_browse_pages(results_hash[0].left)[0][1]).to eql(expected_link)
      end
    end

    describe 'organisations' do
      it "returns an array when organisations is called" do
        expect(results_hash[0].organisations(results_hash[0].left)).to eql(nil)
        expect(results_hash[19].organisations(results_hash[19].left).is_a?(Array)).to eql(true)
      end
      it "returns a multi-dimensional array when an organisation is available" do
        expect(results_hash[19].organisations(results_hash[19].left)[0].is_a?(Array)).to eql(true)
      end
      it "contains a title and link" do
        expected_title = "Department for Transport"
        expected_link = "https://gov.uk/government/organisations/department-for-transport"
        expect(results_hash[1].organisations(results_hash[1].left)[0][0]).to eql(expected_title)
        expect(results_hash[1].organisations(results_hash[1].left)[0][1]).to eql(expected_link)
      end
    end

    describe 'people' do
      it "returns an array when people is called" do
        expect(results_hash[0].people(results_hash[0].left)).to eql(nil)
        expect(results_hash[13].people(results_hash[13].left).is_a?(Array)).to eql(true)
      end
      it "returns a multi-dimensional array when a person is available" do
        expect(results_hash[13].people(results_hash[13].left)[0].is_a?(Array)).to eql(true)
      end
      it "contains a title and link" do
        expected_title = "The Rt Hon John Whittingdale"
        expected_link = "https://gov.uk/government/people/john-whittingdale"
        expect(results_hash[13].people(results_hash[13].left)[1][0]).to eql(expected_title)
        expect(results_hash[13].people(results_hash[13].left)[1][1]).to eql(expected_link)
      end
    end

    describe 'policies' do
      it "returns an array when policies is called" do
        expect(results_hash[0].policies(results_hash[0].left).is_a?(Array)).to eql(true)
        expect(results_hash[1].policies(results_hash[1].left)).to eql(nil)
      end
      it "returns a multi-dimensional array when a policy is available" do
        expect(results_hash[0].policies(results_hash[0].left)[0].is_a?(Array)).to eql(true)
      end
      it "contains a title and a dummy link" do
        expected_title = "personal tax reform"
        expected_link = ""
        expect(results_hash[0].policies(results_hash[0].left)[0][0]).to eql(expected_title)
        expect(results_hash[0].policies(results_hash[0].left)[0][1]).to eql(expected_link)
      end
    end

    describe 'popularity' do
      it 'returns the popularity' do
        popularity = results_hash[0].left[0][0]['popularity']
        expect(results_hash[0].popularity(results_hash[0].left)).to eql(popularity)
      end
    end

    describe 'taxons' do
      it "returns an array when taxon is called" do
        expect(results_hash[0].taxons(results_hash[0].left).is_a?(Array)).to eql(true)
        expect(results_hash[1].taxons(results_hash[1].left)).to eql(nil)
      end
      it "returns a multi-dimensional array when a taxon is available" do
        expect(results_hash[0].taxons(results_hash[0].left)[0].is_a?(Array)).to eql(true)
      end
      it "contains a title and a dummy link" do
        expected_title = "2b669b7d-c9d8-40b7-8b55-aa68a0615daa"
        expected_link = ""
        expect(results_hash[0].taxons(results_hash[0].left)[0][0]).to eql(expected_title)
        expect(results_hash[0].taxons(results_hash[0].left)[0][1]).to eql(expected_link)
      end
    end

    describe 'title' do
      it 'returns the title' do
        title = results_hash[0].left[0][0]['title']
        expect(results_hash[0].title(results_hash[0].left)).to eql(title)
      end
    end

    describe 'specialist_sectors' do
      it "returns an array when specialist_sector is called" do
        expect(results_hash[1].specialist_sectors(results_hash[1].left)).to eql(nil)
        expect(results_hash[15].specialist_sectors(results_hash[15].left).is_a?(Array)).to eql(true)
      end
      it "returns a multi-dimensional array when a specialist sector is available" do
        expect(results_hash[15].specialist_sectors(results_hash[15].left)[0].is_a?(Array)).to eql(true)
      end
      it "has arrays within that contain a title and link" do
        expected_title = "Get and check an MOT"
        expected_link = "https://gov.uk/topic/mot/get-check-mot"
        expect(results_hash[15].specialist_sectors(results_hash[15].left)[0][0]).to eql(expected_title)
        expect(results_hash[15].specialist_sectors(results_hash[15].left)[0][1]).to eql(expected_link)
      end
    end
  end

  describe 'external request' do
    it 'creates a class that sends a request to rummager' do
      results = regular_search.call
      expect(results.class).to eql(Searching::Results)
    end
  end
end
