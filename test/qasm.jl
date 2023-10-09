
@testset "convert simple qasm file into BlockIR" begin

  qasm = """
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


  bir = BlockIR(qasm)



  @testset "correct parsing" begin
    bir !== nothing
  end

  @testset "convert into ZXDiagram" begin
    zxd = ZXDiagram(bir)
    @test zxd !== nothing
  end


  @testset "matrix from zxd" begin
    # TODO Fix matrix from ZXDiagram
    #  m = Matrix(zxd)
  end

  zxwd = convert_to_zxwd(bir)

  @testset "convert into ZXWDiagram" begin
    @test zxwd !== nothing
  end

  @testset "matrix from zxwd" begin
    m = Matrix(zxwd)
  end

  @testset "plot new ZXDiagram" begin
    @test plot(zxd) !== nothing
  end


  chain = Chain()
  push_gate!(chain, Val(:H), 1)
  push_gate!(chain, Val(:H), 2)
  push_gate!(chain, Val(:X), 3)
  push_gate!(chain, Val(:H), 3)
  push_gate!(chain, Val(:CNOT), 1, 3)
  push_gate!(chain, Val(:H), 1)
  push_gate!(chain, Val(:CNOT), 2, 3)
  push_gate!(chain, Val(:H), 1)

  @testset "conversion" begin
    #    @test chain == bir.circuit
  end



end


@testset "parse DJ-NAND" begin
  bv = BlockIR("""
  OPENQASM 2.0;
  include "qelib1.inc";
  qreg q[3];
  creg c[2];
  h q[0];
  h q[1];
  x q[2];
  h q[2];
  x q[2];
  h q[2];
  cx q[1],q[2];
  tdg q[2];
  cx q[0],q[2];
  t q[2];
  cx q[1],q[2];
  t q[1];
  tdg q[2];
  cx q[0],q[2];
  cx q[0],q[1];
  t q[0];
  tdg q[1];
  cx q[0],q[1];
  h q[0];
  h q[1];
  t q[2];
  h q[2];
  measure q[0] -> c[0];
  measure q[1] -> c[1];
  """)


  @testset "correct parsing" begin
   @test bv !== nothing
  end

  @testset "convert into ZXDiagram" begin
    zxd = ZXDiagram(bv)
    @test zxd !== nothing
  end


end
