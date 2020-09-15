require 'mongo'
require 'csv'

Mongo::Logger.logger.level = Logger::FATAL

class UOA

	attr_accessor :data
	attr_reader	:collection

	def initialize()
		client 		= Mongo::Client.new(ENV["MONGO_URI"])
		@collection = client[:uoa]
		@data 		= []
	end


	def recent_trades
		last_record_date = @collection.find({}).sort({"_id": -1}).first['created_at']
		query = @collection.find({'created_at': { '$gt': last_record_date.beginning_of_day, '$lt': last_record_date.end_of_day } })
		query.each { |r| @data.push(r) }
	end

	def search(params)
		query = {}
		if params[:date].present?
			date_parsed = Date.strptime(params[:date], '%m/%d/%Y')
			condition = { 'created_at': { '$gt': date_parsed.beginning_of_day, '$lt': date_parsed.end_of_day } }
			query.merge!(condition)
		end
		response = @collection.find(query)
		response.each { |r| @data.push(r) }
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