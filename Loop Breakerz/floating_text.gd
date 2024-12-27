extends Node2D

func _ready():
	$AnimationPlayer.play("show")
	$Label.rect_pivot_offset = $Label.rect_size / 2
