# GDScript Linter для AbyssMoth

<p align="center">
  <a href="README.md"><img alt="Русский" src="https://img.shields.io/badge/README-Русский-blue"></a>
  <a href="README_EN.md"><img alt="English" src="https://img.shields.io/badge/README-English-gray"></a>
</p>

![Version](https://img.shields.io/badge/version-3.3.0--abyssmoth.1-blue.svg)
![Godot](https://img.shields.io/badge/Godot-4.x-blue.svg)

Это локальный студийный форк `graydwarf/godot-gdscript-linter`, адаптированный под рабочий стиль AbyssMoth/RimuruDev: меньше магии через строки, больше типизированных связей, русская панель в редакторе и компактный UI для нижней панели Godot.

## Что изменено в форке

- Добавлена проверка `reflection-call` для динамических Object API: `call()`, `call_deferred()`, `has_method()`, `has_signal()`, `emit_signal()`, `set_deferred()`, `get_indexed()`, `set_indexed()`.
- `Dictionary.get()` и обычный `get()/set()` не входят в дефолтную проверку, чтобы не шуметь на миграциях сейвов и JSON-подобных данных.
- Панель стала компактнее: JSON/HTML/Markdown экспорт спрятан в одно меню `Экспорт`.
- Настройки Claude Code и CLI убраны из студийного UI форка.
- Добавлена локализация интерфейса: `Auto`, `Русский`, `English`.
- `reflection-call` отображается в фильтре типов, отчёте и HTML-экспорте.
- CLI теперь умеет анализировать одиночный `.gd` файл, а не только директории.

## Использование

1. Скопируйте `addons/gdscript-linter` в проект Godot.
2. Включите плагин: `Проект > Настройки проекта > Плагины`.
3. Откройте нижнюю вкладку `Code Quality`.
4. Нажмите `Сканировать`.
5. В настройках выберите язык `Auto`, `Русский` или `English`.

Если редактор Godot уже на русском, режим `Auto` сам выберет русский интерфейс.

## Основные проверки

| Проверка | Уровень | Что ищет |
|---|---:|---|
| Длина файла | Warning/Critical | Файлы длиннее настроенных лимитов |
| Длина функции | Warning/Critical | Слишком длинные функции |
| Сложность | Warning/Critical | Высокую цикломатическую сложность |
| Количество параметров | Warning | Слишком много параметров функции |
| Вложенность | Warning | Слишком глубокие блоки |
| TODO/FIXME | Info/Warning | Маркеры техдолга |
| Print-вызовы | Warning | Оставленные debug print |
| Магические числа | Info | Числа без именованных констант |
| Закомментированный код | Info | Мёртвый код в комментариях |
| Пропущенные типы | Info | Переменные без type hints |
| Рефлексия | Warning | Динамические вызовы `call()`/`has_method()` и похожие API |
| God Class | Warning | Классы со слишком большим числом членов |
| Naming | Info/Warning | Нарушения соглашений имён |
| Unused | Info/Warning | Неиспользуемые переменные и параметры |
| ASCII/Strict/Sealed | Warning/Critical | Дополнительные защитные правила |

## Игнорирование правил

Для осознанных исключений используйте директивы:

```gdscript
# gdlint:ignore-line:reflection-call
target.call("method_name")
```

Поддерживаются:

| Директива | Область |
|---|---|
| `gdlint:ignore-file` | весь файл |
| `gdlint:ignore-below` | от строки до конца файла |
| `gdlint:ignore-function` | вся функция |
| `gdlint:ignore-block-start/end` | блок кода |
| `gdlint:ignore-next-line` | следующая строка |
| `gdlint:ignore-line` | текущая строка |

Для длинных конфигов можно использовать pinned exceptions:

```gdscript
# gdlint:ignore-file:file-length=340
```

Так линтер не будет ругаться, пока файл не станет длиннее зафиксированного значения.

## Конфиг

Панель автоматически синхронизирует настройки в `gdlint.json`. Также можно использовать `.gdlint.cfg`:

```ini
[limits]
file_lines_soft = 200
file_lines_hard = 300
function_lines = 30
function_lines_critical = 60
max_parameters = 4
max_nesting = 3
cyclomatic_warning = 10
cyclomatic_critical = 15

[checks]
file_length = true
function_length = true
cyclomatic_complexity = true
parameters = true
nesting = true
todo_comments = true
print_statements = true
empty_functions = true
magic_numbers = true
commented_code = true
missing_types = true
reflection_calls = true
god_class = true
naming_conventions = true
unused_variables = true
unused_parameters = true
ascii_only = true
strict_limits = true
sealed = true

[exclude]
paths = addons/, .godot/, tests/mocks/
```

## Лицензия

Форк сохраняет MIT-лицензию оригинального проекта. Локальные изменения поддерживаются для студии AbyssMoth/RimuruDev.
