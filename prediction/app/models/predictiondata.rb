require 'matrix'
class Predictiondata < ActiveRecord::Base
    belongs_to :predictiondata

def predict(station_id, period)
	time = DateTime.now + period/1440.0
	x_time = time.to_time.to_i
	@x = Array.new
	@y = Array.new
	# temp_x = Array.new
	reading = Array.new
	reading = Readingdata.where(station_id: station_id).ids
	# temp_x = Readingdata.where(station_id: station_id).pluck(:datetime)
	reading.map do |r|
		if Temperature.where(readingdata_id: r).exists?
			if Temperature.find_by(readingdata_id: r).temp == -100
				@y << Temperature.find_by(readingdata_id: r).maxtemp
				@x << Readingdata.find(r).datetime
			end
		end
	end
	@x.map!{|l| l.to_time.to_i}
	calculate(@x, @y)
	max_temp_predict = max_best_fit
	@x.clear
	@y.clear
	reading.map do |r|
		if Wind.where(readingdata_id: r).exists?
			if Wind.find_by(readingdata_id: r).speed == -100
				
				@y << Wind.find_by(readingdata_id: r).maxspeed
				@x << Readingdata.find(r).datetime
			end
		end
	end
	@x.map!{|l| l.to_time.to_i}
	calculate(@x, @y)
	max_windspeed_predic = max_best_fit
	@x.clear
	@y.clear
	reading.map do |r|
		if Wind.where(readingdata_id: r).exists?
			if Wind.find_by(readingdata_id: r).direction == -100
				
				@y << Wind.find_by(readingdata_id: r).maxdirection
				@x << Readingdata.find(r).datetime
			end
		end
	end
	@x.map!{|l| l.to_time.to_i}
	calculate(@x, @y)
	max_winddir_predic = max_best_fit
	@x.clear
	@y.clear
	reading.map do |r|
		if Temperature.where(readingdata_id: r).exists?
			if Temperature.find_by(readingdata_id: r).maxtemp == -100
				@y << Temperature.find_by(readingdata_id: r).temp
				@x << Readingdata.find(r).datetime
			end
		end
	end
	@x.map!{|l| l.to_time.to_i}
	calculate(@x, @y)
	temp_predict_pro,max_temp_b = best_fit(x_time)
	@x.clear
	@y.clear
	reading.map do |r|
		if Rainfallamount.where(readingdata_id: r).exists?
			@y << Rainfallamount.find_by(readingdata_id: r).amount
			@x << Readingdata.find(r).datetime
		end
	end
	@x.map!{|l| l.to_time.to_i}
	calculate(@x, @y)
	rainfall_predict,max_rain_b = best_fit(x_time)
	@x.clear
	@y.clear
	reading.map do |r|
		if Wind.where(readingdata_id: r).exists?
			if Wind.find_by(readingdata_id: r).maxspeed == -100
				@y << Wind.find_by(readingdata_id: r).speed
				@x << Readingdata.find(r).datetime
			end
		end
	end
	@x.map!{|l| l.to_time.to_i}
	calculate(@x, @y)
	windspeed_predic_pro,max_winds_b = best_fit(x_time)
	@x.clear
	@y.clear
	reading.map do |r|
		if Wind.where(readingdata_id: r).exists?
			if Wind.find_by(readingdata_id: r).maxdirection == -100
				@y << Wind.find_by(readingdata_id: r).direction
				@x << Readingdata.find(r).datetime
			end
		end
	end
	@x.map!{|l| l.to_time.to_i}
	calculate(@x, @y)
	winddir_predic_pro,max_windd_b = best_fit(x_time)
	
	#result: max_temp_predict<0, temp_predict_pro=1
	
	temp_p = max_temp_predict*temp_predict_pro
	winds_p = max_windspeed_predic*windspeed_predic_pro
	windd_p = max_winddir_predic*windspeed_predic_pro
	Predictiondata.create(:temp=>temp_p.round(2), :windspeed=>winds_p.round(2), :winddir=>windd_p.round(2), :rainfall=>rainfall_predict.round(2), :datetime=>time, :postcode_id=>station_id)
	probability_t = (max_temp_predict / max_temp_b) <= 1? (max_temp_predict / max_temp_b):(max_temp_b / max_temp_predict)
	probability_r = (rainfall_predict / max_rain_b) <= 1? (rainfall_predict / max_rain_b):(max_rain_b / rainfall_predict)
	probability_ws = (max_windspeed_predic / max_winds_b) <= 1? (max_windspeed_predic / max_winds_b):(max_winds_b / max_windspeed_predic)
	probability_wd = (max_winddir_predic / max_windd_b) <= 1? (max_winddir_predic / max_windd_b):(max_windd_b / max_winddir_predic)
	return probability_t, probability_r, probability_ws, probability_wd
