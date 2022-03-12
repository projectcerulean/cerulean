extends Node

var DataLoaderWorkerPreload: PackedScene = preload("res://src/autoload/data_loader/data_loader_worker.tscn")


func _ready() -> void:
	Signals.request_resource_load.connect(_on_request_resource_load)


func _on_request_resource_load(_sender: Node, resource_path: StringName):
	var data_loader_worker: DataLoaderWorker = DataLoaderWorkerPreload.instantiate() as DataLoaderWorker
	data_loader_worker.resource_path = resource_path
	add_child(data_loader_worker)