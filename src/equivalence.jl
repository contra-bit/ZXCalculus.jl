
function equivalence(zxd_1::ZXDiagram, zxd_2::ZXDiagram)
  merged_diagram = append_adjoint_diagram!(zxd_1, zxd_2)
  m_simple = full_reduction(merged_diagram)
  contains_only_bare_wires(m_simple)
end

function append_adjoint_diagram!(zxd_1::AbstractZXDiagram, zxd_2::AbstractZXDiagram)::AbstractZXDiagram
  q = nqubits(zxd_1)
  q == nqubits(zxd_2) || throw(ArgumentError("number of qubits need to be equal, go $q and $(nqubits(zxd_2))"))
  zxd_new = ZXDiagram(q)
  for vs in zip(spider_sequence(zxd_1), spider_sequence(zxd_2))
    create_inverse_gate_from_v(zxd_new, zxd_1, vs[1])
    create_gate_from_v(zxd_new, zxd_1, vs[2])
  end
  zxd_new
end

#function equivalence(zxd_1, zxd_2)
#  m1 = full_reduction(zxd_1)
#  m2 = full_reduction(zxd_2)
#  m_dagger = ZXCalculus.append_adjoint_diagram!(m1, m2)
#  contains_only_bare_wires(m_dagger)
#end
#
