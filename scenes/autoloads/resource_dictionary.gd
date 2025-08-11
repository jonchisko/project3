extends Node

const _ItemDirectory = "res://resources/interactables/items"
const _NpcDirectory = "res://resources/interactables/npcs"

var ResourceIdToResource: Dictionary = {}

var npc_ids: Array[String] = []
var item_ids: Array[String] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self._load_resources()
	
	
func _load_resources():
	var item_file_names = self._get_files_in_dir(self._ItemDirectory)
	var npc_file_names = self._get_files_in_dir(self._NpcDirectory)

	self._add_to_dictionary(item_file_names, "InteractableResource", item_ids)
	self._add_to_dictionary(npc_file_names, "InteractableResource", npc_ids)


func _get_files_in_dir(path):
	var files = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			files.push_back(dir.get_current_dir() + "/" + file_name)
			file_name = dir.get_next()
	else:
		printerr("An error occurred when trying to access the path.")
		
	return files
		
	
func _add_to_dictionary(file_names: Array, type_hint: String, id_collection: Array[String]):
	for file_name in file_names:
		var resource: InteractableResource = ResourceLoader.load(file_name, type_hint)
		
		if resource == null:
			printerr("Resource is null, {fn}".format({"fn": file_name}))
			continue
		
		if self.ResourceIdToResource.has(resource.data.id):
			printerr("Resource ID already in dictionary, in dict: {InDict}, to add: {ToAdd}"
			.format({"InDict": self.ResourceIdToResource[resource.data.id], "ToAdd": resource.data.name}))
			continue
		
		id_collection.push_back(resource.data.id)
		self.ResourceIdToResource[resource.data.id] = resource
