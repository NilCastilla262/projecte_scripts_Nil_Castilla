from BD import connect, insertRow, selectALL, updateRow, deleteRow, close

connexio=connect()

"""
result=BD.insertRow(connexio, ["PC1", "172.19.1.15"])
if result == 1:
    print(f"Insert {result} row(s)")
else:
    print(f"Error: {result}")

result=BD.updateRow(connexio, "172.19.1.15", "PC2")

result=BD.deleteRow(connexio, "172.19.1.15")

result = BD.selectALL(connexio)
BD.imprimir(result)
"""
close(connexio)