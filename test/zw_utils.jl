using ZXCalculus.ZW:
    ZWDiagram,
    spider_type,
    set_phase!,
    parameter,
    nin,
    nout,
    nqubits,
    nv,
    ne,
    degree,
    indegree,
    outdegree,
    outneighbors,
    inneighbors,
    neighbors,
    spiders,
    scalar,
    get_inputs,
    get_outputs,
    get_input_idx,
    get_output_idx,
    add_power!,
    add_global_phase!,
    insert_spider!,
    neighbors
using ZXCalculus: trace_vertex
using ZXCalculus.ZXW: Parameter

@testset "utils" begin
    zw = ZWDiagram(3)

    @test spider_type(zw, 1) == ZW.Input(1)
    @test parameter(zw, 2) == 1
    @test nqubits(zw) == 3
    @test nin(zw) == 3
    @test nout(zw) == 3
    @test nv(zw) == 6
    @test ne(zw) == 7
    @test sort(outneighbors(zw, 1)) == [2, 3]
    @test sort(inneighbors(zw, 1)) == [2, 3]
    @test sort(neighbors(zw, 3)) == [1, 4, 5]
    @test degree(zw, 1) == 2
    @test indegree(zw, 1) == 2
    @test outdegree(zw, 1) == 2

    @test sort(spiders(zw)) == [1, 2, 3, 4, 5, 6]
    @test sort(get_inputs(zw)) == [1, 3, 5]
    @test sort(get_outputs(zw)) == [2, 4, 6]

    @test get_input_idx(zw, 2) == 3
    @test get_output_idx(zw, 2) == 4

    sc = scalar(zw)
    @test sc == Scalar{Rational}()
    add_power!(zw, 2)
    add_global_phase!(zw, 1 // 2)
    sc = scalar(zw)
    @test sc == Scalar{Rational}(2, 1 // 2)

    # TODO
    # set_phase!
end

@testset "Add and Spiders" begin

    zw = ZWDiagram(3)

    pmg2 = PlanarMultigraph(
        Dict(1 => 1, 7 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 6, 2 => 15),
        Dict(
            1 => HalfEdge(1, 7),
            2 => HalfEdge(7, 1),
            3 => HalfEdge(3, 4),
            4 => HalfEdge(4, 3),
            5 => HalfEdge(5, 6),
            6 => HalfEdge(6, 5),
            7 => HalfEdge(3, 1),
            8 => HalfEdge(1, 3),
            9 => HalfEdge(5, 3),
            10 => HalfEdge(3, 5),
            11 => HalfEdge(4, 2),
            12 => HalfEdge(2, 4),
            13 => HalfEdge(6, 4),
            14 => HalfEdge(4, 6),
            15 => HalfEdge(7, 2),
            16 => HalfEdge(2, 7),
        ),
        Dict(0 => 2, 1 => 1, 3 => 3),
        Dict(
            1 => 1,
            16 => 0,
            12 => 1,
            4 => 1,
            7 => 1,
            3 => 2,
            14 => 2,
            6 => 2,
            9 => 2,
            2 => 0,
            15 => 1,
            11 => 0,
            5 => 0,
            8 => 0,
            13 => 0,
            10 => 0,
        ),
        Dict(
            1 => 15,
            15 => 12,
            12 => 4,
            4 => 7,
            7 => 1,
            3 => 14,
            14 => 6,
            6 => 9,
            9 => 3,
            2 => 8,
            8 => 10,
            10 => 5,
            5 => 13,
            13 => 11,
            11 => 16,
            16 => 2,
        ),
        Dict(
            1 => 2,
            2 => 1,
            3 => 4,
            4 => 3,
            5 => 6,
            6 => 5,
            7 => 8,
            8 => 7,
            9 => 10,
            10 => 9,
            11 => 12,
            12 => 11,
            13 => 14,
            14 => 13,
            15 => 16,
            16 => 15,
        ),
        7,
        16,
        3,
        [0],
    )

    insert_spider!(zw, 12, ZW.binZ(Parameter(Val(:Factor), 2.0)))
    @test zw.pmg == pmg2

    set_phase!(zw, 7, Parameter(Val(:PiUnit), 1))
    @test zw.st[7] == ZW.binZ(Parameter(Val(:PiUnit), 1))
end
