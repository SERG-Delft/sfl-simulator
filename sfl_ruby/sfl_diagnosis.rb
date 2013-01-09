
require 'colorize'
require './sfl_actop.rb'
require './sfl_similarity.rb'

class Diagnosis
  attr_reader :actop
  def initialize(actop)
    if actop.class != Actop then
      raise ArgumentError, "type mismatch Actop -> #{actop.class}"
    end
    @actop = actop
  end
  
  def each_component(*similarities)
    # calculate for each component the similarites with the error vector
    result = Hash.new
    for index in 0..@actop.comps.size-1 do
      sc = Array.new
      similarities.each do |s|
        sim_coeff = method(s)
        sc << sim_coeff.call(@actop.activity.row(index), @actop.error)
      end
      yield @actop.comps[index], sc
      result[@actop.comps[index]] = sc
    end
    return result
  end

  def ranking(similarity_coefficient, *options)
    # produce a diagnosis ranking according to similarity_coefficient
    if options.include?(:link) then include_links = true else include_links = false end
    result = Array.new
    each_component(similarity_coefficient) do |c, sc|
      if c.link? then
        if include_links then
          result << [ c, sc[0][1] ]
        end
      else
        result << [ c, sc[0][1] ]
      end
    end
    return result.sort! { |a,b| b[1] <=> a[1] }
  end
end # Diagnosis


module DiagnosisOutput
  Column_width = 12 # for ouput of the SC
  def self.screen(diagnosis, options, *similarities)
    if diagnosis.class != Diagnosis or options.class != Hash or similarities.class != Array then
      raise ArgumentError, "type mismatch Diagnosis -> #{diagnosis.class}, Hash -> #{options.class}, Array -> #{similarities.class}"
    end
    # parse options
    options.has_key?(:sort) ? sort_criterion = options[:sort] : sort_criterion = nil
    options.has_key?(:link) ? include_links  = true : include_links = false
    # crate an output array with rows and columns
    output_array = Array.new; component_name_size = 0
    diagnosis.each_component(*similarities) do |component, similarities|
      component_name_size = component.name.size if component.name.size > component_name_size 
      if include_links then
        output_array <<  Array.[](component, similarities) if include_links
      else
        output_array <<  Array.[](component, similarities)
      end
    end
    if sort_criterion != nil then # seems we have to do some sorting of the output
      # where is our sorting criterion? output_array[0][1] => first row similarity coefficients
      index = 0; output_array[0][1].each_with_index do |sc, i|
        if sc[0] == sort_criterion then index = i end
      end
      output_array.sort! { |a,b| b[1][index][1] <=> a[1][index][1] }
    end
    # output_array is now sorted according to criterion => put it on screen, start with SC's
    print "".ljust(component_name_size) + " | ".blue
    output_array[0][1].each do |sc|
      if sc[0] == sort_criterion then 
        print ":#{sc[0]}".ljust(Column_width).red 
      else 
        print ":#{sc[0]}".ljust(Column_width).blue 
      end
      print " | ".blue
    end
    puts 
    output_array.each do |row|
      if row[0].health < 1.0 then color = :red else color = :blue end
      if row[0].link? then color = :yellow end
      print row[0].name.ljust(component_name_size).colorize(color)
      print " | ".blue
      row[1].each do |sc_value|
        print "#{sc_value[1]}".ljust(Column_width).colorize(color) + " | ".blue
      end
      puts
    end # output_array.each
  end
end # DiagnosisOutput
