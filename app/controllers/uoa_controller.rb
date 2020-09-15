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
			format.csv {
				if params[:search].present?
					file_name =  params[:search][:date].present? ? Date.strptime(params[:search][:date], '%m/%d/%Y').strftime("%m%d%Y") : Date.today.strftime("%m%d%Y")
				else
					file_name = Date.today.strftime("%m%d%Y")
				end
				file_name = "UOA_"+file_name+'.csv'
				send_data options.to_csv, filename: file_name
			}
		end
	end

	private

	def uoa_params
		params.require(:search).permit(:date, :commit)
	end
end