end
def calculate(x, y)
	#@sxx is x1^2 + x2^2 +..+ xn^2; @sx3 is x1^3 + x2^3 +..+ xn^3; @sx4 is x1^4 + x2^4 +..+ xn^4. So does y. 
	#@sx2y is x1^2*y + x2^2*y +..+ xn^2*y
	@n = x.length
	
	@sx = x.reduce(:+)
	@sy = y.reduce(:+)
	@sxx = x.map{|l| l**2}.reduce(:+)
	@sxy = Matrix.row_vector(x)*Matrix.column_vector(y)
	@syy = y.map{|l| l**2}.reduce(:+)
	@sylnx = Matrix.row_vector(y)*Matrix.column_vector(x.map{|l| Math.log(l)})
	@slnx = x.map{|l| Math.log(l)}.reduce(:+)
	@slnx2 = x.map{|l| Math.log(l)**2}.reduce(:+)
	@y_ave = @sy/@n
	@total_var = @y.map{|l| (l - @y_ave)**2}.reduce(:+)
end

# @sxlny = Matrix.row_vector(@x)*Matrix.column_vector(@y.map{|l| Math.log(l)})
# @slny = @y.map{|l| Math.log(l)}.reduce(:+)

def exponential_e
	begin
	@y.map{|l| Math.log(l)}.reduce(:+)
	rescue
	return nil
	end
end

#Linear Regression
#y = b*x + a
def linear
	b = (@n*@sxy.element(0,0) - @sx*@sy)/(@n*@sxx - @sx**2)
	a = (@sy - b*@sx)/@n
	
	y_pre = @x.map{|l| b.round(2)*l+a.round(2)}
	explained_var = y_pre.map{|l| (l - @y_ave)**2}.reduce(:+)
	r2 = explained_var/@total_var
	return b.round(2), a.round(2), r2
end

def r2_fit r2
	fit = r2[0]
	fit_index = 0
	for i in 1..r2.length - 1
		if (r2[i] - 1).abs < (fit - 1).abs
			fit = r2[i]
			fit_index = i
		end
	end
	return fit, fit_index
end

#Polynomial Regression
#y = a0 + a1*x + a2*x^2 +..+ ak*x^k; degree 2 to 10
def poly_regress x, y, degree
	x_degree = x.map{|x_i| (0..degree).map{|l| x_i**l}}
	# Formula of calculate a[k] from https://sph.uth.edu/courses/biometry/Lmoye/PH1820-21/PH1820/lecpoly.htm
	a = (Matrix[*x_degree].transpose*Matrix[*x_degree]).inverse*Matrix[*x_degree].transpose*Matrix.column_vector(y)
	a_round = a.round(2)
	y_pre = Matrix[*x_degree]*Matrix.column_vector(a_round.each().to_a)
	explained_var = y_pre.map{|l| (l - @y_ave)**2}.reduce(:+)
	r2 = explained_var/@total_var
	return a_round, r2
end
def polynomial
	ai = Array.new
	r2 = Array.new
	for i in 1..10
	#get a and r2 of degree 1 to 10
		ai[i-1],r2[i-1] = poly_regress(@x,@y,i)
		# puts ai[i-1].inspect, r2[i-1]
	end
	fit_r2,fit_index = r2_fit(r2)
	fit_degree = fit_index + 1
	a_fit = ai[fit_index].each().to_a
	#part_equ = Array.new
	#for i in 0..fit_degree
		#if a_fit[i].round(2) != 0
			#if i == 0
				#part_equ << "#{a_fit[i].round(2)}"
			#elsif i == 1
				#part_equ << "#{a_fit[i].round(2)}x"
			#else part_equ << "#{a_fit[i].round(2)}x^#{i}"
			#end
		#end
	#end
	#equation = "#{part_equ.reverse!.join(" + ")}"
	return a_fit, fit_r2, fit_degree
end

#Logarithmic Regression
#y = a + b*ln(x)
def logarithmic
	b = (@n*@sylnx.element(0,0) - @sy*@slnx)/(@n*@slnx2 - @slnx**2)
	a = (@sy - b*@slnx)/@n
	y_pre = @x.map{|l| a.round(2)+b.round(2)*Math.log(l)}
	explained_var = y_pre.map{|l| (l - @y_ave)**2}.reduce(:+)
	r2 = explained_var/@total_var
	return b.round(2), a.round(2), r2
end

