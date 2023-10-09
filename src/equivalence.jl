
"""
    equivalence(zxd_1::ZXDiagram, zxd_2::ZXDiagram)

checks the equivalence of two different ZXDiagrams
"""
function equivalence(zxd_1::ZXDiagram, zxd_2::ZXDiagram)
  merged_diagram = append_adjoint_diagram!(zxd_1, zxd_2)
  m_simple = full_reduction(merged_diagram)
  contains_only_bare_wires(m_simple)
end

"""
    append_adjoint_diagram!(zxd_1::AbstractZXDiagram, zxd_2::AbstractZXDiagram)::AbstractZXDiagram

Appends two diagrams, where the second diagram is inverted
"""
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

function invert_phases!(zxd::AbstractZXDiagram)
  ps = zxd.ps
  for v in keys(ps)
    set_phase!(zxd, v, rem(ps[v] + 1, 2))
  end
  zxd
end


function stype_to_val(st)
  if st == SpiderType.Z
    Val{:Z}()
  elseif st == SpiderType.X
    Val{:X}()
  elseif st == SpiderType.H
    Val{:H}()
  else
    throw(ArgumentError("$st has no corresponding SpiderType"))
  end
end


function invert_phase!(zxd, v)
  -phase(zxd, v)
end


function create_gate_from_v(zxd_new, zxd_old, vs)
  if length(vs) == 1
    v = vs
    q = Int(qubit_loc(zxd_old, v))
    p = phase(zxd_old, v)
    st = spider_type(zxd_old, v)
    gate_val = stype_to_val(st)
    if st == SpiderType.H
      gate_val !== nothing && push_gate!(zxd_new, gate_val, q)
    else
      gate_val !== nothing && push_gate!(zxd_new, gate_val, q, p)
    end


  elseif length(vs) == 2
    v1, v2 = vs
    q1 = Int(qubit_loc(zxd_old, v1))
    q2 = Int(qubit_loc(zxd_old, v2))
    st1 = spider_type(zxd_old, v1)
    gate_val1 = stype_to_val(st1)
    st2 = spider_type(zxd_old, v2)
    gate_val2 = stype_to_val(st2)
    p1 = phase(zxd_old, v1)
    p2 = phase(zxd_old, v2)
    if gate_val1 !== nothing
      if st1 == SpiderType.H
        push_gate!(zxd_new, gate_val1, q1)
      else
        push_gate!(zxd_new, gate_val1, q1, p1)
      end
    end
    if gate_val2 !== nothing
      if st2 == SpiderType.H
        push_gate!(zxd_new, gate_val2, q2)
      else
        push_gate!(zxd_new, gate_val2, q2, p2)
      end
    end
  end
end

function create_inverse_gate_from_v(zxd_new, zxd_old, vs)
  if length(vs) == 1
    v = vs
    q = Int(qubit_loc(zxd_old, v))
    p_inv = invert_phase!(zxd_old, v)
    st = spider_type(zxd_old, v)
    gate_val = stype_to_val(st)
    if st == SpiderType.H
      gate_val !== nothing && push_gate!(zxd_new, gate_val, q)
    else
      gate_val !== nothing && push_gate!(zxd_new, gate_val, q, p_inv)
    end


  elseif length(vs) == 2
    v1, v2 = vs
    q1 = Int(qubit_loc(zxd_old, v1))
    q2 = Int(qubit_loc(zxd_old, v2))
    st1 = spider_type(zxd_old, v1)
    gate_val1 = stype_to_val(st1)
    st2 = spider_type(zxd_old, v2)
    gate_val2 = stype_to_val(st2)
    p1 = invert_phase!(zxd_old, v1)
    p2 = invert_phase!(zxd_old, v2)
    if gate_val1 !== nothing
      if st1 == SpiderType.H
        push_gate!(zxd_new, gate_val1, q1)
      else
        push_gate!(zxd_new, gate_val1, q1, p1)
      end
    end
    if gate_val2 !== nothing
      if st2 == SpiderType.H
        push_gate!(zxd_new, gate_val2, q2)
      else
        push_gate!(zxd_new, gate_val2, q2, p2)
      end
    end
  end
end

