require "rails_helper"

RSpec.describe Searching do
  let(:regular_search) { described_class.new("search" => { "count" => "20", "search_term" => "car tax", "host-a" => "production", "host-b" => "production" }) }
  let(:results_hash) { regular_search.call.results }

  describe "initialization" do
    it "initializes properly" do
      expect(regular_search.is_a?(described_class)).to eql(true)
    end
  end

  describe "result count" do
    it "defaults to 10 results if no count is enetered" do
      small_search = described_class.new("search" => { "count" => "", "search_term" => "car tax" })
      expect(small_search.count).to eql(10)
    end

    it "leaves the count as is for entered counts between 1 and 1000" do
      expect(regular_search.count).to eql(20)
    end

    it "caps the count at 1000 for very large searches" do
      large_search = described_class.new("search" => { "count" => "1001", "search_term" => "car tax" })
      expect(large_search.count).to eql(1000)
    end
  end

  describe "#ab_tests" do
    it "handles a single AB test" do
      search = described_class.new("search" => { "which_test" => "relevance,shingles" })
      expect(search.ab_tests("B")).to eql("relevance:B,shingles:B")
    end

    it "handles multiple AB tests" do
      search = described_class.new("search" => { "which_test" => "relevance" })
      expect(search.ab_tests("B")).to eql("relevance:B")
    end
  end
end
