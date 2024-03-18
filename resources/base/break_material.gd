class_name BlockBreakMaterial extends StandardMaterial3D

enum BreakStage {
	NONE, ONE, TWO, THREE, FOUR, FIVE, SIX, SEVEN
}

var break_textures: Dictionary = {
	BreakStage.NONE: preload("res://assets/sprites/breaking/1.png"),
	BreakStage.ONE: preload("res://assets/sprites/breaking/1.png"),
	BreakStage.TWO: preload("res://assets/sprites/breaking/2.png"),
	BreakStage.THREE: preload("res://assets/sprites/breaking/3.png"),
	BreakStage.FOUR: preload("res://assets/sprites/breaking/4.png"),
	BreakStage.FIVE: preload("res://assets/sprites/breaking/5.png"),
	BreakStage.SIX: preload("res://assets/sprites/breaking/6.png"),
	BreakStage.SEVEN: preload("res://assets/sprites/breaking/7.png"),
}

@export var break_stage: BreakStage:
	set(x):
		break_stage = x
		albedo_texture = break_textures[x]
		albedo_color = Color.TRANSPARENT if x == BreakStage.NONE else Color.WHITE

func progress_break_stage() -> void:
	var next_stage = BreakStage.NONE
	match break_stage:
		BreakStage.NONE: next_stage = BreakStage.ONE
		BreakStage.ONE: next_stage = BreakStage.TWO
		BreakStage.TWO: next_stage = BreakStage.THREE
		BreakStage.THREE: next_stage = BreakStage.FOUR
		BreakStage.FOUR: next_stage = BreakStage.FIVE
		BreakStage.FIVE: next_stage = BreakStage.SIX
		BreakStage.SIX: next_stage = BreakStage.SEVEN
	break_stage = next_stage
