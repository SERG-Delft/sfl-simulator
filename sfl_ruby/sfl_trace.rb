require 'colorize'

class TraceNode
  attr_accessor :comp      
  attr_accessor :fault
  attr_accessor :error
  attr_accessor :failure
  attr_accessor :children
  def initialize()
    @children = Array.new
  end

  def add(traceNode)
    @children << traceNode
  end

  def <<(traceNode)
    @children << traceNode
  end

  def fault?()
    children.each do |n|
      return true if n.fault? 
    end
    return true if @fault == 1
    return false
  end

  def error?()
    children.each do |n|
      return true if n.error? 
    end
    return true if @error == 1
    return false
  end

  def failure?()
    children.each do |n|
      return true if n.failure? 
    end
    return true if @failure == 1
    return false
  end

  def component?(component)
    return true if @comp == component 
    children.each do |n|
      return true if n.component?(component)
    end
    return false
  end

  def component_count(component)
    count = 0
    children.each do |n|
      count += n.component_count(component)
    end
    return count + 1 if @comp == component
    return count
  end

  def component_fault?(component)
    return true if @comp == component and @fault == 1
    children.each do |n|
      return true if n.component_fault?(component)
    end
    return false
  end

  def component_error?(component)
    return true if @comp == component and @error == 1
    children.each do |n|
      return true if n.component_error?(component)
    end
    return false
  end

def component_failure?(component)
    return true if @comp == component and @failure == 1
    children.each do |n|
      return true if n.component_failure?(component)
    end
    return false
  end
end # TraceNode


module TraceNodeOutput
  def self.screen(node)
    print node.comp.blue; print "["
    if node.fault == 1   then print node.fault.to_s.red   else print node.fault.to_s.green end; print ","
    if node.error == 1   then print node.error.to_s.red   else print node.error.to_s.green end; print ","
    if node.failure == 1 then print node.failure.to_s.red else print node.failure.to_s.green end; print "]" 
    node.children.each do |n|
      print '{'
      TraceNodeOutput.screen(n)
      print '}'
    end
  end
end



class Trace
  attr_accessor :node   # list of top-level nodes
  def initialize()
    @node = Array.new
  end

  def add(trace_node)
    @node << trace_node
  end

  def <<(node)
    @node << trace_node
  end

  def each()
    @node.each_index do |i|
      yield @node[i], i
    end
    return @node
  end # each

  def each_index()
    @node.each_index do |i|
      yield i
    end
    return nil
  end

  def pass?()
    # return true if trace was a passed trace
    @node.each do |n|
      return false if n.fault? 
    end
    return true
  end # pass?
    
  def fail?()
    # return true if trace was a failed trace
    return not(pass?)
  end # fail?

  def component?(component) 
    # returns true if component is in the trace
    @node.each do |n|
      return n.component?(component)
    end
    return false
  end

  def component_count(component)
    # return the number of occurrences of component in this trace
    count = 0
    @node.each do |n|
      count += n.component_count(component)
    end
    return count
  end

  def component_fault?(component)
    # returns true if component has a fault
    @node.each do |n|
      return n.component_fault?(component)
    end
    return false
  end

  def component_error?(component)
    # returns true if component has an error
     @node.each do |n|
      return n.component_error?(component)
    end
    return false
  end 

  def component_failure?(component)
    # returns true if component has a failure
    @node.each do |n|
      return n.component_failure?(component)
    end
    return false
  end
end # Trace


module TraceOutput
  def self.screen(trace)
    if trace.class != Trace then
      raise ArgumentError, "#{trace.class}"
    end
    trace.node.each do |n|
      TraceNodeOutput.screen(n)
    end
    if trace.pass? then print "[pass]".green else print "[fail]".red end
    puts
  end
end
