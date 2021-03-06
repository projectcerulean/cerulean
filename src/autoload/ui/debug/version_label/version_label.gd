extends Label

@export var git_folder: String = "res://.git/"
@export var n_hash_characters_to_show: int = 8

const hash_length: int = 40


func _ready() -> void:
	# Check for git commit hash
	var hash: String = ""
	var file: File = File.new()
	if file.file_exists(git_folder + "HEAD"):
		file.open(git_folder + "HEAD", File.READ)
		var head: String = file.get_as_text().strip_edges()
		file.close()
		if head.begins_with("ref: "):
			if file.file_exists(git_folder + head.trim_prefix("ref: ")):
				file.open(git_folder + head.trim_prefix("ref: "), File.READ)
				head = file.get_as_text().strip_edges()
				file.close()
				if head.length() == hash_length and head.is_valid_hex_number():
					hash = head
		elif head.length() == hash_length and head.is_valid_hex_number():
			hash = head

	# Show version
	var version_string: String = (
		Version.pretty_name + " "
		+ str(Version.major) + "."
		+ str(Version.minor) + "."
		+ str(Version.patch) + "-"
		+ Version.status
	)
	if not hash.is_empty():
		version_string += "." + hash.substr(0, n_hash_characters_to_show)

	text = version_string
