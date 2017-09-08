require 'rails_helper'

RSpec.describe ResultHelper do
  context 'when the result cannot be found in the list on the right' do
    it 'returns found' do
      expect(compare(3, nil)).to eql('found')
      expect(compare(6, nil)).to eql('found')
    end
  end

  context 'when the result is higher on the right list than the left' do
    it 'returns up' do
      expect(compare(3, 5)).to eql('up')
      expect(compare(1, 62)).to eql('up')
    end
  end

  context 'when the result is lower on the right list than the left' do
    it 'returns down' do
      expect(compare(5, 1)).to eql('down')
      expect(compare(42, 22)).to eql('down')
    end
  end

  context 'when the two results are equal' do
    it 'returns changeless' do
      expect(compare(4, 4)).to eql('changeless')
      expect(compare(23, 23)).to eql('changeless')
    end
  end
end
