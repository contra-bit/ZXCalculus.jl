
module Plotting

using ..ZXCalculus: AbstractZXDiagram

function plot(zxd::AbstractZXDiagram; backend=:vega, kwargs...)
  backend === :vega && return Plotting.plot(zxd; kwargs...)
  # backend === :compose && return plot_compose(zxd; kwargs...)
end

end
