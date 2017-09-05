require 'rails_helper'

RSpec.describe ResultHelper do
  context 'when enhanched info is disabled' do
    let(:params) do
      {
        'info' => 'basic',
        'specialist_sectors' => 'on'
      }
    end

    it 'always returns false' do
      expect(enabled?("mainstream_browse_pages")).to eq(false)
      expect(enabled?("specialist_sectors")).to eq(false)
    end
  end

  context 'when enhanced info is enabled' do
    let(:params) do
      {
        'info' => 'enhanced',
        'specialist_sectors' => 'on'
      }
    end

    it 'always returns true only for parameters that are enabled' do
      expect(enabled?("mainstream_browse_pages")).to eq(false)
      expect(enabled?("specialist_sectors")).to eq(true)
    end
  end
end
