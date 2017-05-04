class Scraper < ActiveRecord::Base
require 'nokogiri'
require 'open-uri'
require 'json'
URL = 'http://www.bom.gov.au/vic/observations/vicall.shtml'
KEY_URL = 'http://www.bom.gov.au'
BASE_URL = 'https://api.forecast.io/forecast'
API_KEY = 'a658ee7536eb1134bc14b1baec64061c'
def get_station
@location_lat=[]
@location_lon=[]
@locationname=[]
@station_latlon=[]
@station_id_array=[]
            #find link that includes "/products/IDV60801/IDV60801."
           doc = Nokogiri::HTML(open(URL))
		   addlinks = doc.css("a").select{|k| k['href'].include? "/products/IDV60801/IDV60801."}
           datalinks=[]
		  
		   latlon=[]
		   addlinks.each do |link|
           datalinks.push KEY_URL + "/" + link['href']
           end
		   
		   datalinks.each do |link|
	 #go to the link of location
      doclink = Nokogiri::HTML(open(link))
	  location_lat_lon = doclink.css('table[class="stationdetails"]')
	  lat= location_lat_lon.css('td[4]').text
	  lon = location_lat_lon.css('td[5]').text
	  @location_lat.push(lat.gsub!("Lat:",""))
	  @location_lon.push(lon.gsub!("Lon:",""))
      end 
	# store the location into array
	  doc.css("#tMAL").each do |a|
       dataStation = a.css("tr")
       dataStation.each do |b|
	     tempname = b.css("a").text
	     if(tempname!="")
		     @locationname<<tempname
		 end
		 end
	 end
	   doc.css("#tWIM").each do |a|
       dataStation = a.css("tr")
       dataStation.each do |b|
	     tempname = b.css("a").text
	     if(tempname!="")
		     @locationname<<tempname
		 end
		 end
	 end
	 doc.css("#tSW").each do |a|
       dataStation = a.css("tr")
       dataStation.each do |b|
	     tempname = b.css("a").text
	     if(tempname!="")
		     @locationname<<tempname
		 end
		 end
	 end
	  doc.css("#tCEN").each do |a|
       dataStation = a.css("tr")
       dataStation.each do |b|
	     tempname = b.css("a").text
	     if(tempname!="")
		     @locationname<<tempname
		 end
		 end
	 end
	   doc.css("#tNCY").each do |a|
       dataStation = a.css("tr")
       dataStation.each do |b|
	     tempname = b.css("a").text
	     if(tempname!="")
		     @locationname<<tempname
		 end
		 end
	 end
	 doc.css("#tNE").each do |a|
       dataStation = a.css("tr")
       dataStation.each do |b|
	     tempname = b.css("a").text
	     if(tempname!="")
		     @locationname<<tempname
		 end
		 end
	 end
	 doc.css("#tNC").each do |a|
       dataStation = a.css("tr")
       dataStation.each do |b|
	     tempname = b.css("a").text
	     if(tempname!="")
		     @locationname<<tempname
		 end
		 end
	 end
	  doc.css("#tWSG").each do |a|
       dataStation = a.css("tr")
       dataStation.each do |b|
	     tempname = b.css("a").text
	     if(tempname!="")
		     @locationname<<tempname
		 end
		 end
	 end
	   doc.css("#tEG").each do |a|
       dataStation = a.css("tr")
       dataStation.each do |b|
	     tempname = b.css("a").text
	     if(tempname!="")
		     @locationname<<tempname
		 end
		 end
	 end
	   doc.css("#tMOB").each do |a|
       dataStation = a.css("tr")
       dataStation.each do |b|
	     tempname = b.css("a").text
	     if(tempname!="")
		     @locationname<<tempname
		 end
		 end
	 end
	 
     count1 = Station.count
	 if count1==0 
    for i in 0..@locationname.length-1
	     @station=@locationname[i]
		 @station_lat=@location_lat[i]
		 @station_lon = @location_lon[i]
		 Station.create(:name=>"#{@station}", :lat=>"#{@station_lat}", :lon=>"#{@station_lon}")
		 end	
	else
	    stations = Station.all
		for i in 0..stations.length-1
		   if  @locationname.include? stations[i].name
                 @station_id_array.push stations[i].id
		   end		   
		end
		s_name = []
		for i in 0..stations.length-1
		   s_name.push stations[i].name
		end
		
		for i in 0..@locationname.length-1
		   if s_name.include? @locationname[i]==false
		       Station.create(:name=>"#{@locationname[i]}", :lat=>"#{@location_lat[i]}", :lon=>"#{@location_lon[i]}")
			   stations = Station.all
			   @station_id_array.push stations[-1].id
           end		   
		end
	end       	 
end
def convert_direction_to_degree dir
         if dir=="N"
		     return 348.75
		 elsif dir=="NNE"
		     return 11.25
		 elsif dir=="NE"
		     return 33.75
		 elsif dir=="ENE"
		     return 56.25
		 elsif dir=="E"
		     return 78.75
		 elsif dir=="ESE"
		     return 101.25
		 elsif dir=="SE"
		     return 123.75
		 elsif dir=="SSE"
		     return 146.25
		 elsif dir=="S"
		     return 168.75
		 elsif dir=="SSW"
		     return 191.25
		 elsif dir=="SW"
		     return 213.75
		 elsif dir=="WSW"
		     return 236.25
		 elsif dir=="W"
		     return 258.75
		 elsif dir=="WNW"
		     return 281.25
		 elsif dir=="NW"
		     return 303.75
		 elsif dir=="NNW"
		     return 326.25
		 else
		     return 0.0
		 end
		 
