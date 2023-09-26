### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 8ab9b70a-e98d-11ea-239c-73dc659722c2
begin
	import Pkg
	Pkg.add(url="https://github.com/Roger-luo/Expronicon.jl")  
	Pkg.add(url="https://github.com/JuliaCompilerPlugins/CompilerPluginTools.jl")
	Pkg.add(url="https://github.com/QuantumBFS/YaoHIR.jl", rev="master")
	Pkg.add(url="/home/liam/src/quantum-circuits/software/OpenQASM.jl")
	Pkg.add(url="https://github.com/QuantumBFS/YaoLocations.jl", rev="master")
	Pkg.add(url="https://github.com/QuantumBFS/Multigraphs.jl")
	#Pkg.add(url="https://github.com/contra-bit/ZXCalculus.jl", rev="feature/plots")
	Pkg.add(url="/home/liam/src/quantum-circuits/software/ZXCalculus.jl", rev="feat/convert_to_zxwd")
	
end

# ╔═╡ 512ac070-335e-45e9-a75d-e689af3ea59d
begin
	  using ZXCalculus
	  using YaoHIR, YaoLocations
	  using YaoHIR.IntrinsicOperation
	  using CompilerPluginTools
end

# ╔═╡ a9bf8e31-686a-4057-acec-bd04e8b5a3dc
using Multigraphs

# ╔═╡ 0378329e-819e-4c70-b543-33d47f6455ee
using OpenQASM

# ╔═╡ 4afff84d-ceb7-4427-b25b-df9dc2a08cde
using ZXCalculus: BlockIR

# ╔═╡ fdfa8ed2-f19c-4b80-b64e-f4bb22d09327
function Base.show(io::IO, mime::MIME"text/html", zx::Union{ZXDiagram, ZXGraph})
       g = plot(zx)
       Base.show(io, mime, g)
end

# ╔═╡ 227f7884-e99a-11ea-3a90-0beb697a2da6
md"# Construct a ZX diagram"

# ╔═╡ 49d6e6ac-e994-11ea-2ac5-27ab8242e297
z1 = ZXDiagram(4)

# ╔═╡ ba769665-063b-4a17-8aa8-afa1fffc574c
md"""
# Multigraph ZXDigram
"""


# ╔═╡ b9d32b41-8bff-4faa-b198-db096582fb2e
begin
	g = Multigraph([0 1 0; 1 0 1; 0 1 0])
	ps = [Rational(0) for i = 1:3]
	v_t = [SpiderType.X, SpiderType.Z, SpiderType.X]
	zxd_m = ZXDiagram(g, v_t, ps)
end

# ╔═╡ 90b83d5e-e99a-11ea-1fb2-95c907668262
md"# Simplify the ZX diagram"

# ╔═╡ 5dbf9f96-e9a4-11ea-19d7-e15e7f2327c9
tcount(zxd)

# ╔═╡ db9a0d4e-e99e-11ea-22ab-1fead216dd07
zxg = ZXGraph(zxd)

# ╔═╡ 66eb6e1a-e99f-11ea-141c-a9017390524f
md"apply the `lc` rule recursively"

# ╔═╡ ce83c0be-e9a3-11ea-1a40-b1b5118a24bd
html"""
<img src="https://user-images.githubusercontent.com/6257240/91627348-c8151080-e984-11ea-9263-849b2c98d88f.png" width=500/>
"""

# ╔═╡ a6b92942-e99a-11ea-227d-f9fe53f8a1cf
# simplify!(Rule{:lc}(), zxd)  #  this should not pass! use `DRule` and `GRule` to distinguish them?
simplify!(Rule{:lc}(), zxg)  # allow Rule(:lc) for simplicity.

# ╔═╡ 86475062-e99f-11ea-2f44-a3c270cc45e5
md"apply the p1 rule recursively"

# ╔═╡ f59bf644-e9a8-11ea-1944-b3843ef5d6c8
html"""
<img src="https://user-images.githubusercontent.com/6257240/91627385-04e10780-e985-11ea-81c3-d50e057e3795.png" width=600/>
"""

# ╔═╡ b739540e-e99a-11ea-2a04-abd99889cf92
simplify!(Rule{:p1}(), zxg)  # does not have any effect?

