require 'spec_helper'
require 'csv'

RSpec.describe Spree::Feefo::generate_feed, type: :model do

  before(:each) do
    Spree::Config[:feefo_logon] = 'www.example_logon.com'
    Spree::Config[:feefo_feed_name] = 'test_feefo_feed.csv'
    Spree::Config[:feefo_tmp_feed_location] = 'tmp'
    Spree::Config[:feefo_public_feed_location] = 'public'
  end

  context "there is a pending order" do
    it "feed is empty" do
      # Feefo.generate_feed
      # expect{
        # feefo_feed_values = CSV.read(Rails.root + "/public/test_feefo_feed.csv")
      # }.to eq([])
    end
  end
end
