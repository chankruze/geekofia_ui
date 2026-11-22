class KitchenSinkController < ApplicationController
  class Thing
    include ActiveModel::Model
    attr_accessor :name

    def self.model_name = ActiveModel::Name.new(self, nil, "Thing")
  end

  def show
    flash.now[:notice] = "Saved"
    @thing = Thing.new(name: "disk")
  end
end
