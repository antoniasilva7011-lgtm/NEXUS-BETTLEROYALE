extends Node3D

const PLAYER_SPEED := 7.0
const TURN_SPEED := 2.4
var move_flags := {"forward": false, "back": false, "left": false, "right": false}
var player: CharacterBody3D
var status_label: Label
var targets: Array[Node3D] = []
var shots := 0

func _ready() -> void:
	_build_world()
	_build_player()
	_build_hud()

func _build_world() -> void:
	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = Sky.new()
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.68, 0.76, 0.88)
	env.ambient_light_energy = 0.8
	world_env.environment = env
	add_child(world_env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -25, 0)
	sun.light_energy = 1.4
	add_child(sun)
	var ground := StaticBody3D.new()
	var ground_mesh := MeshInstance3D.new()
	var plane := BoxMesh.new()
	plane.size = Vector3(100, 1, 100)
	ground_mesh.mesh = plane
	var grass := StandardMaterial3D.new()
	grass.albedo_color = Color(0.18, 0.32, 0.22)
	ground_mesh.material_override = grass
	ground.add_child(ground_mesh)
	var ground_collision := CollisionShape3D.new()
	var ground_shape := BoxShape3D.new()
	ground_shape.size = plane.size
	ground_collision.shape = ground_shape
	ground_collision.position.y = -0.5
	ground.add_child(ground_collision)
	ground.position.y = -0.5
	add_child(ground)
	for i in range(12):
		var obstacle := StaticBody3D.new()
		var mesh := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(2.5, 2.2, 2.5)
		mesh.mesh = box
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.28, 0.34, 0.39)
		mesh.material_override = mat
		obstacle.add_child(mesh)
		var col := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = box.size
		col.shape = shape
		obstacle.add_child(col)
		obstacle.position = Vector3(cos(float(i) * 0.8) * 12.0, 1.1, sin(float(i) * 0.8) * 12.0)
		add_child(obstacle)
	for i in range(5):
		var target := MeshInstance3D.new()
		var capsule := CapsuleMesh.new()
		capsule.radius = 0.65
		capsule.height = 2.0
		target.mesh = capsule
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.85, 0.2, 0.16)
		target.material_override = mat
		target.position = Vector3(-8 + i * 4, 1.0, -18)
		add_child(target)
		targets.append(target)

func _build_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Player"
	var body_mesh := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.45
	capsule.height = 1.8
	body_mesh.mesh = capsule
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.12, 0.68, 0.92)
	body_mesh.material_override = mat
	player.add_child(body_mesh)
	var col := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.45
	shape.height = 1.8
	col.shape = shape
	player.add_child(col)
	player.position = Vector3(0, 1.0, 8)
	add_child(player)
	var camera := Camera3D.new()
	camera.position = Vector3(0, 5.0, 9.0)
	camera.rotation_degrees = Vector3(-18, 0, 0)
	camera.current = true
	player.add_child(camera)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := ColorRect.new()
	panel.color = Color(0.02, 0.04, 0.06, 0.68)
	panel.position = Vector2(18, 18)
	panel.size = Vector2(560, 74)
	layer.add_child(panel)
	status_label = Label.new()
	status_label.position = Vector2(14, 20)
	status_label.add_theme_font_size_override("font_size", 22)
	status_label.text = "NEXUS | PROTÓTIPO | ALVOS: 5"
	panel.add_child(status_label)
	var hint := Label.new()
	hint.text = "Use os botões para se mover • ATIRAR para testar"
	hint.position = Vector2(18, 100)
	hint.add_theme_font_size_override("font_size", 18)
	layer.add_child(hint)
	var controls = [
		["↑", "forward", Vector2(112, -148)],
		["↓", "back", Vector2(112, -54)],
		["←", "left", Vector2(60, -101)],
		["→", "right", Vector2(164, -101)]
	]
	for item in controls:
		var b := Button.new()
		b.text = item[0]
		b.position = Vector2(24, 720) + item[2]
		b.size = Vector2(88, 78)
		b.add_theme_font_size_override("font_size", 28)
		b.button_down.connect(_set_move.bind(item[1], true))
		b.button_up.connect(_set_move.bind(item[1], false))
		layer.add_child(b)
	var shoot_btn := Button.new()
	shoot_btn.text = "ATIRAR"
	shoot_btn.position = Vector2(1080, 570)
	shoot_btn.size = Vector2(160, 100)
	shoot_btn.add_theme_font_size_override("font_size", 24)
	shoot_btn.pressed.connect(_shoot)
	layer.add_child(shoot_btn)

func _set_move(direction: String, pressed: bool) -> void:
	move_flags[direction] = pressed

func _physics_process(delta: float) -> void:
	if player == null:
		return
	var direction := Vector3.ZERO
	if move_flags["forward"] or Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if move_flags["back"] or Input.is_action_pressed("move_back"):
		direction.z += 1
	if move_flags["left"] or Input.is_action_pressed("move_left"):
		direction.x -= 1
	if move_flags["right"] or Input.is_action_pressed("move_right"):
		direction.x += 1
	direction = direction.normalized()
	player.velocity.x = direction.x * PLAYER_SPEED
	player.velocity.z = direction.z * PLAYER_SPEED
	if not player.is_on_floor():
		player.velocity.y -= 20.0 * delta
	else:
		player.velocity.y = 0
	player.move_and_slide()
	if direction.length() > 0.1:
		player.rotation.y = lerp_angle(player.rotation.y, atan2(-direction.x, -direction.z), TURN_SPEED * delta)

func _shoot() -> void:
	shots += 1
	var nearest: Node3D = null
	var nearest_distance := 1000.0
	for target in targets:
		if is_instance_valid(target):
			var d := player.global_position.distance_to(target.global_position)
			if d < nearest_distance:
				nearest_distance = d
				nearest = target
	if nearest != null and nearest_distance < 35.0:
		targets.erase(nearest)
		nearest.queue_free()
		status_label.text = "NEXUS | ALVOS RESTANTES: %d | TIROS: %d" % [targets.size(), shots]
	else:
		status_label.text = "NEXUS | TIROS: %d | APROXIME-SE DOS ALVOS" % shots
