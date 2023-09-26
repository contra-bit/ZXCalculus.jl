module ZXCalculus

using OMEinsum
using YaoHIR, YaoLocations
using YaoHIR.IntrinsicOperation
using YaoHIR: Chain
using YaoLocations: plain
using MLStyle
using Graphs, Multigraphs

using Graphs:
  nv,
  ne,
  outneighbors,
  inneighbors,
  neighbors,
  rem_edge!,
  add_edge!,
  has_edge,
  degree,
  indegree,
  outdegree

import Graphs: has_vertex

export SpiderType, EdgeType
export AbstractZXDiagram, ZXDiagram, ZXGraph
export AbstractRule
export Rule, Match, Scalar

export push_gate!, pushfirst_gate!, tcount
export convert_to_chain, convert_to_zxd
export rewrite!,
  simplify!,
  clifford_simplification,
  full_reduction,
  circuit_extraction,
  phase_teleportation
export phase, spiders, rem_spider!
export plot
export BlockIR

include("scalar.jl")

include("phase.jl")

include("abstract_zx_diagram.jl")
include("zx_layout.jl")
include("zx_diagram.jl")
include("zx_graph.jl")

include("rules.jl")
include("simplify.jl")
include("circuit_extraction.jl")
include("phase_teleportation.jl")

include("ir.jl")

include("deprecations.jl")

module ZXW
using Expronicon.ADT: @const_use, @adt
using MLStyle, Multigraphs, Graphs
using OMEinsum
import Multigraphs: has_vertex
using ..ZXCalculus
using ..ZXCalculus: safe_convert, add_phase!
import ..pushfirst_gate!, ..push_gate!
import ..rewrite!, ..add_power!, ..add_edge!, ..vertices, ..nv, ..round_phases!


include("adts.jl")
include("zxw_diagram.jl")
include("zxw_rules.jl")
include("to_eincode.jl")
include("utils.jl")

end # module ZXW

using .ZXW: ZXWDiagram, CalcRule

export ZXWDiagram, CalcRule
using .ZXW:
  ZXWDiagram,
  ZXWSpiderType,
  Parameter,
  CalcRule,
  PiUnit,
  Factor,
  Input,
  Output,
  W,
  H,
  D,
  Z,
  X,
  rewrite!
export ZXWSpiderType,
  ZXWDiagram, Parameter, PiUnit, Factor, Input, Output, W, H, D, Z, X, CalcRule
export substitute_variables!, expval_circ!, stack_zxwd!, concat!

include("parameter.jl")

include("planar_multigraph.jl")

module ZW
using Expronicon.ADT: @adt, @const_use
using MLStyle, Graphs
using ..ZXCalculus
using ..ZXCalculus.ZXW: _round_phase, Parameter
# these will be changed to using PlanarMultigraph: vertices after we split out package
using ..ZXCalculus:
    vertices,
    nv,
    has_vertex,
    ne,
    neighbors,
    rem_edge!,
    add_edge!,
    degree,
    next,
    split_vertex!,
    split_edge!,
    face,
    trace_face,
    make_hole!,
    add_vertex_and_facet_to_boarder!,
    split_facet!,
    twin,
    prev,
    add_multiedge!,
    join_facet!,
    trace_vertex,
    join_vertex!




# these remains
using ..ZXCalculus: add_phase!
import ..ZXCalculus: add_power!, add_global_phase!, scalar, spiders, rem_spider!
import Graphs.rem_edge!


include("zw_adt.jl")
include("zw_diagram.jl")
include("zw_utils.jl")
end # module ZW


include("plots/zx_plot.jl")


include("qasm.jl")
end # module
