# GDScript Linter - Settings Card UI Builder
# https://poplava.itch.io
@tool
extends RefCounted
class_name GDLintSettingsCardBuilder
## Creates settings panel cards with consistent styling

const Loc = preload("res://addons/gdscript-linter/ui/localization.gd")

# Default analysis limits
const DEFAULT_FILE_LINES_SOFT := 200
const DEFAULT_FILE_LINES_HARD := 300
const DEFAULT_FUNC_LINES := 30
const DEFAULT_FUNC_LINES_CRIT := 60
const DEFAULT_COMPLEXITY_WARN := 10
const DEFAULT_COMPLEXITY_CRIT := 15
const DEFAULT_MAX_PARAMS := 4
const DEFAULT_MAX_NESTING := 3
const DEFAULT_GOD_CLASS_FUNCS := 20
const DEFAULT_GOD_CLASS_SIGNALS := 10

var _reset_icon: Texture2D
var _claude_card_builder: GDLintClaudeCodeCardBuilder
var _help_card_builder: GDLintHelpCardBuilder


func _init(reset_icon: Texture2D) -> void:
	_reset_icon = reset_icon
	_claude_card_builder = GDLintClaudeCodeCardBuilder.new(reset_icon)
	_help_card_builder = GDLintHelpCardBuilder.new()


# Creates the standard card style used by all settings cards
static func create_card_style() -> StyleBoxFlat:
	return GDLintThemeColors.create_card_style()


# Creates the scroll container wrapper for settings panel
func build_settings_panel(settings_panel: PanelContainer, controls: Dictionary) -> void:
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED

	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	scroll.add_child(margin)

	var cards_vbox := VBoxContainer.new()
	cards_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cards_vbox.add_theme_constant_override("separation", 10)
	margin.add_child(cards_vbox)

	# Header bar (non-collapsible)
	cards_vbox.add_child(create_header_bar())

	# Collapsible cards (all collapsed by default)
	cards_vbox.add_child(create_display_options_card(controls))
	cards_vbox.add_child(create_export_options_card(controls))
	cards_vbox.add_child(create_scan_options_card(controls))
	cards_vbox.add_child(create_code_checks_card(controls))
	cards_vbox.add_child(create_limits_card(controls))
	settings_panel.add_child(scroll)
	settings_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL


# Create Display Options collapsible card with checkboxes
func create_display_options_card(controls: Dictionary) -> GDLintCollapsibleCard:
	var card := GDLintCollapsibleCard.new(Loc.t("display_options"), "code_quality/ui/display_options_collapsed")
	var vbox := card.get_content_container()

	# Row of checkboxes for display toggles
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	vbox.add_child(hbox)

	controls.show_issues_check = _create_checkbox(Loc.t("show_issues"), hbox)
	controls.show_debt_check = _create_checkbox(Loc.t("show_debt"), hbox)
	controls.show_ignored_check = _create_checkbox(Loc.t("show_ignored"), hbox)
	controls.show_full_path_check = _create_checkbox(Loc.t("show_full_path"), hbox)

	var language_row := HBoxContainer.new()
	language_row.add_theme_constant_override("separation", 8)
	vbox.add_child(language_row)

	var language_label := Label.new()
	language_label.text = Loc.t("language") + ":"
	language_row.add_child(language_label)

	controls.language_option = OptionButton.new()
	controls.language_option.add_item(Loc.t("language_auto"), 0)
	controls.language_option.set_item_metadata(0, "auto")
	controls.language_option.add_item(Loc.t("language_ru"), 1)
	controls.language_option.set_item_metadata(1, "ru")
	controls.language_option.add_item(Loc.t("language_en"), 2)
	controls.language_option.set_item_metadata(2, "en")
	language_row.add_child(controls.language_option)

	return card


