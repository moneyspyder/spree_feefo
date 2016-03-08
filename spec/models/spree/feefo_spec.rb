require 'spec_helper'
require 'csv'

RSpec.describe Spree::Feefo, type: :model do

  before(:each) do
    Spree::Config[:feefo_merchant_identifier] = 'example_site'
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

    let!(:store) { FactoryGirl.create(:store, default: true ) }
    let(:billing_address) {FactoryGirl.create(:address) }
    let(:order) do
      o = Spree::Order.create(email: "email@domain.com")
      o.billing_address = billing_address
      o.save
      o
    end
    let(:variant) { create(:variant) }
    let!(:line_item) { order.contents.add variant }
    let!(:shipment) do
      order.create_proposed_shipments.first
      s = order.shipments.first
      s.state = "shipped"
      s.shipped_at = (DateTime.now - 48.hours)
      s.save
      s
    end

    before(:each) do
      Feefo.generate_feed
      @feed_content = CSV.open(File.join(Rails.root, 'public/test_feefo_feed.csv'), "r", {col_sep: "\t", encoding: "UTF-8"}).read
    end

    it "finds 1 shipped order" do
      expect( @feed_content.length ).to eq(2)
    end

    it "has the expected attributes" do
      shipment = Spree::Shipment.last
      puts "#{ @feed_content[0] }"
      puts "#{ @feed_content[1] }"
      expected_result =[
        [
          "name",
          "email",
          "date",
          "description",
          "merchant identifier",
          "category",
          "feedback fate",
          "product search code",
          "order Ref",
          "product link",
          "customer Ref",
          "amount"
        ],
        [
          shipment.order.name,
          shipment.order.email,
          shipment.shipped_at.strftime('%Y-%m-%d'),
          shipment.manifest.first.line_item.product.name.strip,
          Spree::Config[:feefo_merchant_identifier],
          shipment.manifest.first.line_item.product.taxons.order(:lft).first.try(:name).to_s,
          '',
          shipment.manifest.first.line_item.product.sku,
          shipment.order.number,
          Spree::Core::Engine.routes.url_helpers.product_url(shipment.manifest.first.line_item.product, host: Spree::Store.default.url),
          shipment.order.user ? shipment.order.user.id : '',
          shipment.order.total.to_f.to_s
        ]
      ]
      expect(@feed_content).to eq(expected_result)
    end
  end
end
