extends StaticBody3D

@onready var outline: MeshInstance3D = $outline
@onready var anim: AnimationPlayer = $AnimationPlayer

@onready var mmesh: MeshInstance3D = $Plane2
var pplayer : CharacterBody3D
var scene_original_parent
var picked_up : bool = false:
	set(new_val):
		if new_val == true:
			anim.play("pin_down")
			apply_shader_to_model(mmesh)
			set_collision_layer_value(2, false)
		else:
			anim.play_backwards("pin_down")
			remove_shader_to_model(mmesh)
			set_collision_layer_value(2, true)
		picked_up = new_val
func _ready() -> void:
	scene_original_parent = get_parent()
func hover_activate():
	if !outline.visible:
		outline.visible = true
	else:
		outline.visible = true

func hover_deactivate():
	outline.visible = false

func _process(delta: float) -> void:
	if picked_up:
		snap_to_wall()

func snap_to_wall():
	var ray = pplayer.ray_cast_3d # Certifique-se que o nome da variável no Player está correto
	
	if ray.is_colliding():
		# 1. Pegamos o ponto de colisão e a normal (direção para onde a parede "olha")
		var collision_point = ray.get_collision_point()
		var collision_normal = ray.get_collision_normal()
		global_position = collision_point + (collision_normal * 0.01)
		look_at_from_position(global_position, global_position + collision_normal, Vector3.UP)
		rotate_object_local(Vector3.RIGHT, deg_to_rad(-90))
		rotate_object_local(Vector3.UP, deg_to_rad(-90))
		if Input.is_action_just_pressed("interact"):
			reparent(scene_original_parent)
			picked_up = false
func interact(player : CharacterBody3D):
	pplayer = player
	self.reparent(player.camera)
	picked_up = true

func apply_shader_to_model(meshh : MeshInstance3D, fov_or_negative_for_unchanged = -1.0):
	var new_shader = ShaderMaterial.new()
	new_shader.shader = preload("res://Interactable/Cards/ShaderCard.gdshader")
	
	var base_mat = mmesh.get_active_material(0)
		
	new_shader.set_shader_parameter("enabled", true)
	new_shader.set_shader_parameter("texture_albedo", base_mat.albedo_texture)
	meshh.set_surface_override_material(0, new_shader)
	#var all_mesh_instances = node3d.find_children("*", "MeshInstance3D")
	#if node3d is MeshInstance3D:
		#all_mesh_instances.push_back(node3d)
	#for mesh_instance in all_mesh_instances:
		#var mesh = mesh_instance.mesh
		## Important to turn shadow casting off for view model or will cause issues with both
		## view model, casting shadows on itself once unclipped, & also will look weird casting on world.
		#mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		#for surface_idx in mesh.get_surface_count():
			#var base_mat = mesh.surface_get_material(surface_idx)
			#if not base_mat is BaseMaterial3D: continue
			#var weapon_shader_material := ShaderMaterial.new()
			#weapon_shader_material.shader = preload("res://Interactable/Cards/ShaderCard.gdshader")
			#weapon_shader_material.set_shader_parameter("Enabled", true)
			#weapon_shader_material.set_shader_parameter("texture_albedo", base_mat.albedo_texture)
			#weapon_shader_material.set_shader_parameter("texture_metallic", base_mat.metallic_texture)
			#weapon_shader_material.set_shader_parameter("texture_roughness", base_mat.roughness_texture)
			#weapon_shader_material.set_shader_parameter("texture_normal", base_mat.normal_texture)
			#weapon_shader_material.set_shader_parameter("albedo", base_mat.albedo_color)
			#weapon_shader_material.set_shader_parameter("metallic", base_mat.metallic)
			#weapon_shader_material.set_shader_parameter("specular", base_mat.metallic_specular)
			#weapon_shader_material.set_shader_parameter("roughness", base_mat.roughness)
			#weapon_shader_material.set_shader_parameter("viewmodel_fov", fov_or_negative_for_unchanged)
			#var tex_channels = { 0: Vector4(1., 0., 0., 0.), 1: Vector4(0., 1., 0., 0.), 2: Vector4(0., 0., 1., 0.), 3: Vector4(1., 0., 0., 1.), 4: Vector4() }
			#weapon_shader_material.set_shader_parameter("metallic_texture_channel", tex_channels[base_mat.metallic_texture_channel])
			#mesh.surface_set_material(surface_idx, weapon_shader_material)

func remove_shader_to_model(meshh: MeshInstance3D):
	meshh.set_surface_override_material(0, null)