# ╔═╡ 7af70558-e9b4-11ea-3aa9-3b73357f0a2a
srule!(sym::Symbol) = g -> simplify!(Rule{sym}(), g)

# ╔═╡ a5784394-e9b4-11ea-0e68-8d8211766409
srule_once!(sym::Symbol) = g -> replace!(Rule{sym}(), g)

# ╔═╡ c6f809e8-e9b4-11ea-2dcb-57c4a1d65bb7
zxg |> srule!(:lc) |> srule!(:p1) |> srule_once!(:pab)

# ╔═╡ 25d876b6-e9a9-11ea-2631-fd6f8934daa6
md"apply the `pab` rule once"

# ╔═╡ 3ce5329a-e9a9-11ea-2c7e-312416dd9483
html"""
<img src="https://user-images.githubusercontent.com/6257240/91627574-5a69e400-e986-11ea-93bf-1d45f09b5967.png" width=600/>
"""

# ╔═╡ bd2b3364-e99a-11ea-06e7-4560cb873d2c
replace!(Rule{:pab}(), zxg)  # this naming is not explict, what about `simplify_recursive!` and `simplily!`.

# ╔═╡ c71cdf4c-e9b5-11ea-2aaf-5f4be0eb3e93
md"## To make life easier"

# ╔═╡ c3e8b5b4-e99a-11ea-0e56-6b18757f94df
md"# Extract circuit"

# ╔═╡ 4f07895a-58aa-4555-aa14-b0526bc1de2d
md"""## ZXDiagrams and Graphs as Matrix
"""


# ╔═╡ 2082486e-e9fd-11ea-1a46-6395b4b34657
md"""
# Porting Yao

We can define a Yao Chain and push gates into the chain

"""

# ╔═╡ 9ba5aa18-9e6b-4f75-a35c-e7a3e548d557
md"""
## Convert BlockIR to ZXDiagram
Create a BlockIR and convert it into a ZXDiagram
"""

# ╔═╡ 4a189a46-9ae6-458c-94c4-7cc8d5dab788
md"""
## Leftover tutorial
"""

# ╔═╡ d341cde4-e9fd-11ea-1c3b-63f35fc648d5
begin
function ZXCalculus.push_gate!(zxd::ZXDiagram, c::AbstractBlock)
	error("Block type `$c` is not supported.")
end
# rotation blocks
function ZXCalculus.push_gate!(zxd::ZXDiagram, c::PutBlock{N,1,RotationGate{1,T,XGate}}) where {N,T}
	push_gate!(zxd, Val(:X), c.locs[1], c.content.theta)
end
function ZXCalculus.push_gate!(zxd::ZXDiagram, c::PutBlock{N,1,RotationGate{1,T,ZGate}}) where {N,T}
	push_gate!(zxd, Val(:Z), c.locs[1], c.content.theta)
end
function ZXCalculus.push_gate!(zxd::ZXDiagram, c::PutBlock{N,1,ShiftGate{T}}) where {N,T}
	push_gate!(zxd, Val(:Z), c.locs[1], c.content.theta)
end
function ZXCalculus.push_gate!(zxd::ZXDiagram, c::PutBlock{N,1,HGate}) where {N}
	push_gate!(zxd, Val(:H), c.locs[1])
end
function ZXCalculus.push_gate!(zxd::ZXDiagram, c::ChainBlock{N}) where {N}
	push_gate!.(Ref(zxd), subblocks(c))
	zxd
end

# constant block
function ZXCalculus.push_gate!(zxd::ZXDiagram, c::PutBlock{N,1,RotationGate{1,T,XGate}}) where {N,T}
	push_gate!(zxd, Val(:X), c.locs[1], c.content.theta)
end
function ZXCalculus.push_gate!(zxd::ZXDiagram, c::PutBlock{N,1,RotationGate{1,T,ZGate}}) where {N,T}
	push_gate!(zxd, Val(:Z), c.locs[1], c.content.theta)
end

# control blocks
function ZXCalculus.push_gate!(zxd::ZXDiagram, c::ControlBlock{N,1,RotationGate{1,T,XGate}}) where {N,T}
	push_gate!(zxd, Val(:X), c.locs[1], c.content.theta)
