extends Node

class_name Bindings

const DiscoveredSpell = preload("res://types/DiscoveredSpell.gd")
const Constants = preload("res://Constants.gd")
const BoundSpell = preload("res://types/BoundSpell.gd")

onready var InventoryStorage = $"/root/InventoryStorage"
onready var State = $"/root/state"

onready var crafted_spells_vbox = $"ScrollContainer/VBoxContainer"

func add_spell_binding(row):
  crafted_spells_vbox.add_child(row)
  row.connect("item_selected", self, "_on_spell_binding_changed")


func _on_spell_binding_changed(spell_name: String, selected_node_index: int, num: int):
  if State.discovered_spells.has(spell_name):
    for child in crafted_spells_vbox.get_children():
      var option_button: OptionButton = child.get_option_button()
      # deselect an existing drop down if it has this option already
      if option_button.selected == num && child.get_index() != selected_node_index:
        option_button.select(0)

    for num in State.bound_spells:
      # Unbind the current spell
      if State.bound_spells[num].spell_name == spell_name:
        State.bound_spells.erase(num)

    var spell = State.discovered_spells[spell_name]
    State.bound_spells[num] = BoundSpell.new(spell.spell_name, spell.spell_status_type, spell.spell_type_name)

    var spell_bindings = get_tree().get_current_scene().get_ui().get_spell_bindings()
    spell_bindings.set_images_for_bindings()
