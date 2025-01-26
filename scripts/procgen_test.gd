@tool
extends MeshInstance3D


const EPSILON: float = 0.01


func _ready() -> void:
	var st := SurfaceTool.new()

	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for i in 10:
		st.add_vertex(Vector3.ZERO)
		st.add_vertex(Vector3.RIGHT)
		st.add_vertex(Vector3.DOWN)

		st.add_vertex(Vector3.DOWN)
		st.add_vertex(Vector3.RIGHT + Vector3.UP * randf_range(0, 1))
		st.add_vertex(Vector3.RIGHT * 2 + Vector3.DOWN)

		st.add_vertex(Vector3.RIGHT * 2 + Vector3.DOWN)
		st.add_vertex(Vector3.RIGHT)
		st.add_vertex(Vector3.RIGHT * 2 + Vector3.UP * randf_range(0, 1))

	mesh = st.commit()
