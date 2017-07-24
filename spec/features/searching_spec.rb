require_relative '../../app/lib/searching.rb'
require 'spec_helper'
require 'capybara/rspec'
require 'json'


describe Searching do

  let!(:searchatron_snr) {Searching.new({"search_term" => "car tax", "count" => 1001 })}
  let!(:searchatron) {Searching.new({"search_term" => "car tax", "count" => 20 })}
  # this is the search that was used in our sample JSON file (app/assets/json/api_response_a)
  # This will be our default search and any others will be used to test methods
  let!(:searchatron_jnr) {Searching.new({"search_term" => "car tax", "count" => "" })}
  let!(:results_hash) {searchatron.call.results}

  feature 'initialization' do
    it "should initialize properly" do
      expect(searchatron.is_a?(Searching)).to eql(true)
    end
  end

  feature 'result count' do
    it "should default to 10 results if no count is enetered" do
      count = searchatron_jnr.count
      expect(count).to eql(10)
    end

    it "should leave the count as is for entered counts between 1 and 1000" do
      count = searchatron.count
      expect(count).to eql(20)
    end

    it "should reduce the count to 1000 for counts entered over 1000" do
      count = searchatron_snr.count
      expect(count).to eql(1000)
    end
  end

  feature 'information gathering' do

    feature 'content_id' do
      it 'should return the content id for each entry' do
        content_id = results_hash[0].left[0][0]['content_id']
        expect(results_hash[0].content_id(results_hash[0].left)).to eql(content_id)
      end
    end

    feature 'date' do
      it "should display date data in a readable format" do
        raw_date = results_hash[0].left[0][0]['public_timestamp']
        expect(raw_date).to eql("2014-12-09T16:21:03.000+00:00")
        expect(results_hash[0].date(results_hash[0].left)).to eql("December 2014")
      end
    end

    feature 'description' do
      it "should return the description for each item" do
        description = results_hash[0].left[0][0]['description']
        expect(results_hash[0].description(results_hash[0].left)).to eql(description)
      end
    end

    feature 'document collections' do
      it "should return an array or nil when document_collections is called" do
        expect(results_hash[0].document_collections(results_hash[0].left)).to eql(nil)
        expect(results_hash[19].document_collections(results_hash[19].left).is_a?(Array)).to eql(true)
      end
      it "should return a multi-dimensional array when a document collection is available" do
        expect(results_hash[19].document_collections(results_hash[19].left)[0].is_a?(Array)).to eql(true)
      end
      it "should contain a title and link" do
        expected_title = "Tax information and impact notes"
        expected_link = "https://www.gov.uk/government/collections/tax-information-and-impact-notes-tiins"
        expect(results_hash[19].document_collections(results_hash[19].left)[0][0]).to eql(expected_title)
        expect(results_hash[19].document_collections(results_hash[19].left)[0][1]).to eql(expected_link)
      end
    end

    feature 'format' do
      it "should return the document format" do
        document_format = results_hash[0].left[0][0]['format']
        expect(results_hash[0].doc_format(results_hash[0].left)).to eql(document_format)
      end
    end

    feature 'historical' do
      it 'should return "Historical", "Current" or nil' do
        expect(results_hash[0].historical(results_hash[0].left)).to eql(nil)
        expect(results_hash[5].historical(results_hash[5].left)).to eql("Historical")
        expect(results_hash[19].historical(results_hash[19].left)).to eql("Current")
      end
    end

    feature 'link' do
      it 'should return a fully formatted link for each result' do
        # => These commented out variables aren't used but are simply in place to show
        # => how the method formats links, they are examples of the format that links
        # => can come in straight from the API
        # => current_link_1 = "/vehicle-tax"
        # => current_link_2 = "https://gov.uk/check-vehicle-tax"
        # => current_link_3 = "www.fake-links.com/"
        expected_link_1 = "https://gov.uk/vehicle-tax"
        expected_link_2 = "https://gov.uk/check-vehicle-tax"
        expected_link_3 = "https://www.fake-links.com/"
        expect(results_hash[0].link(results_hash[0].left)).to eql(expected_link_1)
        expect(results_hash[1].link(results_hash[1].left)).to eql(expected_link_2)
        expect(results_hash[2].link(results_hash[2].left)).to eql(expected_link_3)
      end
    end

    feature 'mainstream browse pages' do
      it "should return an array or nil when mainstream_browse_pages is called" do
        expect(results_hash[0].mainstream_browse_pages(results_hash[0].left).is_a?(Array)).to eql(true)
        expect(results_hash[19].mainstream_browse_pages(results_hash[19].left)).to eql(nil)
      end
      it "should return a multi-dimensional array when a mainstream browse page is available" do
        expect(results_hash[0].mainstream_browse_pages(results_hash[0].left)[0].is_a?(Array)).to eql(true)
      end
      it "should contain a title and link" do
        expected_title = "driving / vehicle tax mot insurance"
        expected_link = "https://gov.uk/browse/driving/vehicle-tax-mot-insurance"
        expect(results_hash[0].mainstream_browse_pages(results_hash[0].left)[0][0]).to eql(expected_title)
        expect(results_hash[0].mainstream_browse_pages(results_hash[0].left)[0][1]).to eql(expected_link)
      end
    end

    feature 'name' do
      it 'should change the format of the link to be more readable, thus displaying the base path' do
        expected_name_1 = "vehicle tax direct debit"
        expected_name_2 = "government / publications / income tax company car tax rates and bands for 2017 to 2018 and 2018 to 2019"
        expect(results_hash[3].name(results_hash[3].left)).to eql(expected_name_1)
        expect(results_hash[18].name(results_hash[18].left)).to eql(expected_name_2)
      end
    end

    feature 'organisations' do
      it "should return an array when organisations is called" do
        expect(results_hash[0].organisations(results_hash[0].left)).to eql(nil)
        expect(results_hash[19].organisations(results_hash[19].left).is_a?(Array)).to eql(true)
      end
      it "should return a multi-dimensional array when an organisation is available" do
        expect(results_hash[19].organisations(results_hash[19].left)[0].is_a?(Array)).to eql(true)
      end
      it "should contain a title and link" do
        expected_title = "Department for Transport"
        expected_link = "https://gov.uk/government/organisations/department-for-transport"
        expect(results_hash[1].organisations(results_hash[1].left)[0][0]).to eql(expected_title)
        expect(results_hash[1].organisations(results_hash[1].left)[0][1]).to eql(expected_link)
      end
    end

    feature 'people' do
      it "should return an array when people is called" do
        expect(results_hash[0].people(results_hash[0].left)).to eql(nil)
        expect(results_hash[13].people(results_hash[13].left).is_a?(Array)).to eql(true)
      end
      it "should return a multi-dimensional array when a person is available" do
        expect(results_hash[13].people(results_hash[13].left)[0].is_a?(Array)).to eql(true)
      end
      it "should contain a title and link" do
        expected_title = "The Rt Hon John Whittingdale"
        expected_link = "https://gov.uk/government/people/john-whittingdale"
        expect(results_hash[13].people(results_hash[13].left)[1][0]).to eql(expected_title)
        expect(results_hash[13].people(results_hash[13].left)[1][1]).to eql(expected_link)
      end
    end

    feature 'policies' do
      it "should return an array when policies is called" do
        expect(results_hash[0].policies(results_hash[0].left).is_a?(Array)).to eql(true)
        expect(results_hash[1].policies(results_hash[1].left)).to eql(nil)
      end
      it "should return a multi-dimensional array when a policy is available" do
        expect(results_hash[0].policies(results_hash[0].left)[0].is_a?(Array)).to eql(true)
      end
      it "should contain a title and a dummy link" do
        expected_title = "personal tax reform"
        expected_link = ""
        expect(results_hash[0].policies(results_hash[0].left)[0][0]).to eql(expected_title)
        expect(results_hash[0].policies(results_hash[0].left)[0][1]).to eql(expected_link)
      end
    end

    feature 'popularity' do
      it 'should return the popularity' do
        popularity = results_hash[0].left[0][0]['popularity']
        expect(results_hash[0].popularity(results_hash[0].left)).to eql(popularity)
      end
    end

    feature 'taxons' do
      it "should return an array when taxon is called" do
        expect(results_hash[0].taxons(results_hash[0].left).is_a?(Array)).to eql(true)
        expect(results_hash[1].taxons(results_hash[1].left)).to eql(nil)
      end
      it "should return a multi-dimensional array when a taxon is available" do
        expect(results_hash[0].taxons(results_hash[0].left)[0].is_a?(Array)).to eql(true)
      end
      it "should contain a title and a dummy link" do
        expected_title = "2b669b7d-c9d8-40b7-8b55-aa68a0615daa"
        expected_link = ""
        expect(results_hash[0].taxons(results_hash[0].left)[0][0]).to eql(expected_title)
        expect(results_hash[0].taxons(results_hash[0].left)[0][1]).to eql(expected_link)
      end
    end

    feature 'title' do
      it 'should return the title' do
        title = results_hash[0].left[0][0]['title']
        expect(results_hash[0].title(results_hash[0].left)).to eql(title)
      end
    end

    feature 'specialist_sectors' do
      it "should return an array when specialist_sector is called" do
        expect(results_hash[1].specialist_sectors(results_hash[1].left)).to eql(nil)
        expect(results_hash[15].specialist_sectors(results_hash[15].left).is_a?(Array)).to eql(true)
      end
      it "should return a multi-dimensional array when a specialist sector is available" do
        expect(results_hash[15].specialist_sectors(results_hash[15].left)[0].is_a?(Array)).to eql(true)
      end
      it "should have arrays within that contain a title and link" do
        expected_title = "Get and check an MOT"
        expected_link = "https://gov.uk/topic/mot/get-check-mot"
        expect(results_hash[15].specialist_sectors(results_hash[15].left)[0][0]).to eql(expected_title)
        expect(results_hash[15].specialist_sectors(results_hash[15].left)[0][1]).to eql(expected_link)
      end
    end

  end

  feature 'external request' do
    it 'creates a class that sends a request to rummager' do
      results = searchatron.call
      expect(results.class).to eql(Searching::Results)
    end
  end

end
