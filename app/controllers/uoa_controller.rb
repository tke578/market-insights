require 'uoa'
require 'csv'

class UoaController < ApplicationController

	def index
		options = UOA.new()
		if params[:search].present?
			options.search(uoa_params)
		else
			options.recent_trades
		end
		@collection = options.data
		respond_to  do |format|
			format.html
			format.csv { send_data options.to_csv, filename: "UOA_"+Date.today.strftime("%m%d%Y")+'.csv' }
		end
	end

	private

	def uoa_params
		params.require(:search).permit(:date, :commit)
	end
end