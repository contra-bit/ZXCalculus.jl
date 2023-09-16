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

include("parameter.jl")

include("planar_multigraph.jl")

module ZW
using Expronicon.ADT: @adt, @const_use
using MLStyle
using ..ZXCalculus
using ..ZXCalculus.ZXW: _round_phase, Parameter
# these will be changed to using PlanarMultigraph: vertices after we split out package
using ..ZXCalculus: vertices, nv
import ..round_phases!

include("zw_adt.jl")
include("zw_diagram.jl")
include("zw_utils.jl")
end # module ZW

end # module
