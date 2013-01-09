Spectrum-based Fault Localization (SFL) Simulator
=================================================

SFL Simulator is used to to support research in spectrum-based fault localization. It simulates a component topology and its activations, creates an activity matrix, and calculates a diagnosis based on a similarity coefficient. The simulator is written in the ruby language (version 1.9.3). 

Requirements
------------
*   Ruby 1.9.3
*   graphviz gem (plus graphviz installation)
*   colorize gem

Usage
-----

Create a new topology 

       require './sfl_actop.rb'
       t = Topology.new

Add components to the topology. 

  	t.add("C1", 1.0, 1.0)   # a 100% healthy component, C1, with 100% failure probability
  	t.add("C2", 0.0, 0.0)   # a 100% faulty component, C2, with 0% failure probability  
	t.add("C3", 0.5, 1.0)   # a 50% intermittently faulty component, C3, with 100% failure probability  

A component must have a name, a health value, and a failure probability. The name is an arbitrary but unique ruby string, the health value must be between 0.0 and 1.0. A health of 1.0 represents a 100% healthy component, a value of 0.0 represents a 100% faulty component. It determines the probability of a component to issue a fault if the component is activated. The failure probability (0.0..1.0) determines the probability that a fault is detectected, leading to a failure. If all failure probabilities are 0.0 a fault will be detected at the end of an activation.

Link the components to form a topology.

     	t.link("L0", nil, "C1", 0.7)  # L0 is starting point for invoking C1 
	t.link("L1", nil, "C2", 0.3)  # and C2, with invocation probabilities
	t.link("L2", "C2", "C3", 1.0) # link C2 -> C3 with 100% invocation probability
	t.link("L3", "C3", nil, 0.5)  # add an empty link off C3

A link between components must have a unique name (string), an originating component name (string), a destination copmonent name (string), and an invocation probability. This determines the likelyhood of a link being executed, and thus, a subsequent component being called. 