# Create Export Options collapsible card
func create_export_options_card(controls: Dictionary) -> GDLintCollapsibleCard:
	var card := GDLintCollapsibleCard.new(Loc.t("export_options"), "code_quality/ui/export_options_collapsed")
	var vbox := card.get_content_container()

	# Row 1: Export visibility toggles
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	vbox.add_child(hbox)

	controls.show_json_export_check = _create_checkbox(Loc.t("show_json_export"), hbox)
	controls.show_html_export_check = _create_checkbox(Loc.t("show_html_export"), hbox)
	controls.show_md_export_check = _create_checkbox(Loc.t("show_md_export"), hbox)

	# Separator
	vbox.add_child(HSeparator.new())

	# Row 2: Export behavior toggles
	var options_hbox := HBoxContainer.new()
	options_hbox.add_theme_constant_override("separation", 15)
	vbox.add_child(options_hbox)

	controls.filter_exports_check = _create_checkbox(Loc.t("filter_exports"), options_hbox)

	# Separator
	vbox.add_child(HSeparator.new())

	# Row 3: Export folder path
	var folder_hbox := HBoxContainer.new()
	folder_hbox.add_theme_constant_override("separation", 8)
	vbox.add_child(folder_hbox)

	var folder_label := Label.new()
	folder_label.text = Loc.t("export_folder")
	folder_hbox.add_child(folder_label)

	controls.export_folder_edit = LineEdit.new()
	controls.export_folder_edit.placeholder_text = "res:// (project root)"
	controls.export_folder_edit.custom_minimum_size = Vector2(160, 0)
	controls.export_folder_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	controls.export_folder_edit.tooltip_text = Loc.t("export_folder")
	folder_hbox.add_child(controls.export_folder_edit)

	controls.export_folder_btn = Button.new()
	controls.export_folder_btn.text = Loc.t("browse")
	controls.export_folder_btn.flat = true
	controls.export_folder_btn.tooltip_text = Loc.t("browse")
	folder_hbox.add_child(controls.export_folder_btn)

	controls.export_folder_reset_btn = Button.new()
	controls.export_folder_reset_btn.icon = _reset_icon
	controls.export_folder_reset_btn.flat = true
	controls.export_folder_reset_btn.tooltip_text = Loc.t("reset_all")
	controls.export_folder_reset_btn.custom_minimum_size = Vector2(16, 16)
	folder_hbox.add_child(controls.export_folder_reset_btn)

	return card


# Create Scan Options collapsible card
func create_scan_options_card(controls: Dictionary) -> GDLintCollapsibleCard:
	var card := GDLintCollapsibleCard.new(Loc.t("scan_options"), "code_quality/ui/scan_options_collapsed")
	var vbox := card.get_content_container()

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	vbox.add_child(hbox)

	controls.respect_gdignore_check = _create_checkbox(Loc.t("respect_gdignore"), hbox)
	controls.scan_addons_check = _create_checkbox(Loc.t("scan_addons"), hbox)
	controls.remember_filters_check = _create_checkbox(Loc.t("remember_filters"), hbox)

	vbox.add_child(HSeparator.new())

	var path_hbox := HBoxContainer.new()
	path_hbox.add_theme_constant_override("separation", 8)
	vbox.add_child(path_hbox)

	var path_label := Label.new()
	path_label.text = Loc.t("scan_path")
	path_hbox.add_child(path_label)

	controls.scan_path_edit = LineEdit.new()
	controls.scan_path_edit.placeholder_text = Loc.t("scan_path_placeholder")
	controls.scan_path_edit.tooltip_text = Loc.t("scan_path_tooltip")
	controls.scan_path_edit.custom_minimum_size = Vector2(220, 0)
	controls.scan_path_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	path_hbox.add_child(controls.scan_path_edit)

	controls.scan_path_reset_btn = Button.new()
	controls.scan_path_reset_btn.icon = _reset_icon
	controls.scan_path_reset_btn.flat = true
	controls.scan_path_reset_btn.tooltip_text = Loc.t("reset_all")
	controls.scan_path_reset_btn.custom_minimum_size = Vector2(16, 16)
	path_hbox.add_child(controls.scan_path_reset_btn)

	vbox.add_child(HSeparator.new())

	# Row: Include Addons
	var include_hbox := HBoxContainer.new()
	include_hbox.add_theme_constant_override("separation", 8)
	vbox.add_child(include_hbox)

	var include_label := Label.new()
	include_label.text = "Include Addons:"
	include_hbox.add_child(include_label)

	controls.included_addons_edit = LineEdit.new()
	controls.included_addons_edit.placeholder_text = "addon1, addon2  (empty = use Scan addons/ checkbox)"
	controls.included_addons_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	controls.included_addons_edit.tooltip_text = "Scan ONLY these addon folders (comma-separated names). Overrides 'Scan addons/' when non-empty."
	include_hbox.add_child(controls.included_addons_edit)

	controls.included_addons_reset_btn = Button.new()
	controls.included_addons_reset_btn.icon = _reset_icon
	controls.included_addons_reset_btn.flat = true
	controls.included_addons_reset_btn.tooltip_text = "Clear (use Scan addons/ checkbox)"
	controls.included_addons_reset_btn.custom_minimum_size = Vector2(16, 16)
	include_hbox.add_child(controls.included_addons_reset_btn)

	# Row: Exclude Addons
	var exclude_hbox := HBoxContainer.new()
	exclude_hbox.add_theme_constant_override("separation", 8)
	vbox.add_child(exclude_hbox)

	var exclude_label := Label.new()
	exclude_label.text = "Exclude Addons:"
	exclude_hbox.add_child(exclude_label)

	controls.excluded_addons_edit = LineEdit.new()
	controls.excluded_addons_edit.placeholder_text = "addon1, addon2  (empty = exclude none)"
	controls.excluded_addons_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	controls.excluded_addons_edit.tooltip_text = "Skip these addon folders (comma-separated). Applies when Include Addons is empty and 'Scan addons/' is enabled."
	exclude_hbox.add_child(controls.excluded_addons_edit)

	controls.excluded_addons_reset_btn = Button.new()
	controls.excluded_addons_reset_btn.icon = _reset_icon
	controls.excluded_addons_reset_btn.flat = true
	controls.excluded_addons_reset_btn.tooltip_text = "Clear (exclude no addons)"
	controls.excluded_addons_reset_btn.custom_minimum_size = Vector2(16, 16)
	exclude_hbox.add_child(controls.excluded_addons_reset_btn)

	return card


