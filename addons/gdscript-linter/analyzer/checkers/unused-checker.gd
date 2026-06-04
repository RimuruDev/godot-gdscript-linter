# GDScript Linter - Unused variable/parameter checker
# https://poplava.itch.io
class_name GDLintUnusedChecker
extends RefCounted

var config
var _declarations: Array = []


func _init(p_config) -> void:
	config = p_config


# Check for unused variables and parameters, calls add_issue_callback for each finding
func check_unused(lines: Array, add_issue_callback: Callable) -> void:
	if not config.check_unused_variables and not config.check_unused_parameters:
		return

	_declarations.clear()

	# Pass 1: Collect all declarations
	_collect_declarations(lines)

	# Pass 2: Find usages
	_find_usages(lines)

	# Pass 3: Report unused
	_report_unused(add_issue_callback)


func _collect_declarations(lines: Array) -> void:
	var in_function := false
	var current_func_name := ""

	for i in range(lines.size()):
		var line: String = lines[i]
		var trimmed := line.strip_edges()
		var line_num := i + 1

		# Track function boundaries
		if trimmed.begins_with("func "):
			in_function = true
			current_func_name = _extract_func_name(trimmed)

			# Extract parameters if enabled
			if config.check_unused_parameters:
				_extract_parameters(trimmed, line_num, current_func_name)

		# Skip class-level variables (only check local variables inside functions)
		if not in_function:
			continue

		# Check for variable declarations
		if config.check_unused_variables:
			_extract_variable_declaration(lines, i, trimmed, line_num)
			_extract_for_loop_variable(trimmed, line_num)


func _extract_func_name(line: String) -> String:
	var after_func := line.substr(5)  # After "func "
	var paren_pos := after_func.find("(")
	if paren_pos > 0:
		return after_func.substr(0, paren_pos).strip_edges()
	return ""


func _extract_parameters(line: String, line_num: int, func_name: String) -> void:
	# Skip built-in virtual methods where parameters may be intentionally unused
	var virtual_methods := ["_ready", "_process", "_physics_process", "_input",
		"_unhandled_input", "_gui_input", "_notification", "_draw", "_enter_tree",
		"_exit_tree", "_init", "_get", "_set", "_get_property_list"]
	if func_name in virtual_methods:
		return

	var params_start := line.find("(")
	if params_start < 0:
		return
	var params_end := _find_matching_closing_paren(line, params_start)
	if params_end < 0 or params_end <= params_start:
		return

	var params_str := line.substr(params_start + 1, params_end - params_start - 1).strip_edges()
	if params_str.is_empty():
		return

	var params := _split_parameters(params_str)
	for param in params:
		var param_name := _extract_param_name(param.strip_edges())
		if param_name.is_empty():
			continue

		# Skip underscore-prefixed if configured
		if config.ignore_underscore_prefix and param_name.begins_with("_"):
			continue

		_declarations.append({
			"name": param_name,
			"line": line_num,
			"type": "parameter",
			"used": false
		})


func _extract_param_name(param: String) -> String:
	var param_name := param

	# Remove default value
	var eq_pos := param_name.find("=")
	if eq_pos > 0:
		param_name = param_name.substr(0, eq_pos)

	# Remove type annotation
	var colon_pos := param_name.find(":")
	if colon_pos > 0:
		param_name = param_name.substr(0, colon_pos)

	return param_name.strip_edges()


func _extract_variable_declaration(lines: Array, line_index: int, line: String, line_num: int) -> void:
	# Skip @export variables (used by editor)
	if "@export" in line:
		return

	var var_regex := RegEx.new()
	var_regex.compile("^\\s*(?:@onready\\s+)?var\\s+(\\w+)")

	var match_result := var_regex.search(line)
	if match_result:
		var var_name := match_result.get_string(1)

		if _is_property_with_accessor(lines, line_index):
			return

		# Skip underscore-prefixed if configured
		if config.ignore_underscore_prefix and var_name.begins_with("_"):
			return

		_declarations.append({
			"name": var_name,
			"line": line_num,
			"type": "variable",
			"used": false
		})


func _is_property_with_accessor(lines: Array, line_index: int) -> bool:
	var line := _remove_string_literals(str(lines[line_index]))
	var accessor_regex := RegEx.new()
	accessor_regex.compile("(^|\\s)(get|set)\\s*:")

	if accessor_regex.search(line):
		return true

	var trimmed := line.strip_edges()
	if not trimmed.ends_with(":"):
		return false

	var base_indent := _get_indent_width(str(lines[line_index]))
	for i in range(line_index + 1, lines.size()):
		var next_line := str(lines[i])
		var next_trimmed := next_line.strip_edges()
		if next_trimmed.is_empty() or next_trimmed.begins_with("#"):
			continue

		if _get_indent_width(next_line) <= base_indent:
			return false

		return accessor_regex.search(_remove_string_literals(next_line)) != null

	return false


