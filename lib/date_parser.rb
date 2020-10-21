module DateParser
	def self.normalize_beg_end_dates(date_string, delimiter='to', date_format='%m-%d-%Y')
		#flatpicker lib 
		dates = []
		date_string.split(delimiter).each do |date|
			begin
				date = date.strip
				Date.strptime(date, date_format)
				dates << date
			rescue ArgumentError
				next
			end
		end
		dates.append(x.first) if dates.size == 1
		return dates
	end
end