# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name DataLoaderWorker
extends Node

var resource_path: String  # Set by parent


func _ready() -> void:
	assert(resource_path != null and resource_path != String(), Errors.INVALID_ARGUMENT)
	assert(ResourceLoader.exists(resource_path), Errors.INVALID_ARGUMENT)
	ResourceLoader.load_threaded_request(resource_path)


func _process(_delta: float) -> void:
	var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(resource_path) as ResourceLoader.ThreadLoadStatus
	if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
		var resource: Resource = ResourceLoader.load_threaded_get(resource_path)
		Signals.emit_resource_load_completed(self, resource_path, resource)
		queue_free()
