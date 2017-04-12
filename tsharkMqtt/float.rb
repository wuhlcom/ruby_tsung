class Float
	def roundf(places)
		size = self.to_s.size
		sprintf("%#{size}.#{places}f", self).to_f
	end

	def roundn(nth)
		num           = self*(10**(-nth))
		num_float     = num.round*(10**nth).to_f
		num_float_str = num_float.to_s
		num_float_str =~/\.(\d*)/
		dot_num_size = Regexp.last_match(1).size
		if dot_num_size>nth.abs
			num_float = num_float_str[/\d+\.\d{#{nth.abs}}/]
		end
		return num_float.to_f
	end
end

if __FILE__ == $0
	t = 1625163.4285714286
	t2 = 122219.14285714286
	num=123.4563
	t=0.32711
	p t.roundf(1)
	p t.roundf(2)
	p t.roundn(1)
	p t.roundn(-2)
end