# GDScript Linter - Style checker (magic numbers, commented code, type hints)
# https://poplava.itch.io
class_name GDLintStyleChecker
extends RefCounted

const Loc = preload("res://addons/gdscript-linter/ui/localization.gd")

var config


func _init(p_config) -> void:
	config = p_config


# Performs all line-level style checks in one pass
func check_line(line: String, trimmed: String, line_num: int, file_result) -> Array:
	var issues: Array = []

	_append_issue(issues, _check_long_line(line, line_num))
	_append_issue(issues, _check_todo_comments(trimmed, line_num))
	_append_issue(issues, _check_print_statements(trimmed, line_num))
	_track_metadata(trimmed, file_result)
	_append_issue(issues, _check_magic_numbers(trimmed, line_num))
	_append_issue(issues, _check_commented_code(trimmed, line_num))
	_append_issue(issues, _check_type_hints(trimmed, line_num))
	_append_issue(issues, _check_reflection_calls(trimmed, line_num))

	return issues


func _append_issue(issues: Array, issue) -> void:
	if issue:
		issues.append(issue)


func _check_long_line(line: String, line_num: int) -> Variant:
	if not config.check_long_lines:
		return null
	if line.length() <= config.max_line_length:
		return null
	return {
		"line": line_num,
		"severity": "info",
		"check_id": "long-line",
		"message": "Line exceeds %d chars (%d)" % [config.max_line_length, line.length()]
	}


func _check_todo_comments(trimmed: String, line_num: int) -> Variant:
	if not config.check_todo_comments:
		return null
	return check_todo_comments(trimmed, line_num)


func _check_print_statements(trimmed: String, line_num: int) -> Variant:
	if not config.check_print_statements:
		return null
	return check_print_statements(trimmed, line_num)


func _check_magic_numbers(trimmed: String, line_num: int) -> Variant:
	if not config.check_magic_numbers:
		return null
	return check_magic_numbers(trimmed, line_num)


func _check_commented_code(trimmed: String, line_num: int) -> Variant:
	if not config.check_commented_code:
		return null
	return check_commented_code(trimmed, line_num)


func _check_type_hints(trimmed: String, line_num: int) -> Variant:
	if not config.check_missing_types:
		return null
	return check_variable_type_hints(trimmed, line_num)


func _check_reflection_calls(trimmed: String, line_num: int) -> Variant:
	if not config.check_reflection_calls:
		return null
	return check_reflection_calls(trimmed, line_num)


func _track_metadata(trimmed: String, file_result) -> void:
	# Track signals
	if trimmed.begins_with("signal "):
		var signal_name := trimmed.substr(7).split("(")[0].strip_edges()
		file_result.signals_found.append(signal_name)

	# Track dependencies
	if trimmed.begins_with("preload(") or trimmed.begins_with("load("):
		var dep := _extract_string_arg(trimmed)
		if dep:
			file_result.dependencies.append(dep)


func _extract_string_arg(line: String) -> String:
	var start := line.find("\"")
	var end := line.rfind("\"")
	if start >= 0 and end > start:
		return line.substr(start + 1, end - start - 1)
	return ""


# Returns issue dictionary or null
func check_magic_numbers(line: String, line_num: int) -> Variant:
	# Skip comments, const declarations, and common safe patterns
	if line.begins_with("#") or line.begins_with("const "):
		return null
	if "enum " in line or "@export" in line:
		return null

	var regex := RegEx.new()
	regex.compile("(?<![a-zA-Z_])(-?\\d+\\.?\\d*)(?![a-zA-Z_\\d])")

	for regex_match in regex.search_all(line):
		var num_str: String = regex_match.get_string()
		var num_val: float = float(num_str)

		# Skip allowed numbers
		if num_val in config.allowed_numbers:
			continue

		# Skip if it's part of a variable name or in a string
		var pos: int = regex_match.get_start()
		if pos > 0 and line[pos - 1] == '"':
			continue

		return {
			"line": line_num,
			"severity": "info",
			"check_id": "magic-number",
			"message": "Magic number %s (consider using a named constant)" % num_str
		}

	return null


