module Api
  module V1
    class SettingsController < BaseController
      def index
        @settings = Setting.pluck(:name, :value)
        @settings = Hash[@settings.map { |k, v| [k, v] }]
        render json: @settings, status: :ok, root: 'data'
      end
    end
  end
end
