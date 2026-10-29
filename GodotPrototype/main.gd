extends Node3D

# NEXUS Battle Royale — vertical slice 0.2
# Procedural mobile arena: third-person camera, real raycast shooting,
# loot pickups, simple shrinking safe zone and touch HUD.

const PLAYER_SPEED := 7.0
const TURN_SPEED := 7.0
const START_ZONE_RADIUS := 42.0
const ZONE_SHRINK_RATE := 0.22
const MAX_HEALTH := 100.0

var move_flags := {"forward": false, "back": false, "left": false, "right": false}
var player: CharacterBody3D
var camera: Camera3D
var status_label: Label
var health_label: Label
var ammo_label: Label
var targets: Array[Node3D] = []
var loot_items: Array[Node3D] = []
var health := MAX_HEALTH
var ammo := 30
var reserve_ammo := 90
var shots := 0
var eliminations := 0
var zone_radius := START_ZONE_RADIUS
var zone_time := 0.0
var fire_cooldown := 0.0
var look_touch_id := -1
var last_touch_position := Vector2.ZERO
var camera_yaw := 0.0
var camera_pitch := -12.0
var match_over := false

func _ready() -> void:
    _build_world()
    _build_player()
    _build_targets()
    _build_loot()
    _build_hud()
    _update_hud()

func _build_world() -> void:
    var world_env := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_SKY
    env.sky = Sky.new()
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.62, 0.72, 0.82)
    env.ambient_light_energy = 0.85
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    world_env.environment = env
    add_child(world_env)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-52, -28, 0)
    sun.light_energy = 1.25
    sun.shadow_enabled = true
    add_child(sun)

    _add_box(Vector3(0, -0.5, 0), Vector3(100, 1, 100), Color(0.19, 0.34, 0.21), true, "Terrain")

    # Roads through the arena
    _add_box(Vector3(0, 0.015, 0), Vector3(7, 0.04, 100), Color(0.16, 0.17, 0.18), false, "MainRoad")
    _add_box(Vector3(0, 0.025, -5), Vector3(100, 0.04, 6), Color(0.16, 0.17, 0.18), false, "CrossRoad")

    # Small town: varied buildings with doors/windows represented by contrasting panels.
    var building_positions := [
        Vector3(-18, 0, -16), Vector3(-8, 0, -22), Vector3(12, 0, -19),
        Vector3(22, 0, -8), Vector3(-22, 0, 8), Vector3(18, 0, 16),
        Vector3(-12, 0, 23), Vector3(7, 0, 27)
    ]
    for i in range(building_positions.size()):
        var p: Vector3 = building_positions[i]
        var w := 5.0 + float(i % 3)
        var d := 5.0 + float((i + 1) % 3)
        var h := 3.5 + float(i % 2) * 1.2
        var wall_color := [Color(0.56, 0.51, 0.42), Color(0.43, 0.49, 0.53), Color(0.54, 0.39, 0.32)][i % 3]
        _add_box(Vector3(p.x, h / 2.0, p.z), Vector3(w, h, d), wall_color, true, "Building_%02d" % i)
        _add_box(Vector3(p.x, h + 0.12, p.z), Vector3(w + 0.3, 0.24, d + 0.3), Color(0.18, 0.21, 0.24), false, "Roof_%02d" % i)
        # Front windows
        for side in [-1.0, 1.0]:
            _add_box(Vector3(p.x + side * w * 0.24, h * 0.62, p.z - d / 2.0 - 0.025), Vector3(0.85, 0.75, 0.06), Color(0.16, 0.43, 0.55), false, "Window")

    # Rocks, cover and trees around the town.
    for i in range(22):
        var angle := float(i) * 2.399
        var radius := 28.0 + float(i % 4) * 3.0
        var p := Vector3(cos(angle) * radius, 0, sin(angle) * radius)
        if i % 3 == 0:
            _add_box(p + Vector3(0, 0.8, 0), Vector3(2.4, 1.6, 2.0), Color(0.34, 0.37, 0.35), true, "Cover")
        else:
            _add_tree(p, 1.0 + float(i % 3) * 0.16)

    _build_zone_visual()

func _add_box(pos: Vector3, size: Vector3, color: Color, solid: bool, node_name: String) -> Node3D:
    var root: Node3D
    if solid:
        root = StaticBody3D.new()
    else:
        root = Node3D.new()
    root.name = node_name
    root.position = pos
    var mesh_instance := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    mesh_instance.mesh = mesh
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.92
    mesh_instance.material_override = material
    root.add_child(mesh_instance)
    if solid:
        var collision := CollisionShape3D.new()
        var shape := BoxShape3D.new()
        shape.size = size
        collision.shape = shape
        root.add_child(collision)
    add_child(root)
    return root

