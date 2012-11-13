module ArrayExtender
	def avg
		sum = 0.0
		self.each do |i|
			sum += i
		end
		sum / self.size		
	end

	def min
		m = -1
		self.each do |i|
			m = i if m == -1 || m > i
		end
		m
	end

	def max
		m = 0
		self.each do |i|
			m = i if m < i
		end
		m
	end
end
class Array
	include ArrayExtender
end
