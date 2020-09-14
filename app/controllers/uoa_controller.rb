require 'uoa'
require 'csv'

class UoaController < ApplicationController

	def index
		options = UOA.new()

		if uoa_params
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
		params.permit(:date, :commit, :format)
	end
end