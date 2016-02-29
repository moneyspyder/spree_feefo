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
      end_date = Time.zone.now.beginning_of_day

      tmp_path = "#{ Rails.root }" + Rails.application.config.feefo_tmp_feed_location
      end_path = "#{ Rails.root }" + Rails.application.config.feefo_end_feed_location
      FileUtils.mkdir_p(tmp_path)
      FileUtils.mkdir_p(end_path)
      tmp_filepath = tmp_path + Rails.application.config.feefo_feed_name
      end_filepath = end_path + Rails.application.config.feefo_feed_name


      File.open(tmp_filepath, "w:UTF-8") do |file|
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

        file.close
        FileUtils.cp tmp_filepath, end_filepath

      end
    end
  end
end