class_name DataStructures
extends Node


class RotationQueue:
	var contents: Array[Variant]
	var index_current: int = 0
	var size_current: int = 0


	func _init(ssize_max: int):
		assert(ssize_max > 0, Errors.INVALID_ARGUMENT)
		contents.resize(ssize_max)


	func add(element: Variant) -> void:
		contents[index_current] = element
		index_current = (index_current + 1) % contents.size()
		size_current = min(size_current + 1, contents.size())


	func get_item(index: int) -> Variant:
		assert(index >= -size_current and index < size_current, Errors.INDEX_ERROR)
		return contents[(index_current + index) % size_current]


	func size() -> int:
		return size_current


	func size_max() -> int:
		return contents.size()