# Returns issue dictionary or null
func check_commented_code(line: String, line_num: int) -> Variant:
	for pattern in config.commented_code_patterns:
		if line.begins_with(pattern) or ("\t" + pattern) in line or (" " + pattern) in line:
			return {
				"line": line_num,
				"severity": "info",
				"check_id": "commented-code",
				"message": "Commented-out code detected"
			}
	return null


# Returns issue dictionary or null
func check_variable_type_hints(line: String, line_num: int) -> Variant:
	# Check for untyped variable declarations
	if not line.begins_with("var ") and not line.begins_with("\tvar "):
		return null

	# Skip if it has a type annotation
	if ":" in line.split("=")[0]:
		return null

	# Skip @onready and inferred types from literals
	if "@onready" in line:
		return null

	# Extract variable name
	var after_var := line.strip_edges().substr(4)  # After "var "
	var var_name := after_var.split("=")[0].split(":")[0].strip_edges()

	return {
		"line": line_num,
		"severity": "info",
		"check_id": "missing-type-hint",
		"message": "Variable '%s' has no type annotation" % var_name
	}


# Returns issue dictionary or null
func check_reflection_calls(line: String, line_num: int) -> Variant:
	if line.begins_with("#"):
		return null

	var code := _strip_string_literals(line)
	for method_name in config.reflection_call_patterns:
		if _contains_function_call(code, method_name):
			return {
				"line": line_num,
				"severity": "warning",
				"check_id": "reflection-call",
				"message": Loc.t("reflection_message") % method_name
			}
	return null


# Returns issue dictionary or null
func check_todo_comments(trimmed: String, line_num: int) -> Variant:
	for pattern in config.todo_patterns:
		if pattern in trimmed:
			var severity := "info" if pattern == "TODO" else "warning"
			var comment_text := trimmed.substr(trimmed.find(pattern) + pattern.length()).strip_edges()
			if comment_text.begins_with(":"):
				comment_text = comment_text.substr(1).strip_edges()
			return {
				"line": line_num,
				"severity": severity,
				"check_id": "todo-comment",
				"message": "%s: %s" % [pattern, comment_text]
			}
	return null


# Returns issue dictionary or null
func check_print_statements(trimmed: String, line_num: int) -> Variant:
	var is_whitelisted := false
	for whitelist_item in config.print_whitelist:
		if whitelist_item in trimmed:
			is_whitelisted = true
			break

	if not is_whitelisted:
		for pattern in config.print_patterns:
			if pattern in trimmed and not trimmed.begins_with("#"):
				return {
					"line": line_num,
					"severity": "warning",
					"check_id": "print-statement",
					"message": "Debug print statement: %s" % trimmed.substr(0, mini(60, trimmed.length()))
				}
	return null


func _strip_string_literals(line: String) -> String:
	var result := ""
	var in_string := false
	var quote := ""
	var escaped := false

	for i in range(line.length()):
		var ch := line[i]

		if in_string:
			if escaped:
				escaped = false
			elif ch == "\\":
				escaped = true
			elif ch == quote:
				in_string = false
				quote = ""
			result += " "
			continue

		if ch == "\"" or ch == "'":
			in_string = true
			quote = ch
			result += " "
			continue

		result += ch

	return result


func _contains_function_call(code: String, method_name: String) -> bool:
	var search_from := 0
	while search_from < code.length():
		var pos := code.find(method_name, search_from)
		if pos < 0:
			return false

		if _is_word_boundary_before(code, pos) and _has_call_parenthesis_after(code, pos + method_name.length()):
			if not _is_function_declaration(code, method_name):
				return true

		search_from = pos + method_name.length()

	return false


func _is_word_boundary_before(code: String, pos: int) -> bool:
	if pos <= 0:
		return true

	var prev := code[pos - 1]
	return not _is_identifier_char(prev)


func _has_call_parenthesis_after(code: String, pos: int) -> bool:
	var i := pos
	while i < code.length() and (code[i] == " " or code[i] == "\t"):
		i += 1

	return i < code.length() and code[i] == "("


func _is_function_declaration(code: String, method_name: String) -> bool:
	return code.strip_edges().begins_with("func %s" % method_name)


func _is_identifier_char(ch: String) -> bool:
	return (ch >= "a" and ch <= "z") or (ch >= "A" and ch <= "Z") or (ch >= "0" and ch <= "9") or ch == "_"
