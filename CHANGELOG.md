# Changelog 🕊️

<!-- markdownlint-disable MD024 -->

All notable changes to the BIRD TextMate grammar and its shared editor syntax
snapshots are documented in this file.

本文记录 BIRD TextMate grammar 及其共享编辑器语法快照的重要变更。

> Coverage statements refer to BIRD configuration syntax: keywords, enum
> constants, CLI phrases, filter attributes, and grammar behavior. They do not
> cover upstream runtime semantics such as AS-SET defaults, disabled BGP
> instance behavior, routing behavior, or memory management.

<!-- changeset-release-marker -->

## [1.0.13-20260717] - 2026-07-17

[TextMate Grammar 1.0.13-20260717] 与 [Vim Syntax 1.0.13-20260717] 已于
2026-07-17 发布；本轮实现由 [PR #14] 合并。

[TextMate Grammar 1.0.13-20260717] and [Vim Syntax 1.0.13-20260717] were
published on 2026-07-17. The implementation was merged in [PR #14].

### ✨ Added / 新增

- 🛰️ **扩展当前与冷门语法覆盖** / **Broader current and uncommon syntax coverage**

  补齐 EVPN、Bridge、BMP、RADV、BGP、OSPF、MRT、Perf 等模块，以及 table
  类型、日志与时间格式、CLI 控制短语、枚举常量、运行时/接口属性和 BGP
  hidden/unknown attributes。

  Expanded coverage across EVPN, Bridge, BMP, RADV, BGP, OSPF, MRT, Perf,
  table types, logging and time formats, CLI controls, enum constants,
  runtime/interface attributes, and BGP hidden/unknown attributes.

- 🧬 **新增类型与测试内置函数** / **New types and test built-ins**

  新增 `mac`、`mac set` 类型及声明高亮，并补齐 `bt_check_assign` 等测试内置函数。

  Added declaration highlighting for `mac` and `mac set`, together with test
  built-ins including `bt_check_assign`.

- 🔎 **上游源码自动覆盖审计** / **Automated upstream source coverage audit**

  新增基于 BIRD 2/3 上游源码的关键字、枚举、CLI 短语和 BIRD 3
  filter 属性审计，并加入 BIRD 2.19 / 3.3 回归样例。

  Added source-driven audits for BIRD 2/3 keywords, enums, CLI phrases, and
  BIRD 3 filter attributes, plus a BIRD 2.19 / 3.3 regression fixture.

### 🔧 Changed / 变更

- 🧭 **对齐当前稳定分支** / **Aligned with current stable branches**

  审计基准更新为 BIRD 2 `stable-v2.19` 的 `cb400b6c`（`v2.19.1`）与
  BIRD 3 `stable-v3.3` 的 `a69711d1`（`v3.3.1-1-ga69711d1`）。该基准仅表示
  配置语法审计范围，不代表覆盖 [BIRD 3.3.0 与 2.19.0 发布公告]中的运行时变化。

  Audited BIRD 2 `stable-v2.19` at `cb400b6c` (`v2.19.1`) and BIRD 3
  `stable-v3.3` at `a69711d1` (`v3.3.1-1-ga69711d1`). These baselines describe
  configuration-syntax coverage only, not runtime changes in the
  [BIRD 3.3.0 and 2.19.0 release announcement].

- ⚙️ **操作符与匹配优先级校正** / **Operator and matching precedence alignment**

  正确区分位运算符 `&`、`|` 与逻辑运算符，并调整通用标识符规则顺序，避免覆盖
  更具体的语法组；Vim 与 Neovim 语法镜像保持逐字节一致。

  Distinguished bitwise `&` and `|` from logical operators, reordered the
  generic identifier rule so specialized groups retain priority, and kept the
  Vim/Neovim syntax mirrors byte-identical.

### 🐛 Fixed / 修复

- 🧵 **字符串、IPv6 与前缀范围匹配** / **Strings, IPv6, and prefix ranges**

  修复双引号字符串转义、压缩 IPv6 前缀（如 `::/0`），以及 IPv4/IPv6
  prefix range 后缀（如 `+`、`{16,24}`）的匹配。

  Fixed double-quoted escapes, compressed IPv6 prefixes such as `::/0`, and
  IPv4/IPv6 prefix-range suffixes such as `+` and `{16,24}`.

- ⚡ **限制 IPv6 正则边界** / **Bounded IPv6 matching**

  收紧 IPv6 前缀匹配边界并限制表达式工作量，避免异常长行触发不必要的性能开销。

  Tightened IPv6 prefix boundaries and bounded matching work to avoid
  unnecessary cost on unusually long lines.

### 🧪 Verification / 验证

- BIRD 2：581 个关键字、67 个枚举常量、114 个 CLI 短语，当前审计零遗漏。
- BIRD 2: 581 keywords, 67 enum constants, and 114 CLI phrases, with zero
  missing in the current audit.
- BIRD 3：554 个关键字、67 个枚举常量、120 个 CLI 短语、90 个过滤器属性，
  当前审计零遗漏。
- BIRD 3: 554 keywords, 67 enum constants, 120 CLI phrases, and 90 filter
  attributes, with zero missing in the current audit.
- 162 条 grammar 正则均可成功编译；仓库守卫另覆盖 567 个 token、3 个 phrase、
  4 个 operator 与 5 个 prefix 检查。
- All 162 grammar regular expressions compile; repository guards additionally
  cover 567 tokens, 3 phrases, 4 operators, and 5 prefix checks.

### 🔌 Editor integrations / 编辑器集成

- [BIRD.vim PR #3] 同步交付 Vim 语法、启发式文件识别、ftplugin 与兼容性测试。
- [BIRD.vim PR #3] delivered the Vim syntax, heuristic file detection,
  ftplugin behavior, and compatibility tests.
- [BIRD.nvim PR #1] 同步交付 Neovim runtime、文件识别、CI 与语法镜像修复。
- [BIRD.nvim PR #1] delivered the Neovim runtime, detection, CI, and syntax
  mirror fixes.

[1.0.13-20260717]: https://github.com/bird-chinese-community/BIRD-tm-language-grammar/releases/tag/tm-v1.0.13-20260717
[TextMate Grammar 1.0.13-20260717]: https://github.com/bird-chinese-community/BIRD-tm-language-grammar/releases/tag/tm-v1.0.13-20260717
[Vim Syntax 1.0.13-20260717]: https://github.com/bird-chinese-community/BIRD-tm-language-grammar/releases/tag/vim-v1.0.13-20260717
[PR #14]: https://github.com/bird-chinese-community/BIRD-tm-language-grammar/pull/14
[BIRD.vim PR #3]: https://github.com/bird-chinese-community/BIRD.vim/pull/3
[BIRD.nvim PR #1]: https://github.com/bird-chinese-community/BIRD.nvim/pull/1
[BIRD 3.3.0 与 2.19.0 发布公告]: https://bird.network.cz/pipermail/bird-users/2026-May/018761.html
[BIRD 3.3.0 and 2.19.0 release announcement]: https://bird.network.cz/pipermail/bird-users/2026-May/018761.html
