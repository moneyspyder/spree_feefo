module Spree
  AppConfiguration.class_eval do
    preference :feefo_logon, :string, default: nil
    preference :feefo_feed_name, :string, default: nil
    preference :feefo_tmp_feed_location, :string, default: nil
    preference :feefo_public_feed_location, :string, default: nil
  end
end