end
function ZXCalculus.push_gate!(zxd::ZXDiagram, c::ControBlock{N,1,RotationGate{1,T,ZGate}}) where {N,T}
	push_gate!(zxd, Val(:Z), c.locs[1], c.content.theta)
end
function ZXCalculus.push_gate!(zxd::ZXDiagram, c::ControlBlock{N,1,ShiftGate{T}}) where {N,T}
	push_gate!(zxd, Val(:Z), c.locs[1], c.content.theta)
end
end

# ╔═╡ 51e72d20-e994-11ea-1a50-854039f728aa
push_gate!(z1, Val(:Z), 1, 3//2)

# ╔═╡ e1dbb828-e995-11ea-385d-fb20b58d1b49
let
	push_gate!(z1, Val(:H), 1)
	push_gate!(z1, Val(:H), 1)
	push_gate!(z1, Val(:Z), 1, 1//2)
	push_gate!(z1, Val(:H), 4)
	push_gate!(z1, Val(:CZ), 4, 1)
	push_gate!(z1, Val(:CNOT), 1, 4)
end

# ╔═╡ 60c59c0a-e994-11ea-02da-7360cbcf81f7
function load_graph()
	zxd = ZXDiagram(4)
	push_gate!(zxd, Val(:Z), 1, 3//2)
	push_gate!(zxd, Val(:H), 1)
    push_gate!(zxd, Val(:Z), 1, 1//2)
    push_gate!(zxd, Val(:H), 4)
    push_gate!(zxd, Val(:CZ), 4, 1)
    push_gate!(zxd, Val(:CNOT), 1, 4)
    push_gate!(zxd, Val(:H), 1)
    push_gate!(zxd, Val(:H), 4)
    push_gate!(zxd, Val(:Z), 1, 1//4)
    push_gate!(zxd, Val(:Z), 4, 3//2)
    push_gate!(zxd, Val(:X), 4, 1//1)
    push_gate!(zxd, Val(:H), 1)
    push_gate!(zxd, Val(:Z), 4, 1//2)
    push_gate!(zxd, Val(:X), 4, 1//1)
    push_gate!(zxd, Val(:Z), 2, 1//2)
    push_gate!(zxd, Val(:CNOT), 3, 2)
    push_gate!(zxd, Val(:H), 2)
    push_gate!(zxd, Val(:CNOT), 3, 2)
    push_gate!(zxd, Val(:Z), 2, 1//4)
    push_gate!(zxd, Val(:Z), 3, 1//2)
    push_gate!(zxd, Val(:H), 2)
    push_gate!(zxd, Val(:H), 3)
    push_gate!(zxd, Val(:Z), 3, 1//2)
    push_gate!(zxd, Val(:CNOT), 3, 2)
end

# ╔═╡ b6eaa762-e9b5-11ea-145e-7b5fa6b01872
zxd2 = load_graph()

# ╔═╡ 5464bc40-e9b5-11ea-2a2e-dfb0d31a33d3
ex_zxd = clifford_simplification(zxd2)

# ╔═╡ c0f046ea-e9b5-11ea-302c-c5fd4399d400
pt_zxd = phase_teleportation(zxd2)

# ╔═╡ 52c1ae46-a440-4d72-8dc1-fa9903feac80
pt_zxg = ZXGraph(pt_zxd)

# ╔═╡ c1b9828c-e99a-11ea-006a-013a2eab8cf3
chain_simplified = circuit_extraction(pt_zxg)

# ╔═╡ 6ddffea2-e9a4-11ea-1c32-0975a45aba7c
tcount(pt_zxg)

# ╔═╡ a5b21163-7e60-409f-ad59-66ca72375094
Matrix(pt_zxg)

# ╔═╡ b6d6781c-a484-4e69-9bae-eea07a11dc42
Matrix(pt_zxd)

# ╔═╡ d1789ff9-3628-4fd3-aa39-823191e78ee0
begin
	 chain_t = Chain()
	  push_gate!(chain_t, Val(:H), 1)
	  push_gate!(chain_t, Val(:H), 2)
	  push_gate!(chain_t, Val(:X), 3)
	  push_gate!(chain_t, Val(:H), 3)
	  push_gate!(chain_t, Val(:CNOT), 1, 3)
	  push_gate!(chain_t, Val(:X), 1)
	  push_gate!(chain_t, Val(:CNOT), 2, 3)
	  push_gate!(chain_t, Val(:H), 2)
end

# ╔═╡ 71fc6836-3c30-43de-aa2b-2d3d48bdb3da
begin
	  ir_test = @make_ircode begin end
	  bir_test = BlockIR(ir_test, 4, chain_t)
	  zxd_test = convert_to_zxd(bir_test)
end

# ╔═╡ 581e847c-e9fd-11ea-3fd0-6bbc0f6efd56
c = qft_circuit(4)

# ╔═╡ 2e84a5ce-e9fd-11ea-12d0-b3a3dd75a76f
push_gate!(zxd3, c)

# ╔═╡ 7b850816-ea02-11ea-183c-5db2d670be24
ZXDiagram(4) |> typeof

# ╔═╡ ee87ca39-5b1a-4b3c-96ad-ee0df2833cd5
md"""
## Create ZXDiagram from QASM
"""

# ╔═╡ 217d328b-58c6-4ff9-8e13-6a59b8889f2f


# ╔═╡ 64cb0092-d364-48b7-9514-a2b5c80701be
begin
	qasm_o = """
	  OPENQASM 2.0;
	  include "qelib1.inc";
	  qreg q0[3];
	  creg c0[2];
	  h q0[0];
	  h q0[1];
	  x q0[2];
	  h q0[2];
	  CX q0[0], q0[2];
	  h q0[0];
	  measure q0[0] -> c0[0];
	  CX q0[1], q0[2];
	  h q0[1];
	  measure q0[1] -> c0[1];
	  """

	qasm_t = """
	OPENQASM 2.0;
 	include "qelib1.inc";
 	qreg q0[3];
  	creg mcm[1];
 	creg end[1];
  	h q0[1];
 	x q0[2];
 	h q0[2];
	CX q0[1],q0[2];
 	h q0[1];
	measure q0[1] -> mcm[0];
 	h q0[0];
  	CX q0[0],q0[2];
  	h q0[0];
 	measure q0[0] -> end[0];
	"""
	
	  ast_o = OpenQASM.parse(qasm_o)
	  bir_o = BlockIR(ast_o)
	  ast_t = OpenQASM.parse(qasm_t)
	  bir_t = BlockIR(ast_t)
	
end

# ╔═╡ a470d83b-c538-4a51-96c5-b957460d6023
    zxd_o = ZXDiagram(bir_o)

# ╔═╡ 960e80b3-efaf-4c49-b2c6-4849dd0a0ef4
begin
	zxd_t = ZXDiagram(bir_t)
	push_gate!(zxd_t, Val{:SWAP}(), [1, 2])
	
end

# ╔═╡ 31753c83-847a-4c2a-a6b3-8be6aaa8f792
zxg_t = ZXGraph(zxd_t)

# ╔═╡ 77afd45a-47e1-4cab-a731-3298351b693d
zxwd_o = convert_to_zxwd(bir_o)

# ╔═╡ 4b54309c-c3e8-402c-a74f-acbdfc3ef046
zxwd_t = convert_to_zxwd(bir_t)

# ╔═╡ 553b216e-2180-475f-928c-eda378b6acae


# ╔═╡ 1b373f50-92bf-4552-b829-1d9959a9885b
m_o = Matrix(zxwd_o)

# ╔═╡ 92965f5c-14b4-4e28-aff0-54aa476e948d
m_t = Matrix(zxwd_t)

# ╔═╡ 7cf94474-213d-4c8e-96f1-1781023718fb
m_o ≈ m_t

# ╔═╡ Cell order:
# ╠═8ab9b70a-e98d-11ea-239c-73dc659722c2
# ╠═512ac070-335e-45e9-a75d-e689af3ea59d
# ╠═fdfa8ed2-f19c-4b80-b64e-f4bb22d09327
# ╟─227f7884-e99a-11ea-3a90-0beb697a2da6
# ╠═49d6e6ac-e994-11ea-2ac5-27ab8242e297
# ╠═51e72d20-e994-11ea-1a50-854039f728aa
# ╠═e1dbb828-e995-11ea-385d-fb20b58d1b49
# ╠═60c59c0a-e994-11ea-02da-7360cbcf81f7
# ╟─ba769665-063b-4a17-8aa8-afa1fffc574c
# ╠═a9bf8e31-686a-4057-acec-bd04e8b5a3dc
# ╠═b9d32b41-8bff-4faa-b198-db096582fb2e
# ╟─90b83d5e-e99a-11ea-1fb2-95c907668262
# ╠═5dbf9f96-e9a4-11ea-19d7-e15e7f2327c9
# ╠═db9a0d4e-e99e-11ea-22ab-1fead216dd07
# ╟─66eb6e1a-e99f-11ea-141c-a9017390524f
# ╟─ce83c0be-e9a3-11ea-1a40-b1b5118a24bd
# ╠═a6b92942-e99a-11ea-227d-f9fe53f8a1cf
# ╟─86475062-e99f-11ea-2f44-a3c270cc45e5
# ╟─f59bf644-e9a8-11ea-1944-b3843ef5d6c8
# ╠═b739540e-e99a-11ea-2a04-abd99889cf92
# ╠═7af70558-e9b4-11ea-3aa9-3b73357f0a2a
# ╠═a5784394-e9b4-11ea-0e68-8d8211766409
# ╠═c6f809e8-e9b4-11ea-2dcb-57c4a1d65bb7
# ╟─25d876b6-e9a9-11ea-2631-fd6f8934daa6
# ╟─3ce5329a-e9a9-11ea-2c7e-312416dd9483
# ╠═bd2b3364-e99a-11ea-06e7-4560cb873d2c
# ╟─c71cdf4c-e9b5-11ea-2aaf-5f4be0eb3e93
# ╠═b6eaa762-e9b5-11ea-145e-7b5fa6b01872
# ╠═5464bc40-e9b5-11ea-2a2e-dfb0d31a33d3
# ╠═c0f046ea-e9b5-11ea-302c-c5fd4399d400
# ╠═52c1ae46-a440-4d72-8dc1-fa9903feac80
# ╟─c3e8b5b4-e99a-11ea-0e56-6b18757f94df
# ╠═c1b9828c-e99a-11ea-006a-013a2eab8cf3
# ╠═6ddffea2-e9a4-11ea-1c32-0975a45aba7c
# ╟─4f07895a-58aa-4555-aa14-b0526bc1de2d
# ╠═b6d6781c-a484-4e69-9bae-eea07a11dc42
# ╠═a5b21163-7e60-409f-ad59-66ca72375094
# ╟─2082486e-e9fd-11ea-1a46-6395b4b34657
# ╠═d1789ff9-3628-4fd3-aa39-823191e78ee0
# ╟─9ba5aa18-9e6b-4f75-a35c-e7a3e548d557
# ╠═71fc6836-3c30-43de-aa2b-2d3d48bdb3da
# ╠═31753c83-847a-4c2a-a6b3-8be6aaa8f792
# ╟─4a189a46-9ae6-458c-94c4-7cc8d5dab788
# ╠═d341cde4-e9fd-11ea-1c3b-63f35fc648d5
# ╠═581e847c-e9fd-11ea-3fd0-6bbc0f6efd56
# ╠═2e84a5ce-e9fd-11ea-12d0-b3a3dd75a76f
# ╠═7b850816-ea02-11ea-183c-5db2d670be24
# ╠═ee87ca39-5b1a-4b3c-96ad-ee0df2833cd5
# ╠═0378329e-819e-4c70-b543-33d47f6455ee
# ╠═217d328b-58c6-4ff9-8e13-6a59b8889f2f
# ╠═4afff84d-ceb7-4427-b25b-df9dc2a08cde
# ╠═64cb0092-d364-48b7-9514-a2b5c80701be
# ╠═a470d83b-c538-4a51-96c5-b957460d6023
# ╠═960e80b3-efaf-4c49-b2c6-4849dd0a0ef4
# ╠═77afd45a-47e1-4cab-a731-3298351b693d
# ╠═4b54309c-c3e8-402c-a74f-acbdfc3ef046
# ╠═553b216e-2180-475f-928c-eda378b6acae
# ╠═1b373f50-92bf-4552-b829-1d9959a9885b
# ╠═92965f5c-14b4-4e28-aff0-54aa476e948d
# ╠═7cf94474-213d-4c8e-96f1-1781023718fb
