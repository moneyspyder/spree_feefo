# encoding: UTF-8

namespace :spree_feefo do
  namespace :feed do
    desc 'generate feefo product feed'
    task generate: :environment do
      require Rails.root.join('app', 'helpers', 'application_helper')
      include ApplicationHelper
      include Rails.application.routes.url_helpers

      require 'csv_tools'
      include CsvTools

      start_date = Time.zone.now.beginning_of_day - 1.months
      end_date = Time.zone.now.beginning_of_day + 1.day

      path = "#{ Rails.root }" + Rails.application.config.feefo_feed_location
      FileUtils.mkdir_p(path)
      filepath = path + Rails.application.config.feefo_feed_name


      File.open(filepath, "w:UTF-8") do |file|
        file.write("\xEF\xBB\xBF")
        file.puts(
          CsvTools.tab_line(
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
          )
        )

        logon = Rails.application.config.feefo_logon

         Spree::Shipment.where(state: "shipped", shipped_at: start_date..end_date).each do |shipment|
          file.puts(
            CsvTools.tab_line(
              shipment.order.name,
              shipment.order.email,
              shipment.shipped_at.strftime('%Y-%m-%d'),
              shipment.manifest.first.line_item.product.name.strip,
              logon,
              shipment.manifest.first.line_item.product.taxons.order(:lft).first.try(:name).to_s,
              '',
              shipment.manifest.first.line_item.variant.sku,
              shipment.order.number,
              # Rails.application.routes.url_helpers.product_path(shipment.manifest.first.line_item.product),
              logon+"/products/#{ shipment.manifest.first.line_item.product.slug }",  # TODO: Do this properly!
              shipment.order.user ? shipment.order.user.id : '',
              shipment.order.total.to_f
            )
          ) if shipment.present? && shipment.order.email.present?
        end

      end
    end
  end
end