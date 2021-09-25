extends Control

var shields = 3 setget set_shields
var max_shields = 3 setget set_max_shields

onready var shieldUIFull = $ShieldUIFull
onready var shieldUIEmpty = $ShieldUIEmpty

func set_shields(value):
	shields = clamp(value, 0, max_shields)
	if shieldUIFull != null:
		shieldUIFull.rect_size.x = shields * 15

func set_max_shields(value):
	max_shields = max(value, 1 )
	self.shields = min(shields, max_shields)
	if shieldUIEmpty != null:
		shieldUIEmpty.rect_size.x = max_shields * 15 

func _ready():
	self.shields = PlayerStats.shields
	self.max_shields = PlayerStats.max_shields

# warning-ignore:return_value_discarded
	PlayerStats.connect("shields_changed", self, "set_shields")
# warning-ignore:return_value_discarded
	PlayerStats.connect("max_shields_changed", self, "set_max_shields")