end
def get_past_weeks 
           doc = Nokogiri::HTML(open(URL))
		   addlinks = doc.css("a").select{|k| k['href'].include? "/products/IDV60801/IDV60801."}
           datalinks=[]	  
		   latlon=[]
		   addlinks.each do |link|
           datalinks.push KEY_URL + "/" + link['href']
           end
                 @date=[]
			     date_time=[]
			     @climate_link_address=[]
             
		         doclink = Nokogiri::HTML(open(datalinks[0]))				
				   climate_link=doclink.css("a").select{|h| h['href'].include? "/climate/dwo/"}				  
                   @climate_link_address.push KEY_URL + "/" + climate_link[0]['href']		   			     
                      climate = Nokogiri::HTML(open(@climate_link_address[0]))
                      climate_tr = climate.css('tr')
                      
                      for i in 0..climate_tr.length-1
					     @date.push climate_tr[i].css('th[class="rb"]').text 
                      end	 
					  @date.delete("")
		             for i in 1..@date.length-1
					     current = DateTime.now
					     date_time.push current-i
					 end
					  return date_time 					 				
end
#refresh per 24 hours
def refresh_date
    doc = Nokogiri::HTML(open(URL))
		   addlinks = doc.css("a").select{|k| k['href'].include? "/products/IDV60801/IDV60801."}
           datalinks=[]	  
		   latlon=[]
		   
		   addlinks.each do |link|
           datalinks.push KEY_URL + "/" + link['href']
           end
			@climate_link_address=[]
			max_date = []
			max_date_fresh = []
          for i in 0..datalinks.length-1
		           doclink = Nokogiri::HTML(open(datalinks[i]))				
				   climate_link=doclink.css("a").select{|h| h['href'].include? "/climate/dwo/"}				  
                   @climate_link_address.push(KEY_URL + "/" + climate_link[0]['href'])		   			   
		   end 		    
 	                  for i in 0..@climate_link_address.length-1                  
					  if @climate_link_address[i].size==58
					  climate = Nokogiri::HTML(open(@climate_link_address[i]))
                      climate_tr = climate.css('tr')     
					   if climate_tr[climate_tr.length-7].css('th').to_s.include? "&"
					     max_date.push max_date[max_date.length-1]   
					   else
					     max_date.push climate_tr[climate_tr.length-7].css('th').text
					   end   
                      else 									    
					    max_date.push max_date[max_date.length-1]				                     				  
                      end
                    end
				
			      for i in 0..max_date.length-1
				     max_date_fresh.push DateTime.parse(max_date[0])
				  end
				  return max_date_fresh
end

def store_datetime
           @current_datetime=[]
           doc = Nokogiri::HTML(open(URL))
		   addlinks = doc.css("a").select{|k| k['href'].include? "/products/IDV60801/IDV60801."}
           datalinks=[]	  
		   latlon=[]
		   addlinks.each do |link|
           datalinks.push KEY_URL + "/" + link['href']
           end
	    stations = Station.all
		count = Readingdata.count
		if count==0
     for i in 0..datalinks.length-1
	  @date_time=[]
      doclink = Nokogiri::HTML(open(datalinks[i]))	
	  @station_id = stations[i].id
	  for i in 1..3
	  datetime = doclink.css("td"+"[headers="+"t#{i}"+"-datetime"+"]").text
	  datearray = datetime.split("m")
	  for i in 0..datearray.length-1
	     datearray[i]=datearray[i]+"m"
		 @datetime=DateTime.parse(datearray[i])
		 Readingdata.create(:datetime=>"#{@datetime}", :station_id=>"#{@station_id}") 
	  end
	   
	  end	
                 			
     end          
	               for i in 0..datalinks.length-1
				    @station_id = stations[i].id
	                @date_time=get_past_weeks.reverse
                    for j in 0..@date_time.length-1
					Readingdata.create(:datetime=>"#{@date_time[j]}", :station_id=>"#{@station_id}") 
                    end
                    end					
         else
		  doc.css("#tMAL").each do |a| 
		  dataStation = a.css("tr")			  
              dataStation.each do |b|
	          datetimeTemp = b.css("td").select{|h| h['headers'].include? "tMAL-datetime tMAL-station-"}
		      datetimeTemp.each do |t|
		      @current_datetime.push t.text   
		    end	      
		    end
		  end
		    doc.css("#tWIM").each do |a| 
		  dataStation = a.css("tr")			  
              dataStation.each do |b|
	          datetimeTemp = b.css("td").select{|h| h['headers'].include? "tWIM-datetime tWIM-station-"}
		      datetimeTemp.each do |t|
		      @current_datetime.push t.text   
		    end	      
		    end
		  end
		    doc.css("#tSW").each do |a| 
		  dataStation = a.css("tr")			  
              dataStation.each do |b|
	          datetimeTemp = b.css("td").select{|h| h['headers'].include? "tSW-datetime tSW-station-"}
		      datetimeTemp.each do |t|
		      @current_datetime.push t.text   
		    end	      
		    end
		  end
		     doc.css("#tCEN").each do |a| 
		  dataStation = a.css("tr")			  
              dataStation.each do |b|
	          datetimeTemp = b.css("td").select{|h| h['headers'].include? "tCEN-datetime tCEN-station-"}
		      datetimeTemp.each do |t|
		      @current_datetime.push t.text   
		    end	      
		    end
		  end
		      doc.css("#tNCY").each do |a| 
		  dataStation = a.css("tr")			  
              dataStation.each do |b|
	          datetimeTemp = b.css("td").select{|h| h['headers'].include? "tNCY-datetime tNCY-station-"}
		      datetimeTemp.each do |t|
		      @current_datetime.push t.text   
		    end	      
		    end
		  end
		        doc.css("#tNE").each do |a| 
		  dataStation = a.css("tr")			  
              dataStation.each do |b|
	          datetimeTemp = b.css("td").select{|h| h['headers'].include? "tNE-datetime tNE-station-"}
		      datetimeTemp.each do |t|
		      @current_datetime.push t.text   
		    end	      
		    end
		  end
		         doc.css("#tNC").each do |a| 
		  dataStation = a.css("tr")			  
              dataStation.each do |b|
	          datetimeTemp = b.css("td").select{|h| h['headers'].include? "tNC-datetime tNC-station-"}
		      datetimeTemp.each do |t|
		      @current_datetime.push t.text   
		    end	      
		    end
		  end
		        doc.css("#tWSG").each do |a| 
		  dataStation = a.css("tr")			  
              dataStation.each do |b|
	          datetimeTemp = b.css("td").select{|h| h['headers'].include? "tWSG-datetime tWSG-station-"}
		      datetimeTemp.each do |t|
		      @current_datetime.push t.text   
		    end	      
		    end
		  end
		       doc.css("#tEG").each do |a| 
		  dataStation = a.css("tr")			  
              dataStation.each do |b|
	          datetimeTemp = b.css("td").select{|h| h['headers'].include? "tEG-datetime tEG-station-"}
		      datetimeTemp.each do |t|
		      @current_datetime.push t.text   
		    end	      
		    end
		  end
		      doc.css("#tMOB").each do |a| 
		  dataStation = a.css("tr")			  
              dataStation.each do |b|
	          datetimeTemp = b.css("td").select{|h| h['headers'].include? "tMOB-datetime tMOB-station-"}
		      datetimeTemp.each do |t|
		      @current_datetime.push t.text   
		    end	      
		    end
		  end
		  for i in 0..@current_datetime.length-1		     
		     Readingdata.create(:datetime=>"#{@current_datetime[i]}", :station_id=>"#{@station_id_array[i]}")
		  end
		  current=DateTime.now
		  
           if current.hour-12==0 && current.minute-10<0
		     @d=[]
             @d = refresh_date
		     for i in 0..@d.length-1
		     Readingdata.create(:datetime=>"#{@d[i]}", :station_id=>"#{station_id_array[i].id}")
		     end		  
           end
         end		 
