# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node

var DataLoaderWorkerPreload: PackedScene = preload("data_loader_worker.tscn")


func _ready() -> void:
	Signals.request_resource_load.connect(_on_request_resource_load)


func _on_request_resource_load(_sender: NodePath, resource_path: String):
	var data_loader_worker: DataLoaderWorker = DataLoaderWorkerPreload.instantiate() as DataLoaderWorker
	add_child(data_loader_worker)
	data_loader_worker.load_resource(resource_path)
