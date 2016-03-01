
class Feefo

  require Rails.root.join('app', 'helpers', 'application_helper')
  include ApplicationHelper
  include Rails.application.routes.url_helpers
  require 'csv'



  def self.generate_feed(start_date = nil, end_date = nil)

    start_date ||= Time.zone.now.beginning_of_day - 1.months
    end_date ||= Time.zone.now.beginning_of_day

    tmp_path = File.join(Rails.root, Spree::Config[:feefo_tmp_feed_location].to_s)
    end_path = File.join(Rails.root, 'public', Spree::Config[:feefo_public_feed_location].to_s)
    FileUtils.mkdir_p(tmp_path)
    FileUtils.mkdir_p(end_path)
    tmp_filepath = File.join(tmp_path, Spree::Config[:feefo_feed_name])
    end_filepath = File.join(end_path, Spree::Config[:feefo_feed_name])

    CSV.open(tmp_filepath, "w", {col_sep: "\t", encoding: "UTF-8"}) do |file|
      file << [
        'Name',
        'Email',
        'Date',
        'Description',
        'Logon',
        'Category',
        'Feedback Date',
        'Product search code',
        'Order Ref',
        'Product link',
        'Customer Ref',
        'Amount'
      ]

      logon = Spree::Config[:feefo_logon]

       Spree::Shipment.where(state: "shipped", shipped_at: start_date..end_date).each do |shipment|
        file << [
          shipment.order.name,
          shipment.order.email,
          shipment.shipped_at.strftime('%Y-%m-%d'),
          shipment.manifest.first.line_item.product.name.strip,
          logon,
          shipment.manifest.first.line_item.product.taxons.order(:lft).first.try(:name).to_s,
          '',
          shipment.manifest.first.line_item.variant.sku,
          shipment.order.number,
          # Rails.application.routes.url_helpers.spree.product_path(shipment.manifest.first.line_item.product),
          logon+"/products/#{ shipment.manifest.first.line_item.product.slug }",  # TODO: Do this properly!
          shipment.order.user ? shipment.order.user.id : '',
          shipment.order.total.to_f
        ] if shipment.present? && shipment.order.email.present?
      end

    end

    FileUtils.cp tmp_filepath, end_filepath
    puts end_filepath
  end
end