end
#refresh per 24 hours
def refresh_max_temperature
             doc = Nokogiri::HTML(open(URL))
		   addlinks = doc.css("a").select{|k| k['href'].include? "/products/IDV60801/IDV60801."}
           datalinks=[]	  
		   latlon=[]
		   
		   addlinks.each do |link|
           datalinks.push KEY_URL + "/" + link['href']
           end
			@climate_link_address=[]
			max_temp = []
          for i in 0..datalinks.length-1
		           doclink = Nokogiri::HTML(open(datalinks[i]))				
				   climate_link=doclink.css("a").select{|h| h['href'].include? "/climate/dwo/"}				  
                   @climate_link_address.push(KEY_URL + "/" + climate_link[0]['href'])		   			   
		   end 		    
 	                  for i in 0..@climate_link_address.length-1                  
					  if @climate_link_address[i].size==58
					  climate = Nokogiri::HTML(open(@climate_link_address[i]))
                      climate_tr = climate.css('tr')     
					   if climate_tr[climate_tr.length-7].css('td[4]').to_s.include? "&"
					     max_temp.push max_temp[max_temp.length-1]   
					   else
					     max_temp.push climate_tr[climate_tr.length-7].css('td[4]').text
					   end   
                      else 									    
					    max_temp.push max_temp[max_temp.length-1]				                     				  
                      end
                    end
end
def get_max_temp_for_month
        doc = Nokogiri::HTML(open(URL))
		   addlinks = doc.css("a").select{|k| k['href'].include? "/products/IDV60801/IDV60801."}
           datalinks=[]	  
		   latlon=[]
		   max_temp=[]
		   addlinks.each do |link|
           datalinks.push KEY_URL + "/" + link['href']
           end
			@climate_link_address=[]
			
          for i in 0..datalinks.length-1
		           doclink = Nokogiri::HTML(open(datalinks[i]))				
				   climate_link=doclink.css("a").select{|h| h['href'].include? "/climate/dwo/"}				  
                   @climate_link_address.push(KEY_URL + "/" + climate_link[0]['href'])		   			   
		   end 		    
                     
		
					 # end
 	                  for i in 0..@climate_link_address.length-1
                      
					  if @climate_link_address[i].size==58
					  climate = Nokogiri::HTML(open(@climate_link_address[i]))
                      climate_tr = climate.css('tr')       
                       for j in 3..climate_tr.length-7  
                      if climate_tr[j].css('td[4]').to_s.include? "&"
					     max_temp.push max_temp[max_temp.length-1]   
					   else
					     max_temp.push climate_tr[j].css('td[4]').text
					   end
					   end
                      else 
					  for k in 1..climate_tr.length-9
					      max_temp.push max_temp[max_temp.length-(climate_tr.length-9)]
                      end					  
                      end
                      end			
					  return max_temp