func _add_tree(pos: Vector3, scale_factor: float) -> void:
    var tree := Node3D.new()
    tree.position = pos
    tree.scale = Vector3.ONE * scale_factor
    add_child(tree)
    var trunk := MeshInstance3D.new()
    var trunk_mesh := CylinderMesh.new()
    trunk_mesh.top_radius = 0.22
    trunk_mesh.bottom_radius = 0.32
    trunk_mesh.height = 2.2
    trunk.mesh = trunk_mesh
    trunk.position.y = 1.1
    var trunk_mat := StandardMaterial3D.new()
    trunk_mat.albedo_color = Color(0.30, 0.20, 0.12)
    trunk.material_override = trunk_mat
    tree.add_child(trunk)
    var crown := MeshInstance3D.new()
    var crown_mesh := SphereMesh.new()
    crown_mesh.radius = 1.25
    crown_mesh.height = 2.3
    crown.mesh = crown_mesh
    crown.position.y = 2.6
    var crown_mat := StandardMaterial3D.new()
    crown_mat.albedo_color = Color(0.13, 0.31, 0.17)
    crown.material_override = crown_mat
    tree.add_child(crown)

func _build_player() -> void:
    player = CharacterBody3D.new()
    player.name = "Player"
    player.position = Vector3(0, 1.05, 8)
    player.floor_snap_length = 0.35
    add_child(player)

    var body := MeshInstance3D.new()
    var body_mesh := CapsuleMesh.new()
    body_mesh.radius = 0.42
    body_mesh.height = 1.8
    body.mesh = body_mesh
    var body_mat := StandardMaterial3D.new()
    body_mat.albedo_color = Color(0.08, 0.62, 0.86)
    body_mat.metallic = 0.12
    body.material_override = body_mat
    player.add_child(body)

    var collision := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.42
    capsule.height = 1.8
    collision.shape = capsule
    player.add_child(collision)

    camera = Camera3D.new()
    camera.name = "ThirdPersonCamera"
    camera.position = Vector3(0, 3.0, 7.0)
    camera.rotation_degrees = Vector3(camera_pitch, 0, 0)
    camera.current = true
    camera.fov = 76.0
    player.add_child(camera)

func _build_targets() -> void:
    var positions := [
        Vector3(-10, 1.0, -15), Vector3(0, 1.0, -25),
        Vector3(10, 1.0, -14), Vector3(24, 1.0, 5),
        Vector3(-25, 1.0, -2), Vector3(4, 1.0, 28)
    ]
    for i in range(positions.size()):
        var enemy := StaticBody3D.new()
        enemy.name = "TrainingTarget_%02d" % i
        enemy.position = positions[i]
        enemy.set_meta("health", 100.0)
        var mesh_instance := MeshInstance3D.new()
        var capsule_mesh := CapsuleMesh.new()
        capsule_mesh.radius = 0.48
        capsule_mesh.height = 1.9
        mesh_instance.mesh = capsule_mesh
        var material := StandardMaterial3D.new()
        material.albedo_color = Color(0.78, 0.17, 0.13)
        material.roughness = 0.65
        mesh_instance.material_override = material
        enemy.add_child(mesh_instance)
        var collision := CollisionShape3D.new()
        var capsule_shape := CapsuleShape3D.new()
        capsule_shape.radius = 0.5
        capsule_shape.height = 1.9
        collision.shape = capsule_shape
        enemy.add_child(collision)
        add_child(enemy)
        targets.append(enemy)

func _build_loot() -> void:
    var positions := [
        Vector3(-17, 0.45, -13), Vector3(14, 0.45, -16),
        Vector3(20, 0.45, 12), Vector3(-14, 0.45, 20),
        Vector3(3, 0.45, -3), Vector3(-3, 0.45, 17)
    ]
    for i in range(positions.size()):
        var loot := Node3D.new()
        loot.name = "Loot_%02d" % i
        loot.position = positions[i]
        loot.set_meta("loot_type", "ammo" if i % 2 == 0 else "medkit")
        var mesh_instance := MeshInstance3D.new()
        var mesh := BoxMesh.new()
        mesh.size = Vector3(0.65, 0.45, 0.65)
        mesh_instance.mesh = mesh
        var material := StandardMaterial3D.new()
        material.albedo_color = Color(0.95, 0.72, 0.14) if i % 2 == 0 else Color(0.12, 0.8, 0.42)
        material.emission_enabled = true
        material.emission = material.albedo_color * 0.18
        mesh_instance.material_override = material
        loot.add_child(mesh_instance)
        add_child(loot)
        loot_items.append(loot)

