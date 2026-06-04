# AbyssMoth GDScript Linter

<p align="center">
  <a href="README.md"><img alt="Russian" src="https://img.shields.io/badge/README-Русский-gray"></a>
  <a href="README_EN.md"><img alt="English" src="https://img.shields.io/badge/README-English-blue"></a>
</p>

![Version](https://img.shields.io/badge/version-3.3.0--abyssmoth.2-blue.svg)
![Godot](https://img.shields.io/badge/Godot-4.x-blue.svg)

This is a local studio fork of `graydwarf/godot-gdscript-linter`, adapted for AbyssMoth/RimuruDev workflows: fewer string-based dynamic calls, more typed wiring, Russian editor UI, and a more compact bottom-panel layout.

## Fork Changes

- Added `reflection-call` for dynamic Object APIs: `call()`, `call_deferred()`, `has_method()`, `has_signal()`, `emit_signal()`, `set_deferred()`, `get_indexed()`, `set_indexed()`.
- `Dictionary.get()` and generic `get()/set()` are intentionally not part of the default rule to avoid noise in save migration and JSON-like data code.
- Export buttons are collapsed into one compact `Export` menu.
- Claude Code and CLI settings cards are removed from the studio UI.
- Added UI language mode: `Auto`, `Russian`, `English`.
- `reflection-call` appears in the type filter, editor report, and HTML export.
- CLI path handling now supports a single `.gd` file as well as directories.
- Added a scan target path, so `res://addons/my_addon` can be analyzed without scanning every addon.
- Fixed `unused-variable`/`unused-parameter` false positives for property `get/set` accessors and generic types with commas.

## Usage

1. Copy `addons/gdscript-linter` into a Godot project.
2. Enable the plugin in `Project > Project Settings > Plugins`.
3. Open the bottom panel tab `Code Quality`.
4. Click `Scan`.
5. Choose the UI language in settings if needed.

## Main Checks

| Check | Severity | Purpose |
|---|---:|---|
| File Length | Warning/Critical | Files above configured line limits |
| Function Length | Warning/Critical | Functions above configured line limits |
| Complexity | Warning/Critical | High cyclomatic complexity |
| Parameters | Warning | Too many function parameters |
| Nesting | Warning | Deeply nested code |
| TODO/FIXME | Info/Warning | Technical-debt markers |
| Print Statements | Warning | Leftover debug prints |
| Magic Numbers | Info | Hardcoded numbers |
| Commented Code | Info | Dead code in comments |
| Missing Types | Info | Missing type hints |
| Reflection Calls | Warning | Dynamic `call()`/`has_method()` style APIs |
| God Class | Warning | Classes with too many members |
| Naming | Info/Warning | Naming convention issues |
| Unused | Info/Warning | Unused variables and parameters |
| ASCII/Strict/Sealed | Warning/Critical | Defensive contract rules |

## Ignore Example

```gdscript
# gdlint:ignore-line:reflection-call
target.call("method_name")
```

Pinned exceptions are useful for intentional large config files:

```gdscript
# gdlint:ignore-file:file-length=340
```

## License

This fork keeps the original MIT license. Local fork changes are maintained for AbyssMoth/RimuruDev.
