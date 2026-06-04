# GDScript Linter - Studio localization helper
@tool
extends RefCounted
class_name GDLintLocalization

const LANGUAGE_AUTO := "auto"
const LANGUAGE_EN := "en"
const LANGUAGE_RU := "ru"

static var language_mode: String = LANGUAGE_AUTO

static var _text := {
	LANGUAGE_EN: {
		"scan": "Scan",
		"settings": "Settings",
		"export": "Export",
		"export_json": "JSON",
		"export_html": "HTML",
		"export_md": "Markdown",
		"all_severities": "All Severities",
		"critical": "Critical",
		"warnings": "Warnings",
		"info": "Info",
		"all_types": "All Types",
		"file_filter": "Filter by filename...",
		"initial_text": "Click Scan to analyze codebase",
		"scanning": "Scanning codebase...",
		"exported": "Exported:",
		"open_folder": "Open Folder",
		"open_file": "Open File",
		"copy_path": "Copy Path",
		"copy_content": "Copy Content",
		"dismiss": "Dismiss",
		"report_title": "Code Quality Report",
		"files": "Files",
		"lines": "Lines",
		"time": "Time",
		"issues": "Issues",
		"debt": "Debt",
		"filters": "Filters",
		"matches": "matches",
		"no_matching": "No issues matching current filters",
		"ignored": "Ignored",
		"language": "Language",
		"language_auto": "Auto",
		"language_ru": "Russian",
		"language_en": "English",
		"display_options": "Display Options",
		"show_issues": "Show Issues",
		"show_debt": "Show Debt",
		"show_ignored": "Show Ignored",
		"show_full_path": "Show Full Path",
		"export_options": "Export Options",
		"show_json_export": "Show JSON Export",
		"show_html_export": "Show HTML Export",
		"show_md_export": "Show .md Export",
		"filter_exports": "Filter Exports",
		"export_folder": "Export Folder:",
		"browse": "Browse...",
		"scan_options": "Scan Options",
		"respect_gdignore": "Respect .gdignore",
		"scan_addons": "Scan addons/",
		"remember_filters": "Remember Filters",
		"code_checks": "Code Checks",
		"enable_all": "Enable All",
		"disable_all": "Disable All",
		"naming": "Naming",
		"style": "Style",
		"functions": "Functions",
		"structure": "Structure",
		"defensive": "Defensive",
		"analysis_limits": "Analysis Limits",
		"reset_all": "Reset All",
		"reset_default": "Reset to default (%d)",
		"help": "Help",
		"addon_subtitle": " - Code Quality Analyzer for GDScript",
		"file_lines_warn": "File Lines (warn):",
		"file_lines_crit": "File Lines (crit):",
		"func_lines": "Func Lines:",
		"func_lines_crit": "Func Lines (crit):",
		"complexity_warn": "Complexity (warn):",
		"complexity_crit": "Complexity (crit):",
		"max_params": "Max Params:",
		"max_nesting": "Max Nesting:",
		"god_class_funcs": "God Class Funcs:",
		"god_class_signals": "God Class Signals:",
		"file_length": "File Length",
		"long_function": "Long Function",
		"long_line": "Long Line",
		"todo_fixme": "TODO/FIXME",
		"print_statement": "Print Statement",
		"empty_function": "Empty Function",
		"magic_number": "Magic Number",
		"commented_code": "Commented Code",
		"missing_type_hint": "Missing Type Hint",
		"reflection_call": "Reflection Call",
		"missing_return_type": "Missing Return Type",
		"too_many_params": "Too Many Params",
		"deep_nesting": "Deep Nesting",
		"high_complexity": "High Complexity",
		"god_class": "God Class",
		"naming_conventions": "Naming Conventions",
		"naming_class": "Naming: Class",
		"naming_function": "Naming: Function",
		"naming_signal": "Naming: Signal",
		"naming_const": "Naming: Constant",
		"naming_enum": "Naming: Enum",
		"unused_variable": "Unused Variable",
		"unused_parameter": "Unused Parameter",
		"ascii_violation": "ASCII Violation",
		"strict_limit": "Strict Limit",
		"sealed_violation": "Sealed Violation",
		"reflection_message": "Dynamic Object API '%s()' hides typed dependencies; prefer direct typed calls or exported references"
	},
	LANGUAGE_RU: {
		"scan": "Сканировать",
		"settings": "Настройки",
		"export": "Экспорт",
		"export_json": "JSON",
		"export_html": "HTML",
		"export_md": "Markdown",
		"all_severities": "Все уровни",
		"critical": "Критичные",
		"warnings": "Предупреждения",
		"info": "Инфо",
		"all_types": "Все типы",
		"file_filter": "Фильтр по файлу...",
		"initial_text": "Нажмите «Сканировать», чтобы проверить код",
		"scanning": "Сканирование кода...",
		"exported": "Экспорт:",
		"open_folder": "Открыть папку",
		"open_file": "Открыть файл",
		"copy_path": "Копировать путь",
		"copy_content": "Копировать содержимое",
		"dismiss": "Закрыть",
		"report_title": "Отчёт качества кода",
		"files": "Файлы",
		"lines": "Строки",
		"time": "Время",
		"issues": "Проблемы",
		"debt": "Долг",
		"filters": "Фильтры",
		"matches": "совпадений",
		"no_matching": "Нет проблем по текущим фильтрам",
		"ignored": "Игнорировано",
		"language": "Язык",
		"language_auto": "Авто",
		"language_ru": "Русский",
		"language_en": "English",
		"display_options": "Отображение",
		"show_issues": "Показывать проблемы",
		"show_debt": "Показывать долг",
		"show_ignored": "Показывать игнор",
		"show_full_path": "Полный путь",
		"export_options": "Экспорт",
		"show_json_export": "JSON",
		"show_html_export": "HTML",
		"show_md_export": "Markdown",
		"filter_exports": "Экспортировать фильтр",
		"export_folder": "Папка экспорта:",
		"browse": "Выбрать...",
		"scan_options": "Сканирование",
		"respect_gdignore": "Учитывать .gdignore",
		"scan_addons": "Сканировать addons/",
		"remember_filters": "Запоминать фильтры",
		"code_checks": "Проверки кода",
		"enable_all": "Включить всё",
		"disable_all": "Выключить всё",
		"naming": "Имена",
		"style": "Стиль",
		"functions": "Функции",
		"structure": "Структура",
		"defensive": "Защита",
		"analysis_limits": "Лимиты анализа",
		"reset_all": "Сбросить всё",
		"reset_default": "Сбросить к умолчанию (%d)",
		"help": "Справка",
		"addon_subtitle": " - анализ качества GDScript",
		"file_lines_warn": "Строк в файле (пред.):",
		"file_lines_crit": "Строк в файле (крит.):",
		"func_lines": "Строк в функции:",
		"func_lines_crit": "Строк в функции (крит.):",
		"complexity_warn": "Сложность (пред.):",
		"complexity_crit": "Сложность (крит.):",
		"max_params": "Параметров:",
		"max_nesting": "Вложенность:",
		"god_class_funcs": "Методов God Class:",
		"god_class_signals": "Сигналов God Class:",
		"file_length": "Длина файла",
		"long_function": "Длинная функция",
		"long_line": "Длинная строка",
		"todo_fixme": "TODO/FIXME",
		"print_statement": "Print-вызов",
		"empty_function": "Пустая функция",
		"magic_number": "Магическое число",
		"commented_code": "Закомментированный код",
		"missing_type_hint": "Нет типа переменной",
		"reflection_call": "Рефлексия",
		"missing_return_type": "Нет типа возврата",
		"too_many_params": "Много параметров",
		"deep_nesting": "Глубокая вложенность",
		"high_complexity": "Высокая сложность",
		"god_class": "God Class",
		"naming_conventions": "Именование",
		"naming_class": "Имя класса",
		"naming_function": "Имя функции",
		"naming_signal": "Имя сигнала",
		"naming_const": "Имя константы",
		"naming_enum": "Имя enum",
		"unused_variable": "Неиспользуемая переменная",
		"unused_parameter": "Неиспользуемый параметр",
		"ascii_violation": "Не ASCII",
		"strict_limit": "Строгий лимит",
		"sealed_violation": "Sealed-нарушение",
		"reflection_message": "Динамический Object API '%s()' скрывает типизированные зависимости; лучше вызвать метод напрямую или через typed reference"
	}
}


static func set_language_mode(mode: String) -> void:
	if mode in [LANGUAGE_AUTO, LANGUAGE_EN, LANGUAGE_RU]:
		language_mode = mode
	else:
		language_mode = LANGUAGE_AUTO


static func get_language() -> String:
	if language_mode != LANGUAGE_AUTO:
		return language_mode

	if Engine.is_editor_hint():
		var editor_settings := EditorInterface.get_editor_settings()
		var editor_language := ""
		if editor_settings.has_setting("interface/editor/editor_language"):
			editor_language = str(editor_settings.get_setting("interface/editor/editor_language"))
		elif editor_settings.has_setting("interface/editor/language"):
			editor_language = str(editor_settings.get_setting("interface/editor/language"))

		if editor_language.to_lower().begins_with("ru"):
			return LANGUAGE_RU
	if OS.get_locale_language().to_lower().begins_with("ru"):
		return LANGUAGE_RU
	return LANGUAGE_EN


static func t(key: String) -> String:
	var lang := get_language()
	var table: Dictionary = _text.get(lang, _text[LANGUAGE_EN])
	if table.has(key):
		return table[key]
	return _text[LANGUAGE_EN].get(key, key)
