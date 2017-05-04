class DisplayController < ApplicationController
  def weather
    # c = Scraper.new
	# c.get_station
	# c.store_datetime
	# c.store_temperature
	# c.store_wind
	# c.store_rainfall
	p = Predictiondata.new
	@probability_t,@probability_r,@probability_ws,@probability_wd = p.predict(1, 10)
  end
end
