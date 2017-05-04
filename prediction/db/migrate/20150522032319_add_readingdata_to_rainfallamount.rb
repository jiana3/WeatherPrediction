class AddReadingdataToRainfallamount < ActiveRecord::Migration
  def change
    add_reference :rainfallamounts, :readingdata, index: true
  end
end