# Create Code Checks collapsible card with toggles for all analysis checks
func create_code_checks_card(controls: Dictionary) -> GDLintCollapsibleCard:
	var card := GDLintCollapsibleCard.new(Loc.t("code_checks"), "code_quality/ui/code_checks_collapsed")
	var vbox := card.get_content_container()

	# Enable All / Disable All buttons row
	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 8)
	vbox.add_child(btn_row)

	controls.enable_all_checks_btn = Button.new()
	controls.enable_all_checks_btn.text = Loc.t("enable_all")
	controls.enable_all_checks_btn.flat = true
	controls.enable_all_checks_btn.tooltip_text = Loc.t("enable_all")
	btn_row.add_child(controls.enable_all_checks_btn)

	controls.disable_all_checks_btn = Button.new()
	controls.disable_all_checks_btn.text = Loc.t("disable_all")
	controls.disable_all_checks_btn.flat = true
	controls.disable_all_checks_btn.tooltip_text = Loc.t("disable_all")
	btn_row.add_child(controls.disable_all_checks_btn)

	# Naming section
	_add_section_header(vbox, Loc.t("naming"))
	var naming_grid := _create_check_grid(vbox)
	controls.check_naming_conventions = _add_check_to_grid(naming_grid, Loc.t("naming_conventions"),
		"Check class, function, signal, const, and enum naming")

	# Style section
	_add_section_header(vbox, Loc.t("style"))
	var style_grid := _create_check_grid(vbox)
	controls.check_long_lines = _add_check_to_grid(style_grid, Loc.t("long_line"),
		"Lines exceeding max length")
	controls.check_todo_comments = _add_check_to_grid(style_grid, Loc.t("todo_fixme"),
		"TODO, FIXME, HACK, etc.")
	controls.check_print_statements = _add_check_to_grid(style_grid, Loc.t("print_statement"),
		"Debug print statements")
	controls.check_magic_numbers = _add_check_to_grid(style_grid, Loc.t("magic_number"),
		"Hardcoded numbers")
	controls.check_commented_code = _add_check_to_grid(style_grid, Loc.t("commented_code"),
		"Commented-out code blocks")
	controls.check_missing_types = _add_check_to_grid(style_grid, Loc.t("missing_type_hint"),
		"Variables without type hints")
	controls.check_reflection_calls = _add_check_to_grid(style_grid, Loc.t("reflection_call"),
		"Dynamic Object APIs such as call(), call_deferred(), has_method(), and emit_signal()")

	# Functions section
	_add_section_header(vbox, Loc.t("functions"))
	var funcs_grid := _create_check_grid(vbox)
	controls.check_function_length = _add_check_to_grid(funcs_grid, Loc.t("long_function"),
		"Functions exceeding line limits")
	controls.check_parameters = _add_check_to_grid(funcs_grid, Loc.t("too_many_params"),
		"Functions with too many parameters")
	controls.check_nesting = _add_check_to_grid(funcs_grid, Loc.t("deep_nesting"),
		"Excessive nesting depth")
	controls.check_cyclomatic_complexity = _add_check_to_grid(funcs_grid, Loc.t("high_complexity"),
		"High cyclomatic complexity")
	controls.check_empty_functions = _add_check_to_grid(funcs_grid, Loc.t("empty_function"),
		"Functions with no implementation")
	controls.check_missing_return_type = _add_check_to_grid(funcs_grid, Loc.t("missing_return_type"),
		"Public functions without return type")

	# Structure section
	_add_section_header(vbox, Loc.t("structure"))
	var struct_grid := _create_check_grid(vbox)
	controls.check_file_length = _add_check_to_grid(struct_grid, Loc.t("file_length"),
		"Files exceeding line limits")
	controls.check_god_class = _add_check_to_grid(struct_grid, Loc.t("god_class"),
		"Classes with too many members")
	controls.check_unused_variables = _add_check_to_grid(struct_grid, Loc.t("unused_variable"),
		"Local variables never used")
	controls.check_unused_parameters = _add_check_to_grid(struct_grid, Loc.t("unused_parameter"),
		"Function parameters never used")

	# Defensive section
	_add_section_header(vbox, Loc.t("defensive"))
	var def_grid := _create_check_grid(vbox)
	controls.check_ascii_only = _add_check_to_grid(def_grid, Loc.t("ascii_violation"),
		"Enforce ASCII-only in attributed files")
	controls.check_strict_limits = _add_check_to_grid(def_grid, Loc.t("strict_limit"),
		"Enforce stricter thresholds via directives")
	controls.check_sealed = _add_check_to_grid(def_grid, Loc.t("sealed_violation"),
		"Prevent inheritance of sealed classes")

	return card