end 
def store_temperature
          doc = Nokogiri::HTML(open(URL))
		   addlinks = doc.css("a").select{|k| k['href'].include? "/products/IDV60801/IDV60801."}
           datalinks=[]	  
		   latlon=[]
		   addlinks.each do |link|
           datalinks.push KEY_URL + "/" + link['href']
           end
		    readingdatas = Readingdata.all
			@temperature=[]
			@last_few_weeks_temp=[]
			count = Temperature.count
			if count==0
		   for i in 0..datalinks.length-1
		         doclink = Nokogiri::HTML(open(datalinks[i]))
				 #@readingdata_id = readingdatas[i].readingdata_id
				 #thetemp = doclink.css('td[headers="t1-temp"]').text			
				 if true#thetemp[1]!="-"
				   for i in 1..3
				    temp = doclink.css("td"+"[headers="+"t#{i}"+"-temp"+"]")
					  temp.each do |t|
					     @temperature.push(t.text)
					  end
					end
				   end
				   climate_link=doclink.css("a").select{|h| h['href'].include? "/climate/dwo/"}
				   climate_link_address=[]
			       climate_link.each do |link|
                   climate_link_address.push KEY_URL + "/" + link['href']
				   end
				   climate_doc = Nokogiri::HTML(open(climate_link_address[0])) 
				   
		   end
		         @last_few_weeks_temp=get_max_temp_for_month
		    for i in 0..(readingdatas.length-@last_few_weeks_temp.length-1)
				      Temperature.create(:temp=>"#{@temperature[i]}",:maxtemp=>"#{-100}", :readingdata_id=>"#{readingdatas[i].id}")				  
		    end
			          @number=0
			for i in (readingdatas.length-@last_few_weeks_temp.length)..readingdatas.length-1			          
			          Temperature.create(:temp=>"#{-100}",:maxtemp=>"#{@last_few_weeks_temp[@number]}", :readingdata_id=>"#{readingdatas[i].id}")	
					  @number=@number+1
			end			
			else
			    @temperature=[]
			   doc.css("#tMAL").each do |a| 
		  dataStation = a.css("tr")			  
              dataStation.each do |b|
	          tmp = b.css("td").select{|h| h['headers'].include? "tMAL-tmp tMAL-station-"}
		      tmp.each do |t|
		      @temperature.push t.text   
		    end	      
		    end
		  end
		    doc.css("#tWIM").each do |a| 
		  dataStation = a.css("tr")			  
              dataStation.each do |b|
	          tmp = b.css("td").select{|h| h['headers'].include? "tWIM-tmp tWIM-station-"}
		      tmp.each do |t|
		      @temperature.push t.text   
		    end	      
		    end
		  end
		    doc.css("#tSW").each do |a| 
		  dataStation = a.css("tr")			  
              dataStation.each do |b|
	          tmp = b.css("td").select{|h| h['headers'].include? "tSW-tmp tSW-station-"}
		      tmp.each do |t|
		      @temperature.push t.text   
		    end	      
		    end
		  end
		     doc.css("#tCEN").each do |a| 
		  dataStation = a.css("tr")			  
              dataStation.each do |b|
	          tmp = b.css("td").select{|h| h['headers'].include? "tCEN-tmp tCEN-station-"}
		      tmp.each do |t|
		      @temperature.push t.text   
		    end	      
		    end
		  end
		      doc.css("#tNCY").each do |a| 
		  dataStation = a.css("tr")			  
              dataStation.each do |b|
	          tmp = b.css("td").select{|h| h['headers'].include? "tNCY-tmp tNCY-station-"}
		      tmp.each do |t|
		      @temperature.push t.text   
		    end	      
		    end
		  end
		        doc.css("#tNE").each do |a| 
		  dataStation = a.css("tr")			  
              dataStation.each do |b|
	          tmp = b.css("td").select{|h| h['headers'].include? "tNE-tmp tNE-station-"}
		      tmp.each do |t|
		      @temperature.push t.text   
		    end	      
		    end
		  end
		         doc.css("#tNC").each do |a| 
		  dataStation = a.css("tr")			  
              dataStation.each do |b|
	          tmp = b.css("td").select{|h| h['headers'].include? "tNC-tmp tNC-station-"}
		      tmp.each do |t|
		      @temperature.push t.text   
		    end	      
		    end
		  end
		        doc.css("#tWSG").each do |a| 
		  dataStation = a.css("tr")			  
              dataStation.each do |b|
	          tmp = b.css("td").select{|h| h['headers'].include? "tWSG-tmp tWSG-station-"}
		      tmp.each do |t|
		      @temperature.push t.text   
		    end	      
		    end
		  end
		       doc.css("#tEG").each do |a| 
		  dataStation = a.css("tr")			  
              dataStation.each do |b|
	          tmp = b.css("td").select{|h| h['headers'].include? "tEG-tmp tEG-station-"}
		      tmp.each do |t|
		      @temperature.push t.text   
		    end	      
		    end
		  end
		      doc.css("#tMOB").each do |a| 
		  dataStation = a.css("tr")			  
              dataStation.each do |b|
	          tmp = b.css("td").select{|h| h['headers'].include? "tMOB-tmp tMOB-station-"}
		      tmp.each do |t|
		      @temperature.push t.text   
		    end	      
		    end
		  end
				 count = Readingdata.count
				 for i in 0..@temperature.length-1
				     Temperature.create(:temp=>"#{@temperature[i]}",:maxtemp=>"#{-100}",:readingdata_id=>"#{count-@temperature.length+i+1}")
				 end
		
		    current=DateTime.now
			
                   if current.hour-14==0 && current.minute-10<0
				       @t=[]
                       @t = refresh_max_temperature
					   count = Readingdata.count
					   for i in 0..@t.length-1
					     Temperature.create(:temp=>"#{-100}", :maxtemp=>"#{@t[i]}", :readingdata_id=>"#{count-@t.length+i+1}")			   
					   end
                   end
			end
end

def get_max_wind_direction
    doc = Nokogiri::HTML(open(URL))
		   addlinks = doc.css("a").select{|k| k['href'].include? "/products/IDV60801/IDV60801."}
           datalinks=[]	  
		   latlon=[]
		   
		   addlinks.each do |link|
           datalinks.push KEY_URL + "/" + link['href']
           end
			@climate_link_address=[]
			max_dir=[]
			max_dir_to_degree=[]
          for i in 0..datalinks.length-1
		           doclink = Nokogiri::HTML(open(datalinks[i]))				
				   climate_link=doclink.css("a").select{|h| h['href'].include? "/climate/dwo/"}				  
                   @climate_link_address.push(KEY_URL + "/" + climate_link[0]['href'])		   			   
		   end 		    
 	                  for i in 0..@climate_link_address.length-1                  
					  if @climate_link_address[i].size==58
					  climate = Nokogiri::HTML(open(@climate_link_address[i]))
                      climate_tr = climate.css('tr')        					  
                      for j in 3..climate_tr.length-7
					   if climate_tr[j].css('td[8]').to_s.include? "&"
					     max_dir.push max_dir[max_dir.length-1]   
					   else
					     max_dir.push climate_tr[j].css('td[8]').text
					   end
                      end
                      else 
					  for k in 1..climate_tr.length-9					    
					    max_dir.push max_dir[max_dir.length-(climate_tr.length-9)]				   
                      end					  
                      end
                    end
                      for i in 0..max_dir.length-1					
					   max_dir_to_degree[i]=convert_direction_to_degree(max_dir[i])
					  end
					  return max_dir_to_degree
