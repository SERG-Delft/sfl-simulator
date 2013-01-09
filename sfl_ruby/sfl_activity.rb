
require 'colorize'

class Activity
  attr_reader :matrix  # Array of Arrays
  attr_reader :rows    # rows is constant
  def initialize(rows) # -------------------
    @rows   = rows
    @matrix = Array.new
    for r in 0..@rows-1 do
      @matrix[r] = Array.new
    end
  end
  def spectra()        # ------------------- number of spectra
    return @matrix[0].size
  end
  def <<(spectrum)     # ------------------- add a spectrum
    if spectrum.class == Array and spectrum.size == @rows then
      for r in 0..@rows-1 do 
        @matrix[r] << spectrum[r]
      end
    else
      raise ArgumentError, "type or size mismatch"
    end
  end
  def delete(index)    # ------------------- delete a spectrum
    @matrix.each do |row|
      row.delete_at(index)
    end
  end
  def [](index)        # ------------------- return a row
    return @matrix[index]
  end
  def row(index)       # ------------------- return a row
    return @matrix[index]
  end
  def row!(index, row) # ------------------- copy array into row
    @matrix[index] = row
  end
  def each_row()       # ------------------- yield all rows
    @matrix.each do |row|
      yield row
    end
  end    
  def each_row!(size)  # ------------------- overwrite all rows
    @matrix.each_index do |i|  
      row = yield @matrix[i]
      if row.size == size then  # size of each row is fixed 
        @matrix[i] = row        # and checked
      else
        raise ArgumentError, "size mismatch"
      end
    end
  end
  def spectrum(index)  # ------------------- return a spectrum
    s = Array.new
    @matrix.each do |row|
      s << row[index]
    end
    return s
  end
  def each_spectrum()  # ------------------- yield all spectra
    cols = @matrix[0].size
    for spectrum in 0..cols-1 do 
      s = Array.new
      for row in 0..@rows-1 do
        s << @matrix[row][spectrum]
      end
      yield s
    end
  end
end # class Activity



module ActivityOutput
  def self.screen(activity)
    if activity.class != Activity then
      raise ArgumentError, "wrong input type: Activity -> #{activity.class}"
    end
    activity.each_row do |r|
      r.each do |a|
        if a == 1 then print a.to_s.blue end
        if a == 0 then print a.to_s.cyan end 
      end
      puts
    end
  end
end


