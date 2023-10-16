zxd1 = ZXDiagram(2)

pushfirst_gate!(zxd1, Val(:X), 1)
pushfirst_gate!(zxd1, Val(:H), 1)
pushfirst_gate!(zxd1, Val(:CNOT), 2, 1)
pushfirst_gate!(zxd1, Val(:CZ), 1, 2)

zxd2 = copy(zxd1)
pushfirst_gate!(zxd1, Val(:X), 1)

@test verify_equality(zxd1, zxd2) == false
@test verify_equality(zxd1, zxd1) == true
