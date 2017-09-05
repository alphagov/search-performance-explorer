require 'rails_helper'

RSpec.describe Searching::Results do
  let(:left_data) do
    {
      'total' => left_result.count,
      'results' => left_result
    }
  end

  let(:right_data) do
    {
      'total' => right_result.count,
      'results' => right_result
    }
  end

  subject do
    described_class.new(
      left_data,
      right_data
    )
  end
  context 'when all data is visible on both sides' do
    let(:left_result) do
      [
        { 'link' => 'Position 1' },
        { 'link' => 'Position 2' },
        { 'link' => 'Position 3' },
      ]
    end
    let(:right_result) do
      [
        { 'link' => 'Position 2' },
        { 'link' => 'Position 1' },
        { 'link' => 'Position 3' },
      ]
    end
    it 'can return the correct offset for a result' do
      expect(subject.score_difference("Position 1", 1)).to eq(["-1", "down-box"])
      expect(subject.score_difference("Position 2", 0)).to eq(["+1", "up-box"])
      expect(subject.score_difference("Position 3", 2)).to eq(["N/A", "changeless-box"])
    end
  end

  context 'when only some data is visible on both sides' do
    let(:left_result) do
      [
        { 'link' => 'Position 1' },
        { 'link' => 'Position 2' },
        { 'link' => 'Position 3' },
      ]
    end
    let(:right_result) do
      [
        { 'link' => 'Position 3' },
        { 'link' => 'Position 4' },
        { 'link' => 'Position 5' },
      ]
    end
    it 'can return the correct offset for a result' do
      expect(subject.score_difference("Position 3", 0)).to eq(["+2", "up-box"])
      expect(subject.score_difference("Position 4", 1)).to eq(["+++++", "up-box"])
      expect(subject.score_difference("Position 5", 2)).to eq(["+++++", "up-box"])
    end
  end
  context 'when all data is the same on both sides' do
    let(:left_result) do
      [
        { 'link' => 'Position 1' },
        { 'link' => 'Position 2' },
        { 'link' => 'Position 3' },
      ]
    end
    let(:right_result) do
      [
        { 'link' => 'Position 1' },
        { 'link' => 'Position 2' },
        { 'link' => 'Position 3' },
      ]
    end
    it 'can return the correct offset for a result' do
      expect(subject.score_difference("Position 1", 0)).to eq(["N/A", "changeless-box"])
      expect(subject.score_difference("Position 2", 1)).to eq(["N/A", "changeless-box"])
      expect(subject.score_difference("Position 3", 2)).to eq(["N/A", "changeless-box"])
    end
  end
end