# Helper to add a section header label
func _add_section_header(container: VBoxContainer, text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", GDLintThemeColors.get_color("font_muted"))
	container.add_child(label)


# Helper to create a 2-column grid for checkboxes
func _create_check_grid(container: VBoxContainer) -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 20)
	grid.add_theme_constant_override("v_separation", 4)
	container.add_child(grid)
	return grid


# Helper to add a checkbox to a grid
func _add_check_to_grid(grid: GridContainer, label_text: String, tooltip: String) -> CheckBox:
	var check := CheckBox.new()
	check.text = label_text
	check.tooltip_text = tooltip if Loc.get_language() == "en" else label_text
	check.button_pressed = true  # Default to enabled
	check.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var font_color: Color = EditorInterface.get_editor_theme().get_color("font_color", "Editor")
	check.add_theme_color_override("font_pressed_color", font_color)
	grid.add_child(check)
	return check


# Create Analysis Limits collapsible card with spinboxes
func create_limits_card(controls: Dictionary) -> GDLintCollapsibleCard:
	var card := GDLintCollapsibleCard.new(Loc.t("analysis_limits"), "code_quality/ui/limits_collapsed")
	var vbox := card.get_content_container()

	# Reset All button row
	var reset_row := HBoxContainer.new()
	reset_row.add_theme_constant_override("separation", 8)
	vbox.add_child(reset_row)

	var reset_all_btn := Button.new()
	reset_all_btn.icon = _reset_icon
	reset_all_btn.text = Loc.t("reset_all")
	reset_all_btn.tooltip_text = Loc.t("reset_all")
	reset_all_btn.flat = true
	controls.reset_all_limits_btn = reset_all_btn
	reset_row.add_child(reset_all_btn)

	# Grid for spinboxes (6 columns: label, spin, reset, label, spin, reset)
	var grid := GridContainer.new()
	grid.columns = 6
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	vbox.add_child(grid)

	# Row 1: File lines soft/hard
	controls.max_lines_soft_spin = _add_spin_row(grid, Loc.t("file_lines_warn"), 50, 1000, DEFAULT_FILE_LINES_SOFT, DEFAULT_FILE_LINES_SOFT)
	controls.max_lines_hard_spin = _add_spin_row(grid, Loc.t("file_lines_crit"), 100, 2000, DEFAULT_FILE_LINES_HARD, DEFAULT_FILE_LINES_HARD)

	# Row 2: Function lines / complexity warning
	controls.max_func_lines_spin = _add_spin_row(grid, Loc.t("func_lines"), 10, 200, DEFAULT_FUNC_LINES, DEFAULT_FUNC_LINES)
	controls.max_complexity_spin = _add_spin_row(grid, Loc.t("complexity_warn"), 5, 50, DEFAULT_COMPLEXITY_WARN, DEFAULT_COMPLEXITY_WARN)

	# Row 3: Func lines critical / complexity critical
	controls.func_lines_crit_spin = _add_spin_row(grid, Loc.t("func_lines_crit"), 20, 300, DEFAULT_FUNC_LINES_CRIT, DEFAULT_FUNC_LINES_CRIT)
	controls.max_complexity_crit_spin = _add_spin_row(grid, Loc.t("complexity_crit"), 5, 50, DEFAULT_COMPLEXITY_CRIT, DEFAULT_COMPLEXITY_CRIT)

	# Row 4: Max params / nesting
	controls.max_params_spin = _add_spin_row(grid, Loc.t("max_params"), 2, 15, DEFAULT_MAX_PARAMS, DEFAULT_MAX_PARAMS)
	controls.max_nesting_spin = _add_spin_row(grid, Loc.t("max_nesting"), 2, 10, DEFAULT_MAX_NESTING, DEFAULT_MAX_NESTING)

	# Row 5: God class thresholds
	controls.god_class_funcs_spin = _add_spin_row(grid, Loc.t("god_class_funcs"), 5, 50, DEFAULT_GOD_CLASS_FUNCS, DEFAULT_GOD_CLASS_FUNCS)
	controls.god_class_signals_spin = _add_spin_row(grid, Loc.t("god_class_signals"), 3, 30, DEFAULT_GOD_CLASS_SIGNALS, DEFAULT_GOD_CLASS_SIGNALS)

	return card


