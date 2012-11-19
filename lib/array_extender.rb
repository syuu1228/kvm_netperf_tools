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

	def bias
		bias_min = 1 - (min() / avg())
		bias_max = (max() / avg()) - 1
		(bias_min + bias_max) * 100
	end

	def twodim_sum_avg
		sum = 0
		self.each_index do |i|
			sum += self[i].avg
		end
		sum
	end

	def twodim_avg_avg
		self.twodim_sum_avg / self.size
	end

	def twodim_max_avg
		m = 0
		self.each_index do |i|
			m = self[i].avg if m < self[i].avg
		end
		m
	end

	def twodim_min_avg
		m = -1
		self.each_index do |i|
			m = self[i].avg if m  == -1 || m > self[i].avg
		end
		m
	end

	def twodim_bias_avg
		self.twodim_max_avg - self.twodim_min_avg
	end
end
class Array
	include ArrayExtender
end