func _get_indent_width(line: String) -> int:
	var width := 0
	for i in range(line.length()):
		var ch := line.substr(i, 1)
		if ch == "\t":
			width += 4
		elif ch == " ":
			width += 1
		else:
			break
	return width


func _extract_for_loop_variable(line: String, line_num: int) -> void:
	var for_regex := RegEx.new()
	for_regex.compile("^\\s*for\\s+(\\w+)\\s+in\\s+")

	var match_result := for_regex.search(line)
	if match_result:
		var var_name := match_result.get_string(1)

		# Skip underscore-prefixed if configured
		if config.ignore_underscore_prefix and var_name.begins_with("_"):
			return

		_declarations.append({
			"name": var_name,
			"line": line_num,
			"type": "for_loop",
			"used": false
		})


func _find_usages(lines: Array) -> void:
	for decl in _declarations:
		var decl_name: String = decl.name
		var decl_line: int = decl.line

		var usage_regex := RegEx.new()
		usage_regex.compile("\\b" + decl_name + "\\b")

		for i in range(lines.size()):
			var line: String = lines[i]
			var line_num := i + 1

			# Skip the declaration line itself
			if line_num == decl_line:
				continue

			# Skip comments
			var trimmed := line.strip_edges()
			if trimmed.begins_with("#"):
				continue

			# Remove string literals to avoid false positives
			var line_no_strings := _remove_string_literals(line)

			# Remove comments from the line
			var comment_pos := line_no_strings.find("#")
			if comment_pos >= 0:
				line_no_strings = line_no_strings.substr(0, comment_pos)

			# Check for usage
			if usage_regex.search(line_no_strings):
				decl.used = true
				break


func _remove_string_literals(line: String) -> String:
	var result := line

	var dq_regex := RegEx.new()
	dq_regex.compile("\"[^\"]*\"")
	result = dq_regex.sub(result, "\"\"", true)

	var sq_regex := RegEx.new()
	sq_regex.compile("'[^']*'")
	result = sq_regex.sub(result, "''", true)

	return result


func _find_matching_closing_paren(text: String, open_index: int) -> int:
	var paren_depth := 0
	var square_depth := 0
	var brace_depth := 0
	var in_string := false
	var string_quote := ""
	var escaped := false

	for i in range(open_index, text.length()):
		var ch := text.substr(i, 1)

		if in_string:
			if escaped:
				escaped = false
			elif ch == "\\":
				escaped = true
			elif ch == string_quote:
				in_string = false
			continue

		if ch == "\"" or ch == "'":
			in_string = true
			string_quote = ch
			continue

		match ch:
			"(":
				paren_depth += 1
			")":
				paren_depth -= 1
				if paren_depth == 0 and square_depth == 0 and brace_depth == 0:
					return i
			"[":
				square_depth += 1
			"]":
				square_depth = max(0, square_depth - 1)
			"{":
				brace_depth += 1
			"}":
				brace_depth = max(0, brace_depth - 1)

	return -1


func _split_parameters(params: String) -> Array[String]:
	var result: Array[String] = []
	var start := 0
	var paren_depth := 0
	var square_depth := 0
	var brace_depth := 0
	var in_string := false
	var string_quote := ""
	var escaped := false

	for i in range(params.length()):
		var ch := params.substr(i, 1)

		if in_string:
			if escaped:
				escaped = false
			elif ch == "\\":
				escaped = true
			elif ch == string_quote:
				in_string = false
			continue

		if ch == "\"" or ch == "'":
			in_string = true
			string_quote = ch
			continue

		match ch:
			"(":
				paren_depth += 1
			")":
				paren_depth = max(0, paren_depth - 1)
			"[":
				square_depth += 1
			"]":
				square_depth = max(0, square_depth - 1)
			"{":
				brace_depth += 1
			"}":
				brace_depth = max(0, brace_depth - 1)
			",":
				if paren_depth == 0 and square_depth == 0 and brace_depth == 0:
					result.append(params.substr(start, i - start).strip_edges())
					start = i + 1

	result.append(params.substr(start).strip_edges())
	return result


func _report_unused(add_issue_callback: Callable) -> void:
	for decl in _declarations:
		if decl.used:
			continue

		var decl_type: String = decl.type
		var decl_name: String = decl.name
		var decl_line: int = decl.line

		match decl_type:
			"variable":
				if config.check_unused_variables:
					add_issue_callback.call(decl_line, "warning", "unused-variable",
						"Variable '%s' is declared but never used" % decl_name)
			"parameter":
				if config.check_unused_parameters:
					add_issue_callback.call(decl_line, "info", "unused-parameter",
						"Parameter '%s' is declared but never used" % decl_name)
			"for_loop":
				if config.check_unused_variables:
					add_issue_callback.call(decl_line, "warning", "unused-variable",
						"Loop variable '%s' is declared but never used" % decl_name)
