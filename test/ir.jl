using Test
using ZXCalculus.ZXW
using ZXCalculus, ZXCalculus.ZX, ZXCalculus.Utils
using YaoHIR, YaoLocations
using Core.Compiler: IRCode

chain = Chain()
push_gate!(chain, Val(:Sdag), 1)
push_gate!(chain, Val(:Z), 1)
push_gate!(chain, Val(:H), 1)
push_gate!(chain, Val(:S), 1)
push_gate!(chain, Val(:S), 2)
push_gate!(chain, Val(:H), 4)
push_gate!(chain, Val(:CNOT), 3, 2)
push_gate!(chain, Val(:CZ), 4, 1)
push_gate!(chain, Val(:H), 2)
push_gate!(chain, Val(:T), 2)
push_gate!(chain, Val(:CNOT), 3, 2)
push_gate!(chain, Val(:Tdag), 2)
push_gate!(chain, Val(:CNOT), 1, 4)
push_gate!(chain, Val(:H), 1)
push_gate!(chain, Val(:T), 2)
push_gate!(chain, Val(:S), 3)
push_gate!(chain, Val(:H), 4)
push_gate!(chain, Val(:T), 1)
push_gate!(chain, Val(:T), 2)
push_gate!(chain, Val(:T), 3)
push_gate!(chain, Val(:X), 3)
push_gate!(chain, Val(:H), 2)
push_gate!(chain, Val(:H), 3)
push_gate!(chain, Val(:Sdag), 4)
push_gate!(chain, Val(:S), 3)
push_gate!(chain, Val(:X), 4)
push_gate!(chain, Val(:CNOT), 3, 2)
push_gate!(chain, Val(:H), 1)
push_gate!(chain, Val(:shift), 4, Phase(1 // 2))
push_gate!(chain, Val(:Rx), 4, Phase(1 // 1))
push_gate!(chain, Val(:Rx), 3, Phase(1 // 4))
push_gate!(chain, Val(:Rx), 2, Phase(1 // 4))
push_gate!(chain, Val(:S), 3)


@testset "ir.jl" begin
    # Shadow operation in ir.jl testset, so that they do not overrride SpiderTypes
    X = YaoHIR.IntrinsicOperation.X
    Z = YaoHIR.IntrinsicOperation.Z
    H = YaoHIR.IntrinsicOperation.H
    T = YaoHIR.IntrinsicOperation.T
    S = YaoHIR.IntrinsicOperation.S
    SGate = YaoHIR.IntrinsicOperation.SGate



    ir = IRCode()
    bir = BlockIR(ir, 4, chain)
    zxd = ZXDiagram(bir)
    zxwd = ZXWDiagram(bir)


    @testset "Chain of ZXDiagram" begin
        # @test chain == Chain(ZXDiagram(bir))
        # FIXME add better equal for Chain
        @test Chain(zxd) !== nothing
    end

    @testset "convert BlockIR into ZXWDiagram" begin
        @test zxwd !== nothing
    end


    @testset "create Matrix from ZXDiagram" begin
        matrix_from_zxd =
            Matrix(ZXWDiagram(BlockIR(IRCode(), 4, circuit_extraction(full_reduction(zxd)))))
        @test matrix_from_zxd !== nothing
    end



    @testset "BlockIR to Matrix" begin
        @test Matrix(zxwd) !== nothing
    end

    @test plot(zxd) !== nothing
    convert_to_chain(zxd)
    pt_zxd = phase_teleportation(zxd)
    @test tcount(pt_zxd) <= tcount(zxd)
    pt_chain = convert_to_chain(pt_zxd)
    @test length(pt_chain) <= length(chain)

    zxg = clifford_simplification(zxd)
    @test plot(zxg) !== nothing
    cl_chain = circuit_extraction(zxg)

    zxg = full_reduction(zxd)
    @test plot(zxg) !== nothing
    fl_chain = circuit_extraction(zxg)
    ZX.generate_layout!(zxg)
    @test ZX.qubit_loc(zxg, 40) == 0 // 1
    ZX.spider_sequence(zxg)

    pt_bir = phase_teleportation(bir)
    cl_bir = clifford_simplification(bir)
    fl_bir = full_reduction(bir)

    @test length(pt_chain) == length(pt_bir.circuit)
    @test length(cl_chain) == length(cl_bir.circuit)
    @test length(fl_chain) == length(fl_bir.circuit)

    @testset "issue#80" begin
        ir = IRCode()
        circuit = Chain(Gate(X, Locations(1)), Gate(X, Locations(1)))
        bir = BlockIR(ir, 1, circuit)
        bir = clifford_simplification(bir)
        bir = clifford_simplification(bir)
        @test bir.circuit == Chain(Gate(H, Locations((1,))), Gate(H, Locations((1,))))
    end

    @testset "generate_layout!" begin

        circ = Chain(
            Gate(H, Locations(2)),
            Gate(T, Locations(4)),
            Gate(H, Locations(1)),
            Gate(AdjointOperation{SGate}(S), Locations(2)),
            Gate(H, Locations(2)),
            Gate(X, Locations(3)),
            Gate(AdjointOperation{SGate}(S), Locations(1)),
            Gate(Z, Locations(1)),
            Gate(H, Locations(2)),
            Gate(X, Locations(1)),
            Gate(Z, Locations(1)),
            Gate(T, Locations(5)),
            Ctrl(Gate(X, Locations(5)), CtrlLocations(1)),
            Gate(H, Locations(1)),
            Gate(T, Locations(1)),
            Ctrl(Gate(X, Locations(3)), CtrlLocations(5)),
            Gate(H, Locations(1)),
            Gate(X, Locations(4)),
            Ctrl(Gate(X, Locations(5)), CtrlLocations(4)),
            Gate(S, Locations(2)),
            Ctrl(Gate(X, Locations(1)), CtrlLocations(3)),
            Gate(X, Locations(2)),
            Ctrl(Gate(X, Locations(3)), CtrlLocations(1)),
            Gate(X, Locations(2)),
            Gate(S, Locations(3)),
            Gate(Z, Locations(2)),
            Gate(Z, Locations(5)),
            Gate(X, Locations(2)),
            Gate(X, Locations(1)),
            Ctrl(Gate(X, Locations(3)), CtrlLocations(5)),
            Gate(S, Locations(4)),
            Gate(X, Locations(3)),
            Ctrl(Gate(X, Locations(1)), CtrlLocations(2)),
            Gate(AdjointOperation{SGate}(S), Locations(4)),
            Gate(Z, Locations(2)),
            Gate(AdjointOperation{SGate}(S), Locations(5)),
            Ctrl(Gate(X, Locations(1)), CtrlLocations(2)),
            Gate(Z, Locations(5)),
            Ctrl(Gate(X, Locations(1)), CtrlLocations(4)),
            Ctrl(Gate(X, Locations(3)), CtrlLocations(4)),
            Gate(H, Locations(4)),
            Gate(Z, Locations(1)),
            Gate(X, Locations(4)),
            Gate(Z, Locations(3)),
            Gate(H, Locations(4)),
            Ctrl(Gate(X, Locations(1)), CtrlLocations(4)),
            Ctrl(Gate(X, Locations(4)), CtrlLocations(1)),
            Gate(X, Locations(4)),
            Gate(S, Locations(3)),
            Gate(AdjointOperation{SGate}(S), Locations(2)),
            Gate(Z, Locations(3)),
            Gate(S, Locations(5)),
            Ctrl(Gate(X, Locations(3)), CtrlLocations(5)),
            Gate(H, Locations(2)),
            Gate(Z, Locations(4)),
            Gate(H, Locations(1)),
            Gate(X, Locations(1)),
            Gate(X, Locations(2)),
            Ctrl(Gate(X, Locations(5)), CtrlLocations(3)),
            Ctrl(Gate(X, Locations(1)), CtrlLocations(3)),
            Gate(Z, Locations(4)),
            Gate(S, Locations(5)),
            Gate(S, Locations(5)),
            Ctrl(Gate(X, Locations(5)), CtrlLocations(1)),
            Gate(T, Locations(4)),
            Gate(Z, Locations(2)),
            Gate(X, Locations(4)),
            Gate(H, Locations(2)),
            Gate(AdjointOperation{SGate}(S), Locations(3)),
            Gate(H, Locations(5)),
            Gate(T, Locations(2)),
            Gate(AdjointOperation{SGate}(S), Locations(5)),
            Gate(AdjointOperation{SGate}(S), Locations(4)),
            Gate(H, Locations(2)),
            Gate(S, Locations(2)),
            Gate(AdjointOperation{SGate}(S), Locations(3)),
            Ctrl(Gate(X, Locations(5)), CtrlLocations(1)),
            Gate(H, Locations(5)),
            Ctrl(Gate(X, Locations(4)), CtrlLocations(3)),
            Gate(H, Locations(4)),
            Gate(Z, Locations(2)),
            Gate(H, Locations(2)),
            Gate(S, Locations(2)),
            Gate(H, Locations(4)),
            Ctrl(Gate(X, Locations(1)), CtrlLocations(2)),
            Gate(X, Locations(4)),
            Gate(H, Locations(1)),
            Gate(AdjointOperation{SGate}(S), Locations(5)),
            Gate(X, Locations(1)),
            Gate(X, Locations(3)),
            Gate(Z, Locations(1)),
            Ctrl(Gate(X, Locations(1)), CtrlLocations(2)),
            Gate(T, Locations(3)),
            Gate(X, Locations(4)),
            Gate(X, Locations(3)),
            Gate(AdjointOperation{SGate}(S), Locations(1)),
            Gate(AdjointOperation{SGate}(S), Locations(3)),
            Gate(H, Locations(5)),
            Gate(S, Locations(4)),
            Gate(Z, Locations(4)),
        )
        ir = IRCode()
        bir = BlockIR(ir, 5, circ)
        zxd = ZXDiagram(bir)
        zxg = ZXGraph(zxd)
        full_reduction(zxg)
        ZX.generate_layout!(zxg)
        @test plot(zxg) !== nothing
        @test ZX.generate_layout!(zxg) !== nothing
    end

    function random_circuit(nbits, ngates; T = 0.1, CZ = 0.0, CNOT = 0.1)
        ir = IRCode()
        CLIFF = 1 - T - CZ - CNOT
        circ = Chain()
        for _ = 1:ngates
            x = rand()
            nbits == 1 && (x = x * (CLIFF + T))
            if x <= CLIFF
                g = rand([:X, :X, :Z, :Z, :S, :Sdag, :H, :H])
                push_gate!(circ, Val(g), rand(1:nbits))
            elseif x - CLIFF <= T
                g = rand([:T, :Tdag])
                push_gate!(circ, Val(g), rand(1:nbits))
            elseif x - CLIFF - T <= CZ
                loc = rand(1:nbits)
                ctrl = loc
                while ctrl == loc
                    ctrl = rand(1:nbits)
                end
                push_gate!(circ, Val(:CZ), loc, ctrl)
            else
                loc = rand(1:nbits)
                ctrl = loc
                while ctrl == loc
                    ctrl = rand(1:nbits)
                end
                push_gate!(circ, Val(:CNOT), loc, ctrl)
            end
        end
        return BlockIR(ir, nbits, circ)
    end

    function random_identity(nbits, ngates; T = 0.1, CZ = 0.0, CNOT = 0.1)
        bir = random_circuit(nbits, ngates; T = T, CZ = CZ, CNOT = CNOT)
        c = bir.circuit.args
        for i = length(c):-1:1
            if c[i] isa Gate
                g = c[i].operation
                if (g in (YaoHIR.IntrinsicOperation.S, YaoHIR.IntrinsicOperation.T)) ||
                   (g isa AdjointOperation)
                    push!(c, Gate(g', c[i].locations))
                else
                    push!(c, c[i])
                end
            else
                push!(c, c[i])
            end
        end
        return bir
    end

    @testset "plot random_identity" begin
        circ = random_identity(5, 50)
        zxd = convert_to_zxd(circ)
        @test plot(zxd) !== nothing
        zxg = ZXGraph(zxd)
        @test plot(zxg) !== nothing
        @test plot(zxg |> clifford_simplification |> full_reduction) !== nothing
    end
end
