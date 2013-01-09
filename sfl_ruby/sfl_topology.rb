
# Topology Simulator
# maintains a topolgy of components
# with traces

require 'graphviz'
require 'colorize'
require './sfl_component.rb'
require './sfl_trace.rb'
require './sfl_activity.rb'

class Topology
  attr_accessor :comps          # list of all components in the topology
  attr_accessor :traces         # list of traces performed in this topology
  def initialize                # links between comps are encoded in the components themselves
    @comps  = Array.new
    @traces = Array.new
  end

  def add(name, health, failure_prob, *options) # add a new component
    # properties hash for future use
    comp = Component.new(name, health, failure_prob, options)
    @comps << comp
    return comp
  end

  def link(name, from, to, weight) # link two components with <from, to> with invoc. probab. 
    # link is actually another component, so create one with default values
    link = add(name, weight, 0.0, :link) # options => :link to indicate specific link component
    @comps.each do |f| # go through the existing (main) components
      if f.name == from then 
        f.add_peer(link, weight) # add FROM to the current (newly created) edge component
      end
    end
    @comps.each do |t| 
      if t.name == to then    # find the TO component
        link.add_peer(t, 1.0) # link the current component to TO (weight 1.0)
      end
    end # @comps
  end # def link

  def edge(from, to)
    @comps.each do |f|
      if f.name == from and f.options.include?(:link) then
        @comps.each do |t|
          if t.name == to then
            f.add_peer(t, 1.0)
          end # if
        end # @comps
      end # if
    end # @comps
  end # def edge

  def each_component()
    @comps.each do |c|
      yield c
    end
    return @comps
  end

  def each_trace()
    @traces.each do |t|
      yield t
    end
    return @traces
  end

  def activate(components)    # execute one test invoking several components at the same time
    trace = Trace.new         # topology makes and maintaines the traces, one trace per activation
    components.each do |requested_comp|
      @comps.each do |existing_comp|
        if requested_comp == existing_comp.name then  # find component in @comps
          trace_node = existing_comp.activate(nil)    # and activate it (starting point) with trace node
          trace.add(trace_node)                       # all activations are combined in a trace
        end # if
      end # @comps
    end # components.each
    @traces << trace          # add trace to list of traces for this topology
    return trace              # return latest trace
  end

  def activate_often(components, often) # perform a given number of activations
    traces = Array.new
    often.times do
      trace = activate(components)
      yield trace
      traces << trace
    end
    return traces
  end

  def activate_until_error(components) # perform activations until an error occurs
    traces = Array.new
    loop do
      last_trace = activate(components) 
      yield last_trace
      traces << last_trace
      break if last_trace.fail?  
    end
    return traces
  end
end # Topology

module TopologyOutput
  def self.graph(topology, filetype, filename)
    graph = GraphViz.new( :topology, :type => :digraph, :rankdir => :LR)
    topology.comps.each do |c|
      if c.options.include? (:link) then
        # component is an EDGE
        graph.add_nodes("#{c.name}", :label => "#{c.name} = #{c.health}", 
                        :fontsize => 10, 
                        :color => :lightgrey, 
                        :fixedsize => :true,
                        :width => 0.8,
                        :shape => :circle)
      else
        # component is a NODE
        if c.health < 1.0 then # RED
          color = "#ee0000" 
          if c.failure < 1.0 then
            color = "#880000"
          end
        end
        if c.health == 1.0 then # GREEN
          color = "#00ee00" 
          if c.failure < 1.0 then
            color = "#005000"
          end
        end
        if c.health > 1.0 then # BLUE
          color = "#00eeee"
          if c.failure < 1.0 then
            color = "#0000ee" 
          end
        end
        graph.add_nodes("#{c.name}", 
                        :label => "<f0> #{c.name} | <f1> h=#{c.health} | <f2> f=#{c.failure} | <f3> #{c.options}", 
                        :color => color, 
                        :shape => :record)
      end # if ? :link
    end # topology.comps.each ...
    topology.comps.each do |comp|
      comp.peers.each do |peer|
        if comp.options.include?(:link) then
          graph.add_edges("#{comp.name}", "#{peer[0].name}", :color => :lightgrey)
        else
          graph.add_edges("#{comp.name}", "#{peer[0].name}", :color => :lightgrey, :dir => :none)
        end
      end
    end # self.graph
    graph.output( filetype => filename )
    return graph
  end

  def self.screen(topology)
    topology.comps.each do |c|
      ComponentOutput.screen(c)
    end
  end

  def self.components(topology)
    screen(topology)
  end

  def self.traces(topology)
    topology.each_trace do |t|
      TraceOutput.screen(t)
    end
  end
end # module















