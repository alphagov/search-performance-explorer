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
  let!(:results_hash) {searchatron.call.results[0]}

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
    it 'should return the content id for each entry' do
      content_id = results_hash.left[0][0]['content_id']
      expect(results_hash.content_id(results_hash.left)).to eql(content_id)
    end

    it "should display date data in a readable format" do
      raw_date = results_hash.left[0][0]['public_timestamp']
      expect(raw_date).to eql("2014-12-09T16:21:03.000+00:00")
      expect(results_hash.date(results_hash.left)).to eql("December 2014")
    end

    it "should return the description for each item" do
      description = results_hash.left[0][0]['description']
      expect(results_hash.description(results_hash.left)).to eql(description)
    end

  end

  feature 'external request' do
    it 'creates a class that sends a request to rummager' do
      results = searchatron.call
      expect(results.class).to eql(Searching::Results)
    end
  end
end
