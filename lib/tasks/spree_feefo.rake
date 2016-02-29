# encoding: UTF-8

namespace :spree_feefo do
  namespace :feed do
    desc 'generate feefo product feed'
    task generate: :environment do
      Feefo.generate_feed
    end
  end
end