func _build_zone_visual() -> void:
    var zone := MeshInstance3D.new()
    zone.name = "SafeZoneRing"
    var torus := TorusMesh.new()
    torus.inner_radius = 0.12
    torus.outer_radius = 0.22
    torus.rings = 8
    torus.ring_segments = 64
    zone.mesh = torus
    zone.rotation_degrees.x = 90
    zone.position.y = 0.15
    zone.scale = Vector3(zone_radius, 1.0, zone_radius)
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.2, 0.75, 1.0, 0.85)
    material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    zone.material_override = material
    add_child(zone)
    set_meta("zone_visual", zone)

func _build_hud() -> void:
    var layer := CanvasLayer.new()
    layer.name = "MobileHUD"
    add_child(layer)

    var top_panel := ColorRect.new()
    top_panel.color = Color(0.015, 0.025, 0.04, 0.78)
    top_panel.position = Vector2(18, 16)
    top_panel.size = Vector2(470, 112)
    layer.add_child(top_panel)

    status_label = Label.new()
    status_label.position = Vector2(14, 8)
    status_label.add_theme_font_size_override("font_size", 22)
    status_label.text = "NEXUS  //  BATTLE ROYALE"
    top_panel.add_child(status_label)

    health_label = Label.new()
    health_label.position = Vector2(14, 42)
    health_label.add_theme_font_size_override("font_size", 18)
    top_panel.add_child(health_label)

    ammo_label = Label.new()
    ammo_label.position = Vector2(14, 72)
    ammo_label.add_theme_font_size_override("font_size", 18)
    top_panel.add_child(ammo_label)

    var crosshair := Label.new()
    crosshair.text = "+"
    crosshair.set_anchors_preset(Control.PRESET_CENTER)
    crosshair.position = Vector2(-10, -20)
    crosshair.size = Vector2(20, 40)
    crosshair.add_theme_font_size_override("font_size", 30)
    crosshair.add_theme_color_override("font_color", Color(0.95, 0.98, 1.0))
    layer.add_child(crosshair)

    var hint := Label.new()
    hint.text = "DESLIZE O LADO DIREITO PARA MIRAR  •  PEGUE CAIXAS NO CHÃO"
    hint.position = Vector2(330, 26)
    hint.size = Vector2(630, 34)
    hint.add_theme_font_size_override("font_size", 16)
    layer.add_child(hint)

    var controls := [
        ["▲", "forward", Vector2(120, -172)],
        ["▼", "back", Vector2(120, -62)],
        ["◀", "left", Vector2(60, -117)],
        ["▶", "right", Vector2(180, -117)]
    ]
    for item in controls:
        var button := Button.new()
        button.text = item[0]
        button.position = Vector2(22, 720) + item[2]
        button.size = Vector2(92, 82)
        button.add_theme_font_size_override("font_size", 27)
        button.button_down.connect(_set_move.bind(item[1], true))
        button.button_up.connect(_set_move.bind(item[1], false))
        layer.add_child(button)

    var fire_button := Button.new()
    fire_button.text = "ATIRAR"
    fire_button.position = Vector2(1080, 570)
    fire_button.size = Vector2(165, 105)
    fire_button.add_theme_font_size_override("font_size", 24)
    fire_button.button_down.connect(_start_fire)
    fire_button.button_up.connect(_stop_fire)
    layer.add_child(fire_button)

    var reload_button := Button.new()
    reload_button.text = "RECARREGAR"
    reload_button.position = Vector2(1060, 470)
    reload_button.size = Vector2(185, 68)
    reload_button.add_theme_font_size_override("font_size", 18)
    reload_button.pressed.connect(_reload)
    layer.add_child(reload_button)

    var heal_button := Button.new()
    heal_button.text = "USAR KIT"
    heal_button.position = Vector2(910, 590)
    heal_button.size = Vector2(145, 72)
    heal_button.add_theme_font_size_override("font_size", 18)
    heal_button.pressed.connect(_use_medkit)
    layer.add_child(heal_button)

var firing := false

func _set_move(direction: String, pressed: bool) -> void:
    move_flags[direction] = pressed

func _start_fire() -> void:
    firing = true
    _shoot()

func _stop_fire() -> void:
    firing = false

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and event.position.x > 450:
            look_touch_id = event.index
            last_touch_position = event.position
        elif not event.pressed and event.index == look_touch_id:
            look_touch_id = -1
    elif event is InputEventScreenDrag and event.index == look_touch_id:
        var delta_pos := event.position - last_touch_position
        last_touch_position = event.position
        camera_yaw -= delta_pos.x * 0.18
        camera_pitch = clamp(camera_pitch - delta_pos.y * 0.12, -35.0, 12.0)
        camera.rotation_degrees = Vector3(camera_pitch, 0, 0)
        player.rotation_degrees.y = camera_yaw

