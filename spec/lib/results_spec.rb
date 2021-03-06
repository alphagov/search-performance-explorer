require "rails_helper"

RSpec.describe Results do
  let(:left_data) do
    {
      "total" => left_result.count,
      "results" => left_result,
    }
  end

  let(:right_data) do
    {
      "total" => right_result.count,
      "results" => right_result,
    }
  end

  subject do
    described_class.new(
      left_data,
      right_data,
    )
  end
  context "when all data is visible on both sides" do
    let(:left_result) do
      [
        { "link" => "/Position-1" },
        { "link" => "/Position-2" },
        { "link" => "/Position-3" },
      ]
    end
    let(:right_result) do
      [
        { "link" => "/Position-2" },
        { "link" => "/Position-1" },
        { "link" => "/Position-3" },
      ]
    end
    it "can return the correct offset for a result" do
      expect(subject.score_difference("https://gov.uk/Position-1", 1)).to eq(-1)
      expect(subject.score_difference("https://gov.uk/Position-2", 0)).to eq(1)
      expect(subject.score_difference("https://gov.uk/Position-3", 2)).to eq(0)
    end
  end

  context "when only some data is visible on both sides" do
    let(:left_result) do
      [
        { "link" => "/Position-1" },
        { "link" => "/Position-2" },
        { "link" => "/Position-3" },
      ]
    end
    let(:right_result) do
      [
        { "link" => "/Position-3" },
        { "link" => "/Position-4" },
        { "link" => "/Position-5" },
      ]
    end
    it "can return the correct offset for a result" do
      expect(subject.score_difference("https://gov.uk/Position-3", 0)).to eq(2)
      expect(subject.score_difference("https://gov.uk/Position-4", 1)).to eq(nil)
      expect(subject.score_difference("https://gov.uk/Position-5", 2)).to eq(nil)
    end
  end
  context "when all data is the same on both sides" do
    let(:left_result) do
      [
        { "link" => "/Position-1" },
        { "link" => "/Position-2" },
        { "link" => "/Position-3" },
      ]
    end
    let(:right_result) do
      [
        { "link" => "/Position-1" },
        { "link" => "/Position-2" },
        { "link" => "/Position-3" },
      ]
    end
    it "can return the correct offset for a result" do
      expect(subject.score_difference("https://gov.uk/Position-1", 0)).to eq(0)
      expect(subject.score_difference("https://gov.uk/Position-2", 1)).to eq(0)
      expect(subject.score_difference("https://gov.uk/Position-3", 2)).to eq(0)
    end
  end
end
