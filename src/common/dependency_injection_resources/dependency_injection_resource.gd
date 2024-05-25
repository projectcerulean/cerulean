# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later

# Base resource type used for performing dependency injection. Each DependencyInjectionResource has
# an owner, and only the owner is allowed to write to the resource. Non-owners are allowed to read
# the values, but only if an owner is set.
class_name DependencyInjectionResource
extends Resource

var _owner: Node = null


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		assert(is_same(_owner, null), "%s: %s: %s" % [Errors.RESOURCE_ORPHANED, resource_path, "Resource still owned by %s" % _owner])


func claim_ownership(caller: Node) -> void:
	# Need to be a bit careful here, since the expression '<freed object> == null' validates to 'true', at least in
	# Godot 4.2. Seems to be changed for Godot 4.3, though.
	# https://github.com/godotengine/godot/issues/59816
	# https://github.com/godotengine/godot/pull/73896
	assert(is_same(_owner, null), "%s: %s: %s" % [Errors.RESOURCE_BUSY, resource_path, "Resource already owned by %s" % _owner])
	assert(not is_same(caller, null) and is_instance_valid(caller), Errors.NULL_NODE)
	_owner = caller
	assert(is_owned_by(caller), Errors.CONSISTENCY_ERROR)


func release_ownership(caller: Node) -> void:
	assert(is_owned_by(caller), "%s: %s: %s" % [Errors.INVALID_ARGUMENT, resource_path, "Resource is owned by %s, not %s" % [_owner, caller]])
	_owner = null


func is_owned_by(node: Node) -> bool:
	return (
		is_instance_valid(node)
		and is_instance_valid(_owner)
		and is_same(node, _owner)
	)


func is_owned() -> bool:
	return not is_same(_owner, null) and is_instance_valid(_owner)


func _validate_read(property_name: String = "") -> void:
	var assert_message: String = (
		"%s: %s:%s" % [Errors.INVALID_RESOURCE_VALUE_READ, resource_path, property_name] if not property_name.is_empty()
		else "%s: %s" % [Errors.INVALID_RESOURCE_VALUE_READ, resource_path]
	)
	assert(is_owned(), assert_message)


func _validate_write(caller: Node, property_name: String = "") -> void:
	var assert_message: String = (
		"%s: %s:%s" % [Errors.INVALID_RESOURCE_VALUE_WRITE, resource_path, property_name] if not property_name.is_empty()
		else "%s: %s" % [Errors.INVALID_RESOURCE_VALUE_WRITE, resource_path]
	)
	assert(is_owned_by(caller), assert_message)
