extends Node3D


func _on_tree_exited() -> void:
	Utils.free_orphaned_nodes()
	print("ORPHAN NODES")
	#print_orphan_nodes()