#Exponential Regression
#y=Ae^(Bx)
def exponential
	if exponential_e.nil?
	puts "Cannot perform exponential regression on this data"
	else
	sxlny = Matrix.row_vector(@x)*Matrix.column_vector(@y.map{|l| Math.log(l)})
	slny = @y.map{|l| Math.log(l)}.reduce(:+)
	a = (slny*@sxx - @sx*sxlny.element(0,0))/(@n*@sxx - @sx**2)
	b = (@n*sxlny.element(0,0) - @sx*slny)/(@n*@sxx - @sx**2)
	end
	if !a.nil? && !b.nil?
		y_pre = @x.map{|l| Math.exp(a.round(2))*(Math.exp(b.round(2))**l)}
		explained_var = y_pre.map{|l| (l - @y_ave)**2}.reduce(:+)
		r2 = explained_var/@total_var
		return Math.exp(a).round(2), b.round(2), r2
	else return nil
	end
end

# def print_equation type
	# if !type.nil?
	# puts type[0]
	# end
# end

def best_fit(time)
	today = Date.today.to_time.to_i
	max_time = [today+46800, today+50400, today+54000]
	r2 = Array.new
	linear_para = Array.new
	log_para = Array.new
	expo_para = Array.new

	
	linear_para[0],linear_para[1],r2[0] = linear
	poly_para,r2[1],fit_degree = polynomial
	log_para[0],log_para[1],r2[2] = logarithmic
	if !exponential_e.nil?
		expo_para[0],expo_para[1],r2[3] = exponential
	end
	fit_r2,fit_index = r2_fit(r2)
	if fit_index == 0
		max_l = 0
		max_time.map do |t|
			if linear_para[0] * t + linear_para[1]>max_l
				max_l = linear_para[0] * t + linear_para[1]
			end
		end
		time_period = linear_para[0] * time + linear_para[1]
		return time_period/max_l, max_l
		#return max_l
	elsif fit_index == 1
		part_equ = Array.new
		max_p = 0
		max_time.map do |t|
			for i in 0..fit_degree
				if poly_para[i].round(2) != 0
					if i == 0
						part_equ << poly_para[i].round(2)
					elsif i == 1
						part_equ << poly_para[i].round(2)*t
					else part_equ << poly_para[i].round(2)*(t**fit_degree)
					end
				end
			end
			if part_equ.inject(:+) > max_p
				max_p = part_equ.inject(:+)
			end
		end
		for i in 0..fit_degree
			if poly_para[i].round(2) != 0
				if i == 0
					part_equ << poly_para[i].round(2)
				elsif i == 1
					part_equ << poly_para[i].round(2)*time
				else part_equ << poly_para[i].round(2)*(time**fit_degree)
				end
			end
		end
		time_period = part_equ.inject(:+)
		return time_period/max_p, max_p
		#return max_p
	elsif fit_index == 2
		max_log = 0
		max_time.map do |t|
			if log_para[1] + log_para[0]*Math.log(t)>max_log
				max_log = log_para[1] + log_para[0]*Math.log(t)
			end
		end
		time_period = max_log = log_para[1] + log_para[0]*Math.log(time)
		return time_period/max_log, max_log
		#return max_l
	elsif fit_index == 3
		max_e = 0
		max_time.map do |t|
			if expo_para[0]*Math.exp(expo_para[1]*t)>max_e
				max_e = expo_para[0]*Math.exp(expo_para[1]*t)
			end
		end
		time_period = expo_para[0]*Math.exp(expo_para[1]*time)
		return time_period/max_e, max_e
		#return max_e
	end
	#return equation[fit_index]
end
def max_best_fit
	today = Date.today.to_time.to_i
	r2 = Array.new
	linear_para = Array.new
	log_para = Array.new
	expo_para = Array.new

	
	linear_para[0],linear_para[1],r2[0] = linear
	poly_para,r2[1],fit_degree = polynomial
	log_para[0],log_para[1],r2[2] = logarithmic
	if !exponential_e.nil?
		expo_para[0],expo_para[1],r2[3] = exponential
	end
	fit_r2,fit_index = r2_fit(r2)
	if fit_index == 0
		return linear_para[0] * today + linear_para[1]
	elsif fit_index == 1
		part_equ = Array.new
		for i in 0..fit_degree
			if poly_para[i].round(2) != 0
				if i == 0
					part_equ << poly_para[i].round(2)
				elsif i == 1
					part_equ << poly_para[i].round(2)*today
				else part_equ << poly_para[i].round(2)*(today**fit_degree)
				end
			end
		end
		return part_equ.inject(:+)
	elsif fit_index == 2
		return log_para[1] + log_para[0]*Math.log(today)
	elsif fit_index == 3
		return expo_para[0]*Math.exp(expo_para[1]*today)
	end
end
	
	
end
