extends Node

var main: Node
var viewport: SubViewport
var texture_rect: TextureRect
var shader_material: ShaderMaterial
var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func start_transition(scene: Node, duration: float = 1.0):
	main = Node.new()
	get_tree().root.add_child(main)
	setup_viewport()
	setup_texture_rect()
	apply_shader()
	var org_parent = scene.get_parent()
	scene.reparent(viewport) # viewport只投射子節點
	set_tween(duration)
	tween.finished.connect(_on_tween_finished.bind(scene, org_parent))


func setup_viewport():
	viewport = SubViewport.new()
	viewport.size = get_viewport().size
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	main.add_child(viewport)

func setup_texture_rect():
	texture_rect = TextureRect.new()
	texture_rect.texture = viewport.get_texture()
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	texture_rect.size = get_viewport().size
	main.add_child(texture_rect)

func apply_shader():
	shader_material = ShaderMaterial.new()
	shader_material.shader = Shader.new()
	# 淡出效果
	shader_material.shader.code = """
		shader_type canvas_item;
		uniform float progress : hint_range(0,1);
		void fragment() {
			vec4 color = texture(TEXTURE, UV);
			color.a *= smoothstep(1.0, 0.0, progress);
			COLOR = color;
		}
	"""
	shader_material.set_shader_parameter("progress", 0.0)
	texture_rect.material = shader_material

func set_tween(duration: float = 1.0):
	tween = main.create_tween()
	# 左移出
	#tween.tween_property(texture_rect, "position:x", -texture_rect.size.x, duration)
	# 淡出
	tween.tween_property(shader_material, "shader_parameter/progress", 1.0, duration)

func _on_tween_finished(scene: Control, org_parent: Node):
	scene.visible = false # reparent會移到最前，需要隱藏
	scene.reparent(org_parent)
	main.queue_free()
