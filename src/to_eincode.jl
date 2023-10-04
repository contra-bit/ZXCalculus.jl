Base.Matrix(zxwd::ZXWDiagram) = to_matrix(zxwd)
Base.Matrix(zxd::ZXDiagram) = to_matrix(zxd)
Base.Matrix(zxg::ZXGraph) = to_matrix(zxg)

function to_matrix(zxwd::ZXWDiagram; optimizer = GreedyMethod(), verbose = false)
    ec, ts = to_eincode(zxwd)
    verbose && println("Optimizing contraction orders...")
    ec_opt = optimize_code(ec, uniformsize(ec, 2), optimizer)
    verbose && println("Contracting...")
    m = ec_opt(ts...)
    return reshape(m, (1 << nin(zxwd), 1 << nout(zxwd)))
end

to_matrix(zxg::ZXGraph; kwargs...) = to_matrix(ZXDiagram(zxg); kwargs...)
function to_matrix(zxd::ZXDiagram; optimizer = GreedyMethod(), verbose = false)
    ec, ts = to_eincode(zxd)
    verbose && println("Optimizing contraction orders...")
    ec_opt = optimize_code(ec, uniformsize(ec, 2), optimizer);
    verbose && println("Contracting...")
    m = ec_opt(ts...)
    return reshape(m, (1<<nin(zxd), 1<<nout(zxd)))
end

function to_eincode(zxwd::ZXWDiagram{T,P}) where {T,P}
    tensors = []
    ixs = Vector{Tuple{T,T,T}}[]
    iy = Tuple{T,T,T}[]
    for v in vertices(zxwd.mg)
        res = @match zxwd.st[v] begin
            Z(p) => z_tensor(degree(zxwd, v), p)
            X(p) => x_tensor(degree(zxwd, v), p)
            W => w_tensor(degree(zxwd, v))
            H => h_tensor(degree(zxwd, v))
            D => d_tensor(degree(zxwd, v))
            Input(q) => nothing
            Output(q) => nothing
        end

        if !isnothing(res)
            push!(ixs, to_eincode_indices(zxwd, v))
            push!(tensors, res)
        end
    end

    for v in get_outputs(zxwd)
        push!(iy, to_eincode_indices(zxwd, v)[])
    end

    for v in get_inputs(zxwd)
        push!(iy, to_eincode_indices(zxwd, v)[])
    end

    scalar_tensor = zeros(ComplexF64, ())

    scalar_tensor[] = ZXCalculus.unwrap_scalar(scalar(zxwd))
    push!(ixs, Tuple{T,T,T}[])
    push!(tensors, scalar_tensor)
    return EinCode(ixs, iy), tensors
end

function to_eincode_indices(zxwd::ZXWDiagram{T,P}, v) where {T,P}
    nbs = neighbors(zxwd, v; count_mul = true)
    ids = Tuple{T,T,T}[]
    isempty(nbs) && return ids
    curr_nb = nbs[1]
    curr_mul = 1
    for i = 1:length(nbs)
        nb = nbs[i]
        if nb != curr_nb
            curr_nb = nb
            curr_mul = 1
        end
        if nb == v
            push!(ids, edge_index(v, nb, (curr_mul + 1) ÷ 2))
        else
            push!(ids, edge_index(v, nb, curr_mul))
        end
        curr_mul += 1
    end
    return ids
end

edge_index(v1, v2, mul) = (min(v1, v2), max(v1, v2), mul)

function z_tensor(n::Int, α::Parameter)
    shape = (fill(2, n)...,)
    factor = @match α begin
        PiUnit(pu, _) => exp(im * pu * π)
        Factor(f, _) => f
        _ => error("Invalid parameter type for Z-spider")
    end
    out = zeros(typeof(factor), shape...)
    out[1] = one(typeof(factor))
    out[fill(2, n)...] = factor
    return out
end

function x_tensor(n::Int, α::Parameter)
    pos = [1, 1] / sqrt(2)
    neg = [1, -1] / sqrt(2)
    shape = (fill(2, n)...,)
    factor = @match α begin
        PiUnit(pu, _) => exp(im * pu * π)
        Factor(f, _) => f
        _ => error("Invalid parameter type for X-spider")
    end
    return reshape(reduce(kron, fill(pos, n)) + factor * reduce(kron, fill(neg, n)), shape)
end

function w_tensor(n::Int)
    w = zeros(ComplexF64, fill(2, n)...)
    for i = 1:n
        id = ones(Int, n)
        id[i] = 2
        w[id...] = 1
    end
    return w
end

function h_tensor(n::Int)
    n == 2 || error("General H-boxes with n-arity are not supported")
    return (1 / sqrt(2)) * ComplexF64[1 1; 1 -1]
end

function d_tensor(n::Int)
    n == 2 || error("A D-box can only has arity 2")
    return ComplexF64[1 1; 1 0] # D = T * X
end

### Can I merge this with the code above?
to_eincode(zxg::ZXGraph) = to_eincode(ZXDiagram(zxg))
function to_eincode(zxd::ZXDiagram{T, P}) where {T, P}
    vs = spiders(zxd)
    tensors = []
    ixs = Vector{Tuple{T, T, T}}[]
    iy = Tuple{T, T, T}[]
    for v in vs
        if !(spider_type(zxd, v) in (SpiderType.In, SpiderType.Out))
            push!(ixs, to_eincode_indices(zxd, v))
            push!(tensors, to_eincode_tensor(zxd, v))
        end
    end
    for o in get_outputs(zxd)
        if spider_type(zxd, o) in (SpiderType.In, SpiderType.Out)
            push!(iy, to_eincode_indices(zxd, o)[])
        end
    end
    for i in get_inputs(zxd)
        if spider_type(zxd, i) in (SpiderType.In, SpiderType.Out)
            push!(iy, to_eincode_indices(zxd, i)[])
        end
    end
    s = unwrap_scalar(scalar(zxd))
    scalar_tensor = zeros(ComplexF64, ())
    scalar_tensor[] = s
    push!(ixs, [])
    push!(tensors, scalar_tensor)
    return EinCode(ixs, iy), tensors
end

function to_eincode_indices(zxd::ZXDiagram{T, P}, v) where {T, P}
    nbs = neighbors(zxd, v; count_mul = true)
    ids = Tuple{T, T, T}[]
    isempty(nbs) && return ids
    curr_nb = nbs[1]
    curr_mul = 1
    for i = 1:length(nbs)
        nb = nbs[i]
        if nb != curr_nb            
            curr_nb = nb
            curr_mul = 1
        end
        if nb == v
            push!(ids, edge_index(v, nb, (curr_mul+1)÷2))
        else
            push!(ids, edge_index(v, nb, curr_mul))
        end
        curr_mul += 1
    end
    return ids
end

to_eincode_tensor(zxd::ZXDiagram, v) = to_eincode_tensor(spider_type(zxd, v), degree(zxd, v), phase(zxd, v))