end
def get_max_wind_speed
    doc = Nokogiri::HTML(open(URL))
		   addlinks = doc.css("a").select{|k| k['href'].include? "/products/IDV60801/IDV60801."}
           datalinks=[]	  
		   latlon=[]
		   
		   addlinks.each do |link|
           datalinks.push KEY_URL + "/" + link['href']
           end
			@climate_link_address=[]
			max_speed=[]
          for i in 0..datalinks.length-1
		           doclink = Nokogiri::HTML(open(datalinks[i]))				
				   climate_link=doclink.css("a").select{|h| h['href'].include? "/climate/dwo/"}				  
                   @climate_link_address.push(KEY_URL + "/" + climate_link[0]['href'])		   			   
		   end 		    
 	                  for i in 0..@climate_link_address.length-1                  
					  if @climate_link_address[i].size==58
					  climate = Nokogiri::HTML(open(@climate_link_address[i]))
                      climate_tr = climate.css('tr')        					  
                      for j in 3..climate_tr.length-7
					   if climate_tr[j].css('td[9]').to_s.include? "&"
					     max_speed.push max_speed[max_speed.length-1]   
					   else
					     max_speed.push climate_tr[j].css('td[9]').text
					   end
                      end
                      else 
					  for k in 1..climate_tr.length-9					    
					    max_speed.push max_speed[max_speed.length-(climate_tr.length-9)]				   
                      end					  
                      end
                    end
					return max_speed
end
#refresh per 24 hours
def refresh_max_speed
      doc = Nokogiri::HTML(open(URL))
		   addlinks = doc.css("a").select{|k| k['href'].include? "/products/IDV60801/IDV60801."}
           datalinks=[]	  
		   latlon=[]
		   
		   addlinks.each do |link|
           datalinks.push KEY_URL + "/" + link['href']
           end
			@climate_link_address=[]
			max_speed=[]
          for i in 0..datalinks.length-1
		           doclink = Nokogiri::HTML(open(datalinks[i]))				
				   climate_link=doclink.css("a").select{|h| h['href'].include? "/climate/dwo/"}				  
                   @climate_link_address.push(KEY_URL + "/" + climate_link[0]['href'])		   			   
		   end 		    
 	                  for i in 0..@climate_link_address.length-1                  
					  if @climate_link_address[i].size==58
					  climate = Nokogiri::HTML(open(@climate_link_address[i]))
                      climate_tr = climate.css('tr')     
					   if climate_tr[climate_tr.length-7].css('td[9]').to_s.include? "&"
					     max_speed.push max_speed[max_speed.length-1]   
					   else
					     max_speed.push climate_tr[climate_tr.length-7].css('td[9]').text
					   end   
                      else 									    
					    max_speed.push max_speed[max_speed.length-1]				                     				  
                      end
                    end
					return max_speed
end
#refresh per 24 hours
def refresh_max_dir
  doc = Nokogiri::HTML(open(URL))
		   addlinks = doc.css("a").select{|k| k['href'].include? "/products/IDV60801/IDV60801."}
           datalinks=[]	  
		   latlon=[]
		   
		   addlinks.each do |link|
           datalinks.push KEY_URL + "/" + link['href']
           end
			@climate_link_address=[]
			max_speed_dir=[]
			max_speed_dir_to_degree=[]
          for i in 0..datalinks.length-1
		           doclink = Nokogiri::HTML(open(datalinks[i]))				
				   climate_link=doclink.css("a").select{|h| h['href'].include? "/climate/dwo/"}				  
                   @climate_link_address.push(KEY_URL + "/" + climate_link[0]['href'])		   			   
		   end 		    
 	                  for i in 0..@climate_link_address.length-1                  
					  if @climate_link_address[i].size==58
					  climate = Nokogiri::HTML(open(@climate_link_address[i]))
                      climate_tr = climate.css('tr')     
					   if climate_tr[climate_tr.length-7].css('td[8]').to_s.include? "&"
					     max_speed_dir.push max_speed_dir[max_speed_dir.length-1]   
					   else
					     max_speed_dir.push climate_tr[climate_tr.length-7].css('td[8]').text
					   end   
                      else 									    
					    max_speed_dir.push max_speed_dir[max_speed_dir.length-1]				                     				  
                      end
                    end
					for i in 0..max_speed_dir.length-1
					max_speed_dir_to_degree.push convert_direction_to_degree(max_speed_dir[i])
					end 
					return max_speed_dir_to_degree
