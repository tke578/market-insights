require 'uoa'
require 'csv'

class UoaController < ApplicationController

	def index
		options = UOA.new()
		options.recent_trades
		@collection = options.data
		respond_to  do |format|
			format.html
			format.csv { send_data options.to_csv, filename: "UOA_"+Date.today.strftime("%m%d%Y")+'.csv' }
		end
	end
end