# Create CLI Options collapsible card
func create_cli_options_card(controls: Dictionary) -> GDLintCollapsibleCard:
	var card := GDLintCollapsibleCard.new("CLI Options", "code_quality/ui/cli_options_collapsed")
	var vbox := card.get_content_container()

	# Export config row
	var export_row := HBoxContainer.new()
	export_row.add_theme_constant_override("separation", 8)
	vbox.add_child(export_row)

	controls.export_config_btn = Button.new()
	controls.export_config_btn.text = "Export Config..."
	controls.export_config_btn.flat = true
	controls.export_config_btn.tooltip_text = "Export settings to a custom JSON file (for CI/CD or alternate configs)"
	export_row.add_child(controls.export_config_btn)

	var info_label := Label.new()
	info_label.text = "(Settings auto-sync to gdlint.json)"
	info_label.add_theme_color_override("font_color", GDLintThemeColors.get_color("font_muted"))
	info_label.add_theme_font_size_override("font_size", 12)
	export_row.add_child(info_label)

	return card


# Create header bar with title and links (non-collapsible)
func create_header_bar() -> HBoxContainer:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 0)

	# Title: "GDScript Linter" in accent color
	var title := Label.new()
	title.text = "GDScript Linter"
	title.add_theme_font_size_override("font_size", 17)
	title.add_theme_color_override("font_color", GDLintThemeColors.get_color("accent"))
	hbox.add_child(title)

	# Subtitle: " - Code Quality Analyzer for GDScript" in muted color
	var subtitle := Label.new()
	subtitle.text = Loc.t("addon_subtitle")
	subtitle.add_theme_font_size_override("font_size", 17)
	# No color override - inherits default editor font color
	hbox.add_child(subtitle)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer)

	return hbox


# Helper to create a checkbox and add it to a container
func _create_checkbox(label_text: String, container: HBoxContainer, tooltip: String = "") -> CheckBox:
	var check := CheckBox.new()
	check.text = label_text
	if tooltip != "":
		check.tooltip_text = tooltip
	else:
		check.tooltip_text = label_text
	var font_color: Color = EditorInterface.get_editor_theme().get_color("font_color", "Editor")
	check.add_theme_color_override("font_pressed_color", font_color)
	container.add_child(check)
	return check


# Helper to add a label + spinbox + reset button to a grid
func _add_spin_row(grid: GridContainer, label_text: String, min_val: int, max_val: int, current_val: int, default_val: int) -> SpinBox:
	var label := Label.new()
	label.text = label_text
	grid.add_child(label)

	var spin := SpinBox.new()
	spin.min_value = min_val
	spin.max_value = max_val
	spin.value = current_val
	spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_child(spin)

	var reset_btn := Button.new()
	reset_btn.icon = _reset_icon
	reset_btn.tooltip_text = Loc.t("reset_default") % default_val
	reset_btn.flat = true
	reset_btn.custom_minimum_size = Vector2(16, 16)
	reset_btn.pressed.connect(func(): spin.value = default_val)
	grid.add_child(reset_btn)

	return spin


# Create Help collapsible card
func _create_help_card() -> GDLintCollapsibleCard:
	var card := GDLintCollapsibleCard.new(Loc.t("help"), "code_quality/ui/help_collapsed")
	_help_card_builder.create_card_content(card.get_content_container())
	return card