end
def store_wind
           doc = Nokogiri::HTML(open(URL))		   
		   addlinks = doc.css("a").select{|k| k['href'].include? "/products/IDV60801/IDV60801."}
           datalinks=[]	  
		   latlon=[]
		   addlinks.each do |link|
           datalinks.push KEY_URL + "/" + link['href']
           end
		   readingdatas = Readingdata.all
		   @wind_direction=[]
		   @wind_speed=[]
		   count = Wind.count
		   if count==0
		    for i in 0..datalinks.length-1
		         doclink = Nokogiri::HTML(open(datalinks[i]))
				     #@readingdata_id = readingdatas[i].readingdata_id
				     # wind_direction = doclink.css("td"+"[headers="+"t#{i}"+"-wind"+"t#{i}-wind-dir"+"]")
					  wind_direction=doclink.css('td[headers="t1-wind t1-wind-dir"]')
					  wind_direction.each do |wd|					 
					     @wind_direction.push(convert_direction_to_degree(wd.text))						
					  end
					  wind_direction=doclink.css('td[headers="t2-wind t2-wind-dir"]')
					  wind_direction.each do |wd|					 
					     @wind_direction.push(convert_direction_to_degree(wd.text))						
					  end
					  wind_direction=doclink.css('td[headers="t3-wind t3-wind-dir"]')
					  wind_direction.each do |wd|					 
					     @wind_direction.push(convert_direction_to_degree(wd.text))						
					  end
					  
					  wind_speed=doclink.css('td[headers="t1-wind t1-wind-gust-kmh"]')
					  wind_speed.each do |ws|					 
					     @wind_speed.push(ws.text)						
					  end
					  wind_speed=doclink.css('td[headers="t2-wind t2-wind-gust-kmh"]')
					  wind_speed.each do |ws|					 
					     @wind_speed.push(ws.text)						
					  end
					  wind_speed=doclink.css('td[headers="t3-wind t3-wind-gust-kmh"]')
					  wind_speed.each do |ws|					 
					     @wind_speed.push(ws.text)						
					  end
			end
			             @last_few_wind_dir=get_max_wind_direction
						 @last_few_wind_speed=get_max_wind_speed
			 for i in 0..(readingdatas.length-@last_few_wind_dir.length-1)
			    Wind.create(:speed=>"#{@wind_speed[i]}",:direction=>"#{@wind_direction[i]}",:maxspeed=>"#{-100}",:maxdirection=>"#{-100}",:readingdata_id=>"#{readingdatas[i].id}")
			 end
			 	          @number=0
			for i in (readingdatas.length-@last_few_wind_speed.length)..(readingdatas.length-1)			          
			          Wind.create(:speed=>"#{-100}", :maxspeed=>"#{@last_few_wind_speed[@number]}", :direction=>"#{-100}", :maxdirection=>"#{@last_few_wind_dir[@number]}", :readingdata_id=>"#{readingdatas[i].id}")	
					  @number=@number+1
			end	
			 else
			    count = Readingdata.count
			   @wind_direction=[]
				@wind_speed=[]
				@Wind_maxdirection=[]
				@wind_maxspeed=[]
			   doc = Nokogiri::HTML(open(URL))
			      doc.css("#tMAL").each do |a| 
                  dataStation = a.css("tr")			  
                  dataStation.each do |b|
	              windspeedTemp =  b.css("td").select{|h| h['headers'].include? "tMAL-wind tMAL-wind-gust-kmh tMAL-station-"}
				  winddirectionTemp = b.css("td").select{|h| h['headers'].include? "tMAL-wind tMAL-wind-dir tMAL-station-"}
		           windspeedTemp.each do |t|
		           @wind_speed.push t.text
		           end 
				   winddirectionTemp.each do |wd|
		           @wind_direction.push(convert_direction_to_degree(wd.text))
		           end
				  end
				  end
				      doc.css("#tWIM").each do |a| 
                  dataStation = a.css("tr")			  
                  dataStation.each do |b|
	              windspeedTemp =  b.css("td").select{|h| h['headers'].include? "tWIM-wind tWIM-wind-gust-kmh tWIM-station-"}
				  winddirectionTemp = b.css("td").select{|h| h['headers'].include? "tWIM-wind tWIM-wind-dir tWIM-station-"}
		           windspeedTemp.each do |t|
		           @wind_speed.push t.text
		           end 
				   winddirectionTemp.each do |wd|
		           @wind_direction.push(convert_direction_to_degree(wd.text))
		           end
				  end
				  end
				      doc.css("#tSW").each do |a| 
                  dataStation = a.css("tr")			  
                  dataStation.each do |b|
	              windspeedTemp =  b.css("td").select{|h| h['headers'].include? "tSW-wind tSW-wind-gust-kmh tSW-station-"}
				  winddirectionTemp = b.css("td").select{|h| h['headers'].include? "tSW-wind tSW-wind-dir tSW-station-"}
		           windspeedTemp.each do |t|
		           @wind_speed.push t.text
		           end 
				   winddirectionTemp.each do |wd|
		           @wind_direction.push(convert_direction_to_degree(wd.text))
		           end
				  end
				  end
				  doc.css("#tCEN").each do |a| 
                  dataStation = a.css("tr")			  
                  dataStation.each do |b|
	              windspeedTemp =  b.css("td").select{|h| h['headers'].include? "tCEN-wind tCEN-wind-gust-kmh tCEN-station-"}
				  winddirectionTemp = b.css("td").select{|h| h['headers'].include? "tCEN-wind tCEN-wind-dir tCEN-station-"}
		           windspeedTemp.each do |t|
		           @wind_speed.push t.text
		           end 
				   winddirectionTemp.each do |wd|
		           @wind_direction.push(convert_direction_to_degree(wd.text))
		           end
				  end
				  end
				   doc.css("#tNCY").each do |a| 
                  dataStation = a.css("tr")			  
                  dataStation.each do |b|
	              windspeedTemp =  b.css("td").select{|h| h['headers'].include? "tNCY-wind tNCY-wind-gust-kmh tNCY-station-"}
				  winddirectionTemp = b.css("td").select{|h| h['headers'].include? "tNCY-wind tNCY-wind-dir tNCY-station-"}
		           windspeedTemp.each do |t|
		           @wind_speed.push t.text
		           end 
				   winddirectionTemp.each do |wd|
		           @wind_direction.push(convert_direction_to_degree(wd.text))
		           end
				  end
				  end
				      	      doc.css("#tNE").each do |a| 
                  dataStation = a.css("tr")			  
                  dataStation.each do |b|
	              windspeedTemp =  b.css("td").select{|h| h['headers'].include? "tNE-wind tNE-wind-gust-kmh tNE-station-"}
				  winddirectionTemp = b.css("td").select{|h| h['headers'].include? "tNE-wind tNE-wind-dir tNE-station-"}
		           windspeedTemp.each do |t|
		           @wind_speed.push t.text
		           end 
				   winddirectionTemp.each do |wd|
		           @wind_direction.push(convert_direction_to_degree(wd.text))
		           end
				  end
				  end
				     doc.css("#tNC").each do |a| 
                  dataStation = a.css("tr")			  
                  dataStation.each do |b|
	              windspeedTemp =  b.css("td").select{|h| h['headers'].include? "tNC-wind tNC-wind-gust-kmh tNC-station-"}
				  winddirectionTemp = b.css("td").select{|h| h['headers'].include? "tNC-wind tNC-wind-dir tNC-station-"}
		           windspeedTemp.each do |t|
		           @wind_speed.push t.text
		           end 
				   winddirectionTemp.each do |wd|
		           @wind_direction.push(convert_direction_to_degree(wd.text))
		           end
				  end
				  end
				     doc.css("#tWSG").each do |a| 
                  dataStation = a.css("tr")			  
                  dataStation.each do |b|
	              windspeedTemp =  b.css("td").select{|h| h['headers'].include? "tWSG-wind tWSG-wind-gust-kmh tWSG-station-"}
				  winddirectionTemp = b.css("td").select{|h| h['headers'].include? "tWSG-wind tWSG-wind-dir tWSG-station-"}
		           windspeedTemp.each do |t|
		           @wind_speed.push t.text
		           end 
				   winddirectionTemp.each do |wd|
		           @wind_direction.push(convert_direction_to_degree(wd.text))
		           end
				  end
				  end
				  	 doc.css("#tEG").each do |a| 
                  dataStation = a.css("tr")			  
                  dataStation.each do |b|
	              windspeedTemp =  b.css("td").select{|h| h['headers'].include? "tEG-wind tEG-wind-gust-kmh tEG-station-"}
				  winddirectionTemp = b.css("td").select{|h| h['headers'].include? "tEG-wind tEG-wind-dir tEG-station-"}
		           windspeedTemp.each do |t|
		           @wind_speed.push t.text
		           end 
				   winddirectionTemp.each do |wd|
		           @wind_direction.push(convert_direction_to_degree(wd.text))
		           end
				  end
				  end
				   	 doc.css("#tMOB").each do |a| 
                  dataStation = a.css("tr")			  
                  dataStation.each do |b|
	              windspeedTemp =  b.css("td").select{|h| h['headers'].include? "tMOB-wind tMOB-wind-gust-kmh tMOB-station-"}
				  winddirectionTemp = b.css("td").select{|h| h['headers'].include? "tMOB-wind tMOB-wind-dir tMOB-station-"}
		           windspeedTemp.each do |t|
		           @wind_speed.push t.text
		           end 
				   winddirectionTemp.each do |wd|
		           @wind_direction.push(convert_direction_to_degree(wd.text))
		           end
				  end
				  end
				 count = Readingdata.count
				 for i in 0..@wind_speed.length-1
				     Wind.create(:speed=>"#{@wind_speed[i]}",:maxspeed=>"#{-100}",:direction=>"#{@wind_direction[i]}",:maxdirection=>"#{-100}",:readingdata_id=>"#{count-@wind_speed.length+i+1}")
				 end
				 current=DateTime.now
                          if current.hour-12==0 && current.minute-10<0
                                    count = Readingdata.count
									@mwd = []
									@mws = []
									@mvd=refresh_max_dir
									@mvs=refresh_max_speed
									for i in 0..@mvd.length-1
									 Wind.create(:speed=>"#{-100}", :maxspeed=>"#{@mws[i]}", :direction=>"#{-100}", :maxdirection=>"#{@mvd[i]}", readingdata_id=>"#{count-@mvd.length+i+1}")
									end
                          end
			 end
