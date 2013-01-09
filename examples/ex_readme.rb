require './sfl_actop.rb'
require './sfl_diagnosis.rb'

t = Topology.new

t.add("C0", 1.0, 1.0)   # a 100% healthy component, C0, with 100% failure probability
t.add("C1", 1.0, 1.0)   # a 100% healthy component, C1, with 100% failure probability
t.add("C2", 0.0, 0.0)   # a 100% faulty component, C2, with 0% failure probability  
t.add("C3", 0.5, 1.0)   # a 50% intermittently faulty component, C3, with 100% failure probability  
t.add("C4", 1.0, 1.0)   # another healthy component

t.link("L0", "C0", "C1", 1.0) # C0 is the starting point for the system it links to C1 with 100% invocation probability
t.edge("L0", "C2")            # L0 also links to C2 (add another edge) with the same probability
t.link("L1", "C1", "C3", 0.8) # link C1 -> C1 with 80% invocation probability
t.link("L2", "C2", "C3", 0.5) # link C2 -> C3 with 50% invocation probability
t.link("L3", "C2", "C4", 0.3) # link C2 -> C4 with 30% invocation probability

TopologyOutput.graph(t, :png, "ex_readme.png")

t.activate_often(["C0"], 20){}

TopologyOutput.traces(t)

actop = Actop.new(t)
ActopOutput.screen(actop)
ActopOutput.graph(actop, :png, "ex_readme_actop.png")

diagnosis = Diagnosis.new(actop)
DiagnosisOutput.screen(diagnosis, {:sort => :ochiai, :edge => true}, :ochiai, :jaccard)
