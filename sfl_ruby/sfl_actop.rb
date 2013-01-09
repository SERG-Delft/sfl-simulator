require 'colorize'
require './sfl_topology.rb'
require './sfl_similarity.rb'

class Actop
  attr_reader :comps; attr_reader :traces
  attr_reader :activity, :error
  attr_reader :act_fault, :act_error, :act_failure
  def initialize(topology, *options)
    if topology.class != Topology then
      raise ArgumentError, "type mismatch Topology -> #{topology.class}"
    end
    @comps = topology.comps
    @traces = topology.traces
    acterror()
  end

  def similar_fail(similarity_coefficient, lower, upper)
    # creates a new Topology with traces/spectra that are similar to the failed traces/spectra 
    # in the range lower .. upper
    failed_indices = failed_indices()
    similar_indices = Array.new;  sc = method(similarity_coefficient)
    for idx_all in 0..@error.size-1 do
      failed_indices.each do |idx_f|
        if idx_all == idx_f then
          similar_indices << idx_all
        else
          name, val = sc.call(activity.spectrum(idx_all),activity.spectrum(idx_f))
          if val >= lower and val <= upper then
            similar_indices << idx_all
          end
        end
      end 
    end # for
    return make_topology(similar_indices)
  end # similar_fail

  def unique_fail()
    # create a new Topology with unique spectra 
    unique_indices = [0]
    for idx_all in 1..@error.size-1 do
      if @error[idx_all] == 1 then
        unique_indices << idx_all # always add error spectrum
      else
        unique = true
        unique_indices.each do |idx_unique|
          if activity.spectrum(idx_all) == activity.spectrum(idx_unique) then
            unique = false; break
          end
        end
        unique_indices << idx_all if unique
      end # if
    end # for
    return make_topology(unique_indices)
  end # unique_fail

  private # --------------------------------------------------------------------------------------
  def make_topology(indices)
    new_traces = Array.new
    indices.each do |idx|
      new_traces << @traces[idx]
    end
    topology = Topology.new; topology.comps = @comps; topology.traces = new_traces
    return Actop.new(topology)
  end

  def failed_indices()
    # figure out the failed traces
    failed_indices = Array.new
    @error.each_index do |idx| 
      failed_indices << idx if @error[idx] == 1  
    end
    return failed_indices
  end

  def acterror()
    # generate attributes from topology and traces
    @activity    = Activity.new(@comps.size); @error = Array.new
    @act_fault   = Activity.new(@comps.size)  # for fault activity
    @act_error   = Activity.new(@comps.size)  # for error activity
    @act_failure = Activity.new(@comps.size)  # for failure activity
    @traces.each do |t|
      activity_spectrum = Array.new; fault_spectrum = Array.new
      error_spectrum = Array.new; failure_spectrum = Array.new
      @comps.each do |c|
        if t.component?(c.name) then 
          activity_spectrum << 1 
          if t.component_fault?(c.name)   then fault_spectrum   << 1 else fault_spectrum   << 0 end 
          if t.component_error?(c.name)   then error_spectrum   << 1 else error_spectrum   << 0 end
          if t.component_failure?(c.name) then failure_spectrum << 1 else failure_spectrum << 0 end
        else 
          activity_spectrum << 0 
          fault_spectrum    << 0
          error_spectrum    << 0
          failure_spectrum  << 0
        end
      end
      @activity    << activity_spectrum
      @act_fault   << fault_spectrum
      @act_error   << error_spectrum
      @act_failure << failure_spectrum
      if t.fail? then @error << 1 else @error << 0 end
    end # each_trace
  end # activity_matrix
end



module ActopOutput
  def self.graph(actop, type, filename)
    graph = GraphViz.new( :topology, :type => :digraph, :rankdir => :LR)
    actop.comps.each do |comp|
      if comp.link? then
        # component is a LINK
        freq = 0; actop.traces.each { |t| freq += t.component_count(comp.name) }
        graph.add_nodes("#{comp.name}", :label => "#{comp.name} = #{comp.health}\n#{freq}", 
                        :fontsize => 12, 
                        :color => :lightgrey, 
                        :fixedsize => :true,
                        :width => 0.8,
                        :shape => :circle)
      else
        # component is a NODE
        if comp.health < 1.0 then # RED
          color = "#ee0000" 
          if comp.failure < 1.0 then
            color = "#880000"
          end
        end
        if comp.health == 1.0 then # GREEN
          color = "#00ee00" 
          if comp.failure < 1.0 then
            color = "#005000"
          end
        end
        if comp.health > 1.0 then # BLUE
          color = "#00eeee"
          if comp.failure < 1.0 then
            color = "#0000ee" 
          end
        end
        graph.add_nodes("#{comp.name}", 
                        :label => "<f0> #{comp.name} | <f1> h=#{comp.health} | <f2> f=#{comp.failure} | <f3> #{comp.options}", 
                        :color => color, 
                        :shape => :record)
      end # if ? :link
    end # actop.comps.each ...
    # output the edges
    actop.comps.each do |comp|
      comp.peers.each do |peer|
        if comp.link? then
          freq = 0; actop.traces.each { |t| freq += t.component_count(comp.name) }
          thickness = Math.sqrt(freq + 1)
          graph.add_edges("#{comp.name}", "#{peer[0].name}", :color => :lightgrey, :penwidth => thickness + 1)
        end
        if peer[0].link? then 
          freq = 0; actop.traces.each { |t| freq += t.component_count(peer[0].name) }
          thickness = Math.sqrt(freq + 1)
          graph.add_edges("#{comp.name}", "#{peer[0].name}", :color => :lightgrey, :dir => :none, :penwidth => thickness + 1)
        end
      end
    end
    graph.output( type => filename )
    return graph
  end # self.graph


  def self.screen(actop)
    if actop.class != Actop then 
      raise ArgumentError, "type mismatch Actop -> #{actop.class}"
    end
    component_name_size = 0; actop.comps.each do |c| # determine the longest component name
      if c.name.size > component_name_size then component_name_size = c.name.size end
    end
    actop.comps.each_index do |c_i|
      if actop.comps[c_i].health < 1.0 then component_color = :red else component_color = :blue end
      if actop.comps[c_i].options.include?(:link) then component_color = :yellow end
      print "#{actop.comps[c_i].name.ljust(component_name_size)} ".colorize(component_color)
      actop.activity.row(c_i).each_index do |a_i|
        if actop.activity.row(c_i)[a_i] == 0 then activity_color = :yellow end
        if actop.activity.row(c_i)[a_i] == 1 then activity_color = :yellow end
        if actop.activity.row(c_i)[a_i] == 1 and actop.act_error.row(c_i)[a_i] == 1   then activity_color = :cyan end
        if actop.activity.row(c_i)[a_i] == 1 and actop.act_failure.row(c_i)[a_i] == 1 then activity_color = :magenta end
        if actop.activity.row(c_i)[a_i] == 1 and actop.act_fault.row(c_i)[a_i] == 1   then activity_color = :red end
        print actop.activity.row(c_i)[a_i].to_s.colorize(activity_color)
      end
      puts 
    end
    print "E".ljust(component_name_size+1)
    actop.error.each do |e|
      print e.to_s.green if e == 0
      print e.to_s.red   if e == 1
    end
    puts # "\t[" + "fault".red + "|" + "error".cyan + "|" + "failure".magenta + "]"
  end
end # module
