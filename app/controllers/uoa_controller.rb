require 'uoa'
require 'csv'

class UoaController < ApplicationController

	def index
		options = UOA.new()
		@tickers = options.tickers
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
					file_name =  params[:search][:date_range].present? ? Date.strptime(params[:search][:date], '%m/%d/%Y').strftime("%m%d%Y") : Date.today.strftime("%m%d%Y")
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
		params.require(:search).permit(:date_range, :symbol, :commit, :price_range_begin, :price_range_end, :expiration_date, :type,
										:strike_price_range_begin, :strike_price_range_end, :open_interest_range_begin, :open_interest_range_end,
										:implied_volatility_range_begin, :implied_volatility_range_end, :volume_range_begin, :volume_range_end)
	end
end