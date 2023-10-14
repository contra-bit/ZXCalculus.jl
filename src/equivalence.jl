"""
    verify_equality(zxd_1::ZXDiagram, zxd_2::ZXDiagram)

checks the equivalence of two different ZXDiagrams


"""
# TODO reimplement dagger and concat! as per ZXW
function verify_equality(zxd_1::ZXDiagram, zxd_2::ZXDiagram)
  merged_diagram = concat!(zxd_1, dagger(zxd_2))
  m_simple = full_reduction(merged_diagram)
  contains_only_bare_wires(m_simple)
end

function create_gate_from_v(zxd_new, zxd_old, vs)
  if length(vs) == 1
    v = vs
    q = Int(qubit_loc(zxd_old, v))
    p = phase(zxd_old, v)
    st = spider_type(zxd_old, v)
    # Return if gate is nothing
    if !(st == SpiderType.In || st == SpiderType.Out)
      gate_val = stype_to_val(st)
      if st == SpiderType.H
        gate_val !== nothing && push_gate!(zxd_new, gate_val, q)
      else
        gate_val !== nothing && push_gate!(zxd_new, gate_val, q, p)
      end
    end


  elseif length(vs) == 2
    v1, v2 = vs
    q1 = Int(qubit_loc(zxd_old, v1))
    q2 = Int(qubit_loc(zxd_old, v2))

    p1 = phase(zxd_old, v1)
    p2 = phase(zxd_old, v2)

    st1 = spider_type(zxd_old, v1)
    if (st1 == SpiderType.In || st1 == SpiderType.Out)
      gate_val1 = stype_to_val(st1)
      if gate_val1 !== nothing
        if st1 == SpiderType.H
          push_gate!(zxd_new, gate_val1, q1)
        else
          push_gate!(zxd_new, gate_val1, q1, p1)
        end
      end
    end

    st2 = spider_type(zxd_old, v2)
    if (st1 == SpiderType.In || st1 == SpiderType.Out)
      gate_val2 = stype_to_val(st2)
      if gate_val2 !== nothing
        if st2 == SpiderType.H
          push_gate!(zxd_new, gate_val2, q2)
        else
          push_gate!(zxd_new, gate_val2, q2, p2)
        end
      end
    end
  end
end

