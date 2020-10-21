require 'mongo'
require 'csv'
require 'date_parser'


Mongo::Logger.logger.level = Logger::FATAL

class UOA
	include ActiveModel::Validations

	attr_accessor :data
	attr_reader	:collection

	def initialize()
		client 		= Mongo::Client.new("mongodb+srv://taz:VATnBl3dvrBKRK20@barchart.ejira.mongodb.net/barchart?retryWrites=true&w=majority")
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
		puts "This is the params"
		puts params
		if params[:date_range].present?
			date_range = DateParser.normalize_beg_end_dates(params[:date_range])
			puts date_range
			unless date_range.blank?
				puts date_range.first
				puts date_range.last
				beg_date = Date.strptime(date_range.first, '%m-%d-%Y')
				end_date = Date.strptime(date_range.last, '%m-%d-%Y')
				condition = { 'created_at': { '$gt': beg_date.beginning_of_day, '$lt': end_date.end_of_day } }
				query.merge!(condition)
			end
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