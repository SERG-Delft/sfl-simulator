Spectrum-based Fault Localization (SFL) Simulator
=================================================

SFL Simulator is used to to support research in spectrum-based fault localization. It simulates a component topology and its activations, creates an activity matrix, and calculates a diagnosis based on a similarity coefficient. The simulator is written in the ruby language (version 1.9.3). 

Requirements
------------
*   Ruby 1.9.3
*   graphviz gem (plus [graphviz](http://www.graphviz.org) installation)
*   colorize gem

Usage
-----

Create a new topology (please note, that all files should in the same directory).

       require './sfl_actop.rb'
       require './sfl_diagnosis.rb'
       t = Topology.new()

Add components to the topology: 

    t.add("C0", 1.0, 1.0)   # a 100% healthy component, C0, with 100% failure probability
    t.add("C1", 1.0, 1.0)   # a 100% healthy component, C1, with 100% failure probability
    t.add("C2", 0.0, 0.0)   # a 100% faulty component, C2, with 0% failure probability  
    t.add("C3", 0.5, 1.0)   # a 50% intermittently faulty component, C3, with 100% failure probability  
    t.add("C4", 1.0, 1.0)   # another healthy component 

A component must have a name, a health value, and a failure probability. The name is an arbitrary but unique ruby string, the health value must be between 0.0 and 1.0. A health of 1.0 represents a 100% healthy component, a value of 0.0 represents a 100% faulty component. It determines the probability of a component to issue a fault if the component is activated. The failure probability (0.0..1.0) determines the probability that a fault is detectected, leading to a failure. If all failure probabilities are 0.0 a fault will be detected at the end of an activation.

Link the components to form a topology:

     t.link("L0", "C0", "C1", 1.0) # link C0 -> C1 with 100% invocation probability
     t.edge("L0", "C2")            # link C0 -> C2 (in the same link) 
     t.link("L1", "C1", "C3", 0.8) # link C1 -> C1 with 80% invocation probability
     t.link("L2", "C2", "C3", 0.5) # link C2 -> C3 with 50% invocation probability
     t.link("L3", "C2", "C4", 0.3) # link C2 -> C4 with 30% invocation probability    

A link between components must have a unique name (string), an originating component name (string), a destination component name (string), and an invocation probability. This determines the likelihood of a link being executed, and thus, a subsequent component being called. 

Generate a picture of the topology:

	 TopologyOutput.graph(t, :png, "ex_readme.png")

This uses the graphviz library in order to generate a picture of the topology. The filetypes (e.g. :png) correspond to the [file types provided by graphviz](http://www.graphviz.org/content/output-formats). This ![figure](sfl-simulator/examples/ex_readme.png) displays the topology described above.

The execution of the component topology can now be simulated, either with a fixed number of executions:

    t.activate_often(["C0"], 20) # exercise Topology t 20 times, start in C0

Several components may be activated at the same time:

    t.activate_often(["C0", "C4"]) {}

Components can also be activated until a component fails. This is useful when very low fault intermittency must be simulated:

    t.activate_until_error(["C0"]) {}

Activation leads to traces, which can be shown:

    TopologyOutput.traces(t)

This results in an output like the following. Each activation results in one line with the component executed, the link invoked, plus [fault, error, failure] information. The curly brackets {} indicate invocation nesting.

    C0[0,0,0]{L0[0,0,0]{C1[0,0,0]{L1[0,0,0]{C3[0,0,0]}}}{C2[1,1,0]{L2[0,1,0]{C3[1,1,1]}}}}[fail]
    C0[0,0,0]{L0[0,0,0]{C1[0,0,0]{L1[0,0,0]{C3[1,1,1]}}}{C2[1,1,0]{L3[0,1,0]{C4[0,1,1]}}}}[fail]
    C0[0,0,0]{L0[0,0,0]{C1[0,0,0]{L1[0,0,0]{C3[0,0,0]}}}{C2[1,1,0]{L2[0,1,0]{C3[0,1,1]}}}}[fail]
    C0[0,0,0]{L0[0,0,0]{C1[0,0,0]}{C2[1,1,0]{L2[0,1,0]{C3[1,1,1]}}{L3[0,1,0]{C4[0,1,1]}}}}[fail]
    C0[0,0,0]{L0[0,0,0]{C1[0,0,0]}{C2[1,1,0]{L2[0,1,0]{C3[0,1,1]}}}}[fail]
    C0[0,0,0]{L0[0,0,0]{C1[0,0,0]{L1[0,0,0]{C3[1,1,1]}}}{C2[1,1,0]}}[fail]
    C0[0,0,0]{L0[0,0,0]{C1[0,0,0]{L1[0,0,0]{C3[0,0,0]}}}{C2[1,1,0]}}[fail]
    C0[0,0,0]{L0[0,0,0]{C1[0,0,0]}{C2[1,1,0]{L2[0,1,0]{C3[0,1,1]}}{L3[0,1,0]{C4[0,1,1]}}}}[fail]
    C0[0,0,0]{L0[0,0,0]{C1[0,0,0]{L1[0,0,0]{C3[0,0,0]}}}{C2[1,1,0]{L2[0,1,0]{C3[1,1,1]}}}}[fail]
    C0[0,0,0]{L0[0,0,0]{C1[0,0,0]{L1[0,0,0]{C3[0,0,0]}}}{C2[1,1,0]{L3[0,1,0]{C4[0,1,1]}}}}[fail]
    C0[0,0,0]{L0[0,0,0]{C1[0,0,0]{L1[0,0,0]{C3[1,1,1]}}}{C2[1,1,0]{L2[0,1,0]{C3[1,1,1]}}}}[fail]
    C0[0,0,0]{L0[0,0,0]{C1[0,0,0]{L1[0,0,0]{C3[0,0,0]}}}{C2[1,1,0]{L2[0,1,0]{C3[0,1,1]}}}}[fail]
    C0[0,0,0]{L0[0,0,0]{C1[0,0,0]}{C2[1,1,0]{L3[0,1,0]{C4[0,1,1]}}}}[fail]
    C0[0,0,0]{L0[0,0,0]{C1[0,0,0]}{C2[1,1,0]{L2[0,1,0]{C3[1,1,1]}}{L3[0,1,0]{C4[0,1,1]}}}}[fail]
    C0[0,0,0]{L0[0,0,0]{C1[0,0,0]}{C2[1,1,0]}}[fail]
    C0[0,0,0]{L0[0,0,0]{C1[0,0,0]}{C2[1,1,0]{L2[0,1,0]{C3[0,1,1]}}}}[fail]
    C0[0,0,0]{L0[0,0,0]{C1[0,0,0]{L1[0,0,0]{C3[0,0,0]}}}{C2[1,1,0]{L2[0,1,0]{C3[0,1,1]}}}}[fail]
    C0[0,0,0]{L0[0,0,0]{C1[0,0,0]{L1[0,0,0]{C3[0,0,0]}}}{C2[1,1,0]}}[fail]
    C0[0,0,0]{L0[0,0,0]{C1[0,0,0]{L1[0,0,0]{C3[1,1,1]}}}{C2[1,1,0]{L2[0,1,0]{C3[1,1,1]}}}}[fail]
    C0[0,0,0]{L0[0,0,0]{C1[0,0,0]{L1[0,0,0]{C3[1,1,1]}}}{C2[1,1,0]{L2[0,1,0]{C3[0,1,1]}}}}[fail] 

An activated topology can be used for diagnosis experiments. First, the topology activation can be created and shown:

    actop = Actop.new(t)
    ActopOutput.screen(actop)
    ActopOutput.graph(actop, :png, "ex_readme_actop.png")

    C0 11111111111111111111   # activity of the components
    C1 11111111111111111111
    C2 11111111111111111111
    C3 01111110110010111111
    C4 10100010001011101111
    L0 11111111111111111111   # activity of the links
    L1 01111110010000111111
    L2 01011000100010000111
    L3 10100010001011101111
    E  11111111111111111111   # error vector

Finally, a diagnosis can be calculated and shown:

	diagnosis = Diagnosis.new(actop)
	DiagnosisOutput.screen(diagnosis, {:sort => :ochiai}, :ochiai, :jaccard)

   	   | :ochiai      | :jaccard     | 
 	C0 | 1.0          | 1.0          | 
	C1 | 1.0          | 1.0          | 
	C2 | 1.0          | 1.0          |  
	L0 | 1.0          | 1.0          |  
	C3 | 0.975        | 0.95         |  
	L1 | 0.806        | 0.65         | 
	L2 | 0.707        | 0.5          | 
	C4 | 0.387        | 0.15         | 
	L3 | 0.387        | 0.15         | 

    
    