end
def refresh_max_rainfall
        doc = Nokogiri::HTML(open(URL))
		   addlinks = doc.css("a").select{|k| k['href'].include? "/products/IDV60801/IDV60801."}
           datalinks=[]	  
		   latlon=[]
		   
		   addlinks.each do |link|
           datalinks.push KEY_URL + "/" + link['href']
           end
			@climate_link_address=[]
			max_amount=[]
          for i in 0..datalinks.length-1
		           doclink = Nokogiri::HTML(open(datalinks[i]))				
				   climate_link=doclink.css("a").select{|h| h['href'].include? "/climate/dwo/"}				  
                   @climate_link_address.push(KEY_URL + "/" + climate_link[0]['href'])		   			   
		   end 		    
 	                  for i in 0..@climate_link_address.length-1                  
					  if @climate_link_address[i].size==58
					  climate = Nokogiri::HTML(open(@climate_link_address[i]))
                      climate_tr = climate.css('tr')     
					   if climate_tr[climate_tr.length-7].css('td[5]').to_s.include? "&"
					     max_amount.push max_amount[max_amount.length-1]   
					   else
					     max_amount.push climate_tr[climate_tr.length-7].css('td[5]').text
					   end   
                      else 									    
					    max_amount.push max_amount[max_amount.length-1]				                     				  
                      end
                    end
					return max_amount
end
def get_max_rainfall
         doc = Nokogiri::HTML(open(URL))
		   addlinks = doc.css("a").select{|k| k['href'].include? "/products/IDV60801/IDV60801."}
           datalinks=[]	  
		   latlon=[]
		   addlinks.each do |link|
           datalinks.push KEY_URL + "/" + link['href']
           end
			@climate_link_address=[]
          max_amount = []			
        for i in 0..datalinks.length-1
		           doclink = Nokogiri::HTML(open(datalinks[i]))				
				   climate_link=doclink.css("a").select{|h| h['href'].include? "/climate/dwo/"}				  
                   @climate_link_address.push(KEY_URL + "/" + climate_link[0]['href'])		   			   
		   end 		    
 	                  for i in 0..@climate_link_address.length-1
                      
					  if @climate_link_address[i].size==58
					  climate = Nokogiri::HTML(open(@climate_link_address[i]))
                      climate_tr = climate.css('tr')       
                     					  
                      for j in 3..climate_tr.length-7
					   max_amount.push climate_tr[j].css('td[5]').text
                      end
                      else 
					  for k in 1..climate_tr.length-9
					      max_amount.push max_amount[max_amount.length-(climate_tr.length-9)]
                      end					  
                      end
                      end	
					  return max_amount
