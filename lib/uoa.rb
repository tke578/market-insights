require 'mongo'
require 'csv'
require 'date_parser'


Mongo::Logger.logger.level = Logger::FATAL

class UOA
	include ActiveModel::Validations

	attr_accessor :data, :tickers
	attr_reader	:collection

	def initialize()
		client 		= Mongo::Client.new(ENV['MONGO_URI'])
		@collection = client[:uoa]
		@data 		= []
		@tickers 	= []
	end


	def recent_trades
		last_record_date = @collection.find({}).sort({"_id": -1}).first['created_at']
		query = @collection.find({'created_at': { '$gt': last_record_date.beginning_of_day, '$lt': last_record_date.end_of_day } })
		query.each { |r| @data.push(r) }
	end

	def search(params)
		query = {}

		if params[:date_range].present?
			date_range = DateParser.normalize_beg_end_dates(params[:date_range])
			unless date_range.blank?
				beg_date = Date.strptime(date_range.first, '%m-%d-%Y')
				end_date = Date.strptime(date_range.last, '%m-%d-%Y')
				condition = { 'created_at': { '$gt': beg_date.beginning_of_day, '$lt': end_date.end_of_day } }
				query.merge!(condition)
			end
		end
		if params[:symbol].present?
			condition = { "Symbol": params[:symbol].upcase }
			query.merge!(condition)
		end
		if params[:price_range_begin] != "0" and params[:price_range_end] != "0"
			condition = { 'Price': { '$gt': params[:price_range_begin].to_i, '$lt': params[:price_range_end].to_i } }
			query.merge!(condition)
		end
		if params[:strike_price_range_begin] != "0" and params[:strike_price_range_end] != "0"
			condition = { 'Strike': { '$gt': params[:strike_price_range_begin].to_i, '$lt': params[:strike_price_range_end].to_i } }
			query.merge!(condition)
		end
		if params[:expiration_date].present?
			date_range = DateParser.normalize_beg_end_dates(params[:expiration_date])
			unless date_range.blank?
				beg_date = Date.strptime(date_range.first, '%m-%d-%Y')
				end_date = Date.strptime(date_range.last, '%m-%d-%Y')
				condition = { 'Exp Date': { '$gt': beg_date.beginning_of_day, '$lt': end_date.end_of_day } }
				query.merge!(condition)
			end
		end
		if params[:open_interest_range_begin] != "0" and params[:open_interest_range_end] != "0"
			condition = { 'Open Int': { '$gt': params[:open_interest_range_begin].to_i, '$lt': params[:open_interest_range_end].to_i } }
			query.merge!(condition)
		end
		if params[:implied_volatility_range_begin] != "0" and params[:implied_volatility_range_end] != "0"
			condition = { 'IV': { '$gt': params[:implied_volatility_range_begin].to_i, '$lt': params[:implied_volatility_range_end].to_i } }
			query.merge!(condition)
		end
		if params[:volume_range_begin] != "0" and params[:volume_range_end] != "0"
			condition = { 'Volume': { '$gt': params[:volume_range_begin].to_i, '$lt': params[:volume_range_end].to_i } }
			query.merge!(condition)
		end

		if query.blank?
			recent_trades
		else
			response = @collection.find(query)
			response.each { |r| @data.push(r) }
		end
	end

	def tickers
		response = @collection.distinct("Symbol")
		response.each { |r| @tickers.push(r) }
	end


	def to_csv
		return if @data.blank?
		row_headers = @data.first.keys().select { |key| !['_id', 'created_at', 'updated_at'].include? key }
		CSV.generate(headers: true) do |csv|
			csv << row_headers
			@data.each { |record| csv << record }
    	end
	end

end