func _physics_process(delta: float) -> void:
    if player == null or match_over:
        return
    fire_cooldown = maxf(0.0, fire_cooldown - delta)
    if firing and fire_cooldown <= 0.0:
        _shoot()
    var input_dir := Vector3.ZERO
    if move_flags["forward"] or Input.is_action_pressed("move_forward"):
        input_dir.z -= 1.0
    if move_flags["back"] or Input.is_action_pressed("move_back"):
        input_dir.z += 1.0
    if move_flags["left"] or Input.is_action_pressed("move_left"):
        input_dir.x -= 1.0
    if move_flags["right"] or Input.is_action_pressed("move_right"):
        input_dir.x += 1.0
    input_dir = input_dir.normalized()
    var world_dir := (Basis(Vector3.UP, deg_to_rad(camera_yaw)) * input_dir).normalized()
    player.velocity.x = world_dir.x * PLAYER_SPEED
    player.velocity.z = world_dir.z * PLAYER_SPEED
    if not player.is_on_floor():
        player.velocity.y -= 22.0 * delta
    else:
        player.velocity.y = 0.0
    player.move_and_slide()
    if world_dir.length() > 0.1:
        player.rotation.y = lerp_angle(player.rotation.y, atan2(-world_dir.x, -world_dir.z), TURN_SPEED * delta)
        camera_yaw = player.rotation_degrees.y

    _update_zone(delta)
    _collect_loot()
    _update_hud()

func _shoot() -> void:
    if match_over or fire_cooldown > 0.0:
        return
    if ammo <= 0:
        status_label.text = "SEM MUNIÇÃO — RECARREGUE"
        fire_cooldown = 0.25
        return
    ammo -= 1
    shots += 1
    fire_cooldown = 0.16

    var from := camera.global_position
    var to := from + (-camera.global_transform.basis.z * 100.0)
    var query := PhysicsRayQueryParameters3D.create(from, to)
    query.exclude = [player.get_rid()]
    query.collide_with_areas = true
    var hit := get_world_3d().direct_space_state.intersect_ray(query)
    if not hit.is_empty():
        var collider: Object = hit.get("collider")
        if collider is Node3D and targets.has(collider):
            var target := collider as Node3D
            var target_health := float(target.get_meta("health", 100.0)) - 34.0
            target.set_meta("health", target_health)
            if target_health <= 0.0:
                targets.erase(target)
                target.queue_free()
                eliminations += 1
                status_label.text = "ELIMINAÇÃO CONFIRMADA"
    _update_hud()

func _reload() -> void:
    var needed := 30 - ammo
    var amount := mini(needed, reserve_ammo)
    if amount > 0:
        ammo += amount
        reserve_ammo -= amount
    _update_hud()

func _use_medkit() -> void:
    health = minf(MAX_HEALTH, health + 35.0)
    _update_hud()

func _collect_loot() -> void:
    for item in loot_items.duplicate():
        if not is_instance_valid(item):
            loot_items.erase(item)
            continue
        if player.global_position.distance_to(item.global_position) < 2.0:
            if item.get_meta("loot_type") == "ammo":
                reserve_ammo += 30
                status_label.text = "MUNIÇÃO COLETADA  +30"
            else:
                health = minf(MAX_HEALTH, health + 25.0)
                status_label.text = "KIT MÉDICO COLETADO  +25"
            loot_items.erase(item)
            item.queue_free()

func _update_zone(delta: float) -> void:
    zone_time += delta
    if zone_time > 8.0:
        zone_radius = maxf(10.0, zone_radius - ZONE_SHRINK_RATE * delta)
        var zone: Node3D = get_meta("zone_visual")
        zone.scale = Vector3(zone_radius, 1.0, zone_radius)
    var distance_from_center := Vector2(player.global_position.x, player.global_position.z).length()
    if distance_from_center > zone_radius:
        health -= 7.0 * delta
        if health <= 0.0:
            health = 0.0
            match_over = true
            status_label.text = "VOCÊ FOI ELIMINADO PELA ZONA"

func _update_hud() -> void:
    if health_label == null:
        return
    health_label.text = "VIDA: %d/100     ELIMINAÇÕES: %d" % [roundi(health), eliminations]
    ammo_label.text = "MUNIÇÃO: %02d / %03d     ALVOS: %d     ZONA: %dm" % [ammo, reserve_ammo, targets.size(), roundi(zone_radius)]
