require './sfl_actop.rb'
require './sfl_diagnosis.rb'

$t1  = Topology.new

def top_0(topo)
  # topo.add ( component, health (error_probability), failure_probability, [options] )
  topo.add("S0", 1.0, 1.0)
  topo.add("S1", 1.0, 1.0)  
  topo.add("S2.1", 0.99, 0.0, :fatal)
  topo.add("S2.2", 1.0, 1.0)
  topo.add("S3", 1.0, 0.0)
  topo.add("S4", 1.0, 1.0)
  topo.add("S5", 0.99, 0.0)
  # topo.link ( name, from_component, to_component, invocation_probability)
  topo.link("L0", nil, "S0", 1.0)
  topo.link("L1", "S0", "S1", 0.0)
  topo.link("L2", "S0", "S2.1", 0.4)
  topo.link("L3", "S0", "S2.2", 0.1)
  topo.edge("L3", "S2.1")
  topo.link("L4", "S1", "S3", 0.8)
  topo.link("L5", "S2.1", "S3", 0.7)
  topo.link("L6", "S2.2", "S3", 0.3)
  topo.link("L7", "S2.1", "S4", 0.9)
  topo.link("L8", "S2.2", "S4", 0.8)
  topo.link("L9", "S3", "S5", 0.9)
  topo.link("L10","S3", nil, 0.1)
end

top_0($t1)
TopologyOutput.graph($t1, :png, "top0.png")

$t1.activate_until_error(["L0"]) {}

TopologyOutput.traces($t1)

puts "\nOriginal".red
$a1 = Actop.new($t1)
ActopOutput.screen($a1)
ActopOutput.graph($a1, :png, "top0_act.png")
$d1 = Diagnosis.new($a1)
DiagnosisOutput.screen($d1, {:sort => :ochiai}, :ochiai, :jaccard, :tarantula)

puts "\nUnique Spectra".red
$a2 = $a1.unique_fail()
ActopOutput.screen($a2)
$d2 = Diagnosis.new($a2)
DiagnosisOutput.screen($d2, {:sort => :ochiai}, :ochiai, :jaccard, :tarantula)
