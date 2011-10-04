module ApplicationHelper
	def nice_date
		self.strftime("%m/%d/%Y")
	end
	
	def convert_seconds_to_time(seconds)
	   total_minutes = seconds / 1.minutes
	   seconds_in_last_minute = seconds - total_minutes.minutes.seconds
	   "#{total_minutes}:#{seconds_in_last_minute.to_s.rjust(2,'0')}"
	end
end
