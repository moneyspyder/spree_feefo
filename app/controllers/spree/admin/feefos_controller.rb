class Spree::Admin::FeefosController < Spree::Admin::BaseController

  def edit
  end


  def update
    params.each do |name, value|
      next unless Spree::Config.has_preference? name
      Spree::Config[name] = value
    end
    flash[:success] = Spree.t(:successfully_updated, resource: 'feefo settings')
    redirect_to edit_admin_feefo_path
  end

end