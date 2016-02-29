require 'spec_helper'
require 'csv'

RSpec.describe Spree::Feefo, type: :model do

  before(:each) do
    Spree::Config[:feefo_logon] = 'www.example_logon.com'
    Spree::Config[:feefo_feed_name] = 'test_feefo_feed.csv'
    Spree::Config[:feefo_tmp_feed_location] = 'tmp'
    Spree::Config[:feefo_public_feed_location] = ''
  end

  context "there is a pending order" do
    it "feed is empty" do
      Feefo.generate_feed
      CSV.read(File.join(Rails.root, 'public/test_feefo_feed.csv')) == []
    end
  end

  context "there is 1 shipped order" do
    before(:each) do
      FactoryGirl.create(:shipment, state: 'shipped', shipped_at: (DateTime.now - 48.hours))
    end

    it "finds 1 shipped order" do
      Feefo.generate_feed
      CSV.read(File.join(Rails.root, 'public/test_feefo_feed.csv')).count == 1
    end
  end
end