end
def store_rainfall
       doc = Nokogiri::HTML(open(URL))		   
		   addlinks = doc.css("a").select{|k| k['href'].include? "/products/IDV60801/IDV60801."}
           datalinks=[]	  
		   latlon=[]
		   addlinks.each do |link|
           datalinks.push KEY_URL + "/" + link['href']
           end
		   count = Rainfallamount.count
		   @last_few_weeks_max_amount=[]
		   if count==0
		   @rainfall=[]
		  readingdatas = Readingdata.all
		    for i in 0..datalinks.length-1
			doclink = Nokogiri::HTML(open(datalinks[i]))
			  for i in 1..3
				    rainfall = doclink.css("td"+"[headers="+"t#{i}"+"-rainsince9am"+"]")
					  rainfall.each do |t|
					     @rainfall.push(t.text)
					  end
					end
			end
			@last_few_weeks_max_amount=get_max_rainfall
			for i in 0..(readingdatas.length-@last_few_weeks_max_amount.length-1)
				      Rainfallamount.create(:amount=>"#{@rainfall[i]}",:maxamount=>"#{-100}", :readingdata_id=>"#{readingdatas[i].id}")				  
		    end
			          @number=0
			for i in (readingdatas.length-@last_few_weeks_max_amount.length)..(readingdatas.length-1)			          
			          Rainfallamount.create(:amount=>"#{-100}",:maxamount=>"#{@last_few_weeks_max_amount[@number]}", :readingdata_id=>"#{readingdatas[i].id}")	
					  @number=@number+1
			end	
			else
			    @rainfall=[]
			    doc = Nokogiri::HTML(open(URL))
			      doc.css("#tMAL").each do |a| 
                  dataStation = a.css("tr")			  
                  dataStation.each do |b|
	              rainfallTemp = b.css("td").select{|h| h['headers'].include? "tMAL-rainsince9am tMAL-station-"}
		         rainfallTemp.each do |t|
		         @rainfall.push t.text
		         end 
				 end
				 end
				 
				   doc = Nokogiri::HTML(open(URL))
			      doc.css("#tWIM").each do |a| 
                  dataStation = a.css("tr")			  
                  dataStation.each do |b|
	              rainfallTemp = b.css("td").select{|h| h['headers'].include? "tWIM-rainsince9am tWIM-station-"}
		         rainfallTemp.each do |t|
		         @rainfall.push t.text
		         end 
				 end
				 end
				 
				   doc = Nokogiri::HTML(open(URL))
			      doc.css("#tSW").each do |a| 
                  dataStation = a.css("tr")			  
                  dataStation.each do |b|
	              rainfallTemp = b.css("td").select{|h| h['headers'].include? "tSW-rainsince9am tSW-station-"}
		         rainfallTemp.each do |t|
		         @rainfall.push t.text
		         end 
				 end
				 end
				 
				   doc = Nokogiri::HTML(open(URL))
			      doc.css("#tCEN").each do |a| 
                  dataStation = a.css("tr")			  
                  dataStation.each do |b|
	              rainfallTemp = b.css("td").select{|h| h['headers'].include? "tCEN-rainsince9am tCEN-station-"}
		         rainfallTemp.each do |t|
		         @rainfall.push t.text
		         end 
				 end
				 end
				 
				   doc = Nokogiri::HTML(open(URL))
			      doc.css("#tNCY").each do |a| 
                  dataStation = a.css("tr")			  
                  dataStation.each do |b|
	              rainfallTemp = b.css("td").select{|h| h['headers'].include? "tNCY-rainsince9am tNCY-station-"}
		         rainfallTemp.each do |t|
		         @rainfall.push t.text
		         end 
				 end
				 end
				 
				   doc = Nokogiri::HTML(open(URL))
			      doc.css("#tNE").each do |a| 
                  dataStation = a.css("tr")			  
                  dataStation.each do |b|
	              rainfallTemp = b.css("td").select{|h| h['headers'].include? "tNE-rainsince9am tNE-station-"}
		         rainfallTemp.each do |t|
		         @rainfall.push t.text
		         end 
				 end
				 end
				 
				   doc = Nokogiri::HTML(open(URL))
			      doc.css("#tNC").each do |a| 
                  dataStation = a.css("tr")			  
                  dataStation.each do |b|
	              rainfallTemp = b.css("td").select{|h| h['headers'].include? "tNC-rainsince9am tNC-station-"}
		         rainfallTemp.each do |t|
		         @rainfall.push t.text
		         end 
				 end
				 end
				 
				   doc = Nokogiri::HTML(open(URL))
			      doc.css("#tWSG").each do |a| 
                  dataStation = a.css("tr")			  
                  dataStation.each do |b|
	              rainfallTemp = b.css("td").select{|h| h['headers'].include? "tWSG-rainsince9am tWSG-station-"}
		         rainfallTemp.each do |t|
		         @rainfall.push t.text
		         end 
				 end
				 end
				 
				   doc = Nokogiri::HTML(open(URL))
			      doc.css("#tEG").each do |a| 
                  dataStation = a.css("tr")			  
                  dataStation.each do |b|
	              rainfallTemp = b.css("td").select{|h| h['headers'].include? "tEG-rainsince9am tEG-station-"}
		         rainfallTemp.each do |t|
		         @rainfall.push t.text
		         end 
				 end
				 end
				 
				   doc = Nokogiri::HTML(open(URL))
			      doc.css("#tMOB").each do |a| 
                  dataStation = a.css("tr")			  
                  dataStation.each do |b|
	              rainfallTemp = b.css("td").select{|h| h['headers'].include? "tMOB-rainsince9am tMOB-station-"}
		         rainfallTemp.each do |t|
		         @rainfall.push t.text
		         end 
				 end
				 end
				 count = Readingdata.count
				 for i in 0..@rainfall.length-1
				     Rainfallamount.create(:amount=>"#{@rainfall[i]}",:maxamount=>"#{-100}", :readingdata_id=>"#{count-@rainfall.length+i+1}")
				 end
				 current=DateTime.now
                       if current.hour-12==0 && current.minute-10<0
                            count = Readingdata.count
						    @mrm = []
							@mrm = refresh_max_rainfall
							for i in 0..@mrm.length-1
							 Rainfallamount.create(:amount=>"#{-100}",:maxamount=>"#{@mrm[i]}", readingdata_id=>"#{count-@mrm.length+i+1}")
							end
                       end
			end
end

end

