# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name DataLoaderWorker
extends Node

var _resource_path: String


func load_resource(resource_path: String) -> void:
	assert(resource_path, Errors.INVALID_ARGUMENT)
	assert(not _resource_path, Errors.INVALID_CONTEXT)
	_resource_path = resource_path
	assert(ResourceLoader.exists(_resource_path), Errors.INVALID_ARGUMENT)
	ResourceLoader.load_threaded_request(_resource_path)


func _process(_delta: float) -> void:
	if _resource_path != null and _resource_path != String():
		var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(_resource_path) as ResourceLoader.ThreadLoadStatus
		if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			var resource: Resource = ResourceLoader.load_threaded_get(_resource_path)
			Signals.emit_resource_load_completed(self, _resource_path, resource)
			queue_free()
