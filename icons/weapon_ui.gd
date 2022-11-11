extends PanelContainer

@onready var nodes := {
	"DEFAULT" : %Flash,
	"GRENADE" : %Grenade
}

var selected_node: String = ""


func switch_to(node_name : String):
	# Return if same node
	if node_name == selected_node: return
	if selected_node != "": 
		# Unselect previous
		nodes[selected_node].set_state(false)
	# Select node
	nodes[node_name].set_state(true)
	selected_node = node_name
