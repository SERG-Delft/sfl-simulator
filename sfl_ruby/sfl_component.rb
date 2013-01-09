

class Component
  attr_accessor :name        # String
  attr_accessor :peers       # [Component, probab]
  attr_accessor :health      # 0.0 .. 1.0 -> defines intermittency, error probability
  attr_accessor :failure     # 0.0 .. 1.0 -> defines failure rate, failure probability
  attr_accessor :options     # e.g. :fatal

  def initialize(name, health, failure_prob, options)
    @name = name
    @health = health         # probability that an error occurs when covered (intermittency)
    @failure = failure_prob  # probability that a failure occurs when an error happened
    @options = options       # list of options for a component (properties, ...)
    @peers = Hash.new        # contains subordinate peer components / probab 
  end # initialize
 
  def add_peer(comp, prob)   # link another (peer) node to this one
    # accepts component object, and invocation probab
    if comp.class != Component then
      raise ArgumentError, "type mismatch Component -> #{comp.class}"
    end
    @peers[comp] = prob     
  end # add_peer

  def invoke(parent_node)    # invokes all peer components according to their invocation probab
    @peers.each do |comp,prob|
      if rand(0.0..1.0) <= prob then
        parent_node << comp.activate(parent_node)
      end
    end
  end # invoke

  def activate(parent_node)  # activates (calls) this component 
    # component is a NODE
    if parent_node == nil then # we are top-level component
      parent_node = TraceNode.new; parent_node.fault = 0; parent_node.error = 0; parent_node.failure = 0 
    end
    curr_node = TraceNode.new; curr_node.comp = @name
    curr_node.fault = curr_node.error = curr_node.failure = 0
    if rand(0.0..1.0) <= @health or options.include?(:link) then # do we trigger a fault? (not relevant if :edge)
      curr_node.fault = 0 
      curr_node.error = 0
    else 
      curr_node.fault = 1 
      curr_node.error = 1
    end 
    if parent_node.error == 1 or curr_node.error == 1 then # do we propagate an error?
      curr_node.error = 1 
    else 
      curr_node.error = 0 
    end
    # do we issue a failure?  
    if curr_node.error == 1 then
      if rand(0.0..1.0) <= @failure then 
        curr_node.failure = 1 
      else 
        curr_node.failure = 0 
      end 
      if @options.include?(:fatal) then curr_node.failure = 1 end
    end
    invoke(curr_node) unless curr_node.failure == 1   # continue tracing unless we observe a failure
    return curr_node
  end # activate

  def link?() # is this component a link or a normal node?
    return options.include?(:link)
  end
end # Component


module ComponentOutput
  def self.screen(component)
    if component.health < 1.0 then component_color = :red else component_color = :blue end
    print "#{component.name.colorize(component_color)} [h=#{component.health},f=#{component.failure},o=#{component.options}] {"
    component.peers.each do |array|
      if array[0].health < 1.0 then component_color = :red else component_color = :blue end
      print "[#{array[1].to_s.green}, #{array[0].name.colorize(component_color)}]"
    end
    puts "}"
  end
end
