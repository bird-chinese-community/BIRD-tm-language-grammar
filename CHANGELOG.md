# Changelog 🕊️

<!-- markdownlint-disable MD024 -->

All notable changes to the BIRD TextMate grammar and its shared editor syntax
snapshots are documented in this file.

本文记录 BIRD TextMate grammar 及其共享编辑器语法快照的重要变更。

> Coverage statements refer to BIRD configuration syntax: keywords, enum
> constants, CLI phrases, filter attributes, and grammar behavior. They do not
> cover upstream runtime semantics such as AS-SET defaults, disabled BGP
> instance behavior, routing behavior, or memory management.
>
> 覆盖范围声明针对 BIRD 配置语法：关键字、枚举常量、CLI 短语、过滤器属性与
> 语法行为；不涵盖上游运行时语义，如 AS-SET 默认值、BGP 实例禁用行为、
> 路由行为或内存管理。

<!-- changeset-release-marker -->

## [1.0.13-20260717] - 2026-07-17

[TextMate Grammar 1.0.13-20260717](https://github.com/bird-chinese-community/BIRD-tm-language-grammar/releases/tag/tm-v1.0.13-20260717)
与 [Vim Syntax 1.0.13-20260717](https://github.com/bird-chinese-community/BIRD-tm-language-grammar/releases/tag/vim-v1.0.13-20260717)
已于 2026-07-17 发布；本轮实现由 [PR #14](https://github.com/bird-chinese-community/BIRD-tm-language-grammar/pull/14) 合并。

[TextMate Grammar 1.0.13-20260717](https://github.com/bird-chinese-community/BIRD-tm-language-grammar/releases/tag/tm-v1.0.13-20260717)
and [Vim Syntax 1.0.13-20260717](https://github.com/bird-chinese-community/BIRD-tm-language-grammar/releases/tag/vim-v1.0.13-20260717)
were published on 2026-07-17. The implementation was merged in
[PR #14](https://github.com/bird-chinese-community/BIRD-tm-language-grammar/pull/14).

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
  配置语法审计范围，不代表覆盖
  [BIRD 3.3.0 与 2.19.0 发布公告](https://bird.network.cz/pipermail/bird-users/2026-May/018761.html)
  中的运行时变化。

  Audited BIRD 2 `stable-v2.19` at `cb400b6c` (`v2.19.1`) and BIRD 3
  `stable-v3.3` at `a69711d1` (`v3.3.1-1-ga69711d1`). These baselines describe
  configuration-syntax coverage only, not runtime changes in the
  [BIRD 3.3.0 and 2.19.0 release announcement](https://bird.network.cz/pipermail/bird-users/2026-May/018761.html).

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

- [BIRD.vim PR #3](https://github.com/bird-chinese-community/BIRD.vim/pull/3)
  同步交付 Vim 语法、启发式文件识别、ftplugin 与兼容性测试。
- [BIRD.vim PR #3](https://github.com/bird-chinese-community/BIRD.vim/pull/3)
  delivered the Vim syntax, heuristic file detection,
  ftplugin behavior, and compatibility tests.
- [BIRD.nvim PR #1](https://github.com/bird-chinese-community/BIRD.nvim/pull/1)
  一并带来 Neovim runtime、文件识别、CI 与语法镜像修复。
- [BIRD.nvim PR #1](https://github.com/bird-chinese-community/BIRD.nvim/pull/1)
  shipped the Neovim runtime, detection, CI, and syntax
  mirror fixes.

## [tm-v1.0.11-20260611] / [vim-v1.0.11-20260611] - 2026-06-11

### 🔧 Changed / 变更

- 🧩 **扩展协议与 CLI 语法** / **Expanded protocol and CLI grammar**

  扩展协议专用配置与管理 CLI 短语，补充独立的 `show route` 命令，并修复
  structural keyword 的正则遮蔽与历史拼写变体。

  Expanded protocol-specific configuration and management CLI phrases, added
  the standalone `show route` command, and removed structural-keyword regex
  shadowing and obsolete typo variants.

- 🔄 **同步 TextMate 与 Vim 快照** / **Synchronized TextMate and Vim snapshots**

  TextMate grammar 与 Vim syntax 均发布 `1.0.11-20260611` 快照；Vim 资产延后
  补发，但继续对应同一语法版本。

  Published `1.0.11-20260611` snapshots for both the TextMate grammar and Vim
  syntax. The Vim asset was backfilled later while retaining the same syntax
  version.

## [tm-v1.0.10-20260609] - 2026-06-09

### ✨ Added / 新增

- 🛰️ **BIRD 2.19 与 BIRD 3.3 token 覆盖** / **BIRD 2.19 and BIRD 3.3 token coverage**

  补充 BIRD 2.19 与 BIRD 3.3 的配置 token，并新增对应 sample fixture 与自动
  coverage check；本版本仅发布 TextMate grammar 轨道。

  Added configuration tokens for BIRD 2.19 and BIRD 3.3 together with a sample
  fixture and automated coverage check. This version was published only on the
  TextMate grammar track.

## [tm-v1.0.9-20260306] - 2026-03-06

### 🐛 Fixed / 修复

- 🧭 **对齐 neighbor 与 local AS 高亮** / **Aligned neighbor and local-AS highlighting**

  调整 `neighbor` 与 `local as` 相关规则，使 TextMate grammar 的高亮范围与
  parser 接受的配置形式一致，并修复 Prek CI 参数。

  Aligned `neighbor` and `local as` highlighting with parser-supported forms and
  corrected the Prek CI arguments. This release affected only the TextMate
  grammar track.

## [tm-v1.0.8-20260301] / [vim-v1.0.8-20260301] - 2026-03-01

### ✨ Added / 新增

- 🔤 **协议短语与发布工具** / **Protocol phrases and release tooling**

  新增高优先级协议短语、sample 覆盖与 syntax patch bump 工具，并让 TextMate、
  Vim 与 Neovim 快照同步到同一版本。

  Added high-priority protocol phrases, sample coverage, and a syntax patch-bump
  tool while synchronizing the TextMate, Vim, and Neovim snapshots.

### 🐛 Fixed / 修复

- 🧵 **匹配优先级与词法边界** / **Matcher priority and lexical boundaries**

  修正 matcher reachability、symbol/definition、operator、typed set、byte string、
  压缩 IPv6 与 property/method 边界，避免通用规则遮蔽更具体的语法组。

  Corrected matcher reachability, symbols and definitions, operators, typed
  sets, byte strings, compressed IPv6, and property/method boundaries so broad
  rules no longer shadow specialized groups.

### 🧪 Verification / 验证

- 引入 submodule-aware Prek workflow、commitlint 与仓库级格式守卫。
- Introduced a submodule-aware Prek workflow, commitlint, and repository-wide
  formatting guards.

## [tm-v1.0.7-20260228] / [vim-v1.0.7-20260228] - 2026-02-28

### 🔧 Changed / 变更

- 🧩 **迁移到独立编辑器仓库** / **Migrated to dedicated editor repositories**

  将 Vim 与 Neovim runtime 迁移到独立仓库，并以 Git submodule 保留本仓的兼容
  安装入口；Release workflow 同步支持递归检出。

  Migrated the Vim and Neovim runtimes to dedicated repositories while keeping
  compatibility installation through Git submodules, and made the Release
  workflow initialize them recursively.

### 🐛 Fixed / 修复

- 🔐 **协议、地址族与 RPKI 关键字** / **Protocol, address-family, and RPKI keywords**

  修复 `vpn4`、`vpn6`、`roa4`、`roa6`、`protocol`、`all`、`none` 及缺失的 RPKI
  协议关键字，并改进许可证自动识别。

  Corrected `vpn4`, `vpn6`, `roa4`, `roa6`, `protocol`, `all`, `none`, and
  missing RPKI protocol keywords, and improved automated license detection.

## [tm-v1.0.6-20250808] / [vim-v1.0.6-20250808] - 2025-08-08

### 🔧 Changed / 变更

- 📦 **统一 Vim 与 Neovim 安装入口** / **Unified Vim and Neovim installation**

  将分散的安装流程统一到 `scripts/install.sh`，补充错误处理与 syntax setup，
  同时重构 Vim 高亮规则并发布两个稳定轨道的 `1.0.6` 资产。

  Unified the editor installation flow under `scripts/install.sh`, added error
  handling and syntax setup, refactored Vim highlighting, and published stable
  `1.0.6` assets for both release tracks.

## [vim-v1.0.5-20250808] - 2025-08-08

### 🔧 Changed / 变更

- 🐦 **扩展 Vim runtime 识别与语法** / **Expanded Vim runtime detection and syntax**

  大幅扩展 Vim syntax 规则与 `ftdetect` 识别逻辑，并将此前 beta 轨道推进到
  `1.0.5` 稳定版本；本次没有新的 TextMate tag。

  Substantially expanded the Vim syntax and `ftdetect` logic and promoted the
  former beta track to stable `1.0.5`. No new TextMate tag accompanied this
  release.

## [vim-v1.0.2-beta-20250808] - 2025-08-08

### 🐛 Fixed / 修复

- 🛠️ **改进 Vim 安装与协议语法** / **Improved Vim installation and protocol syntax**

  修正早期 Vim 安装流程并补充协议语法规则，发布第三个 beta 快照。

  Corrected the early Vim installation flow and expanded protocol syntax in the
  third beta snapshot.

## [tm-v1.0.5-20250808] / [vim-v1.0.1-beta-20250808] - 2025-08-08

### 🔧 Changed / 变更

- 🏷️ **同步早期轨道版本元数据** / **Synchronized early-track version metadata**

  将 TextMate grammar 更新为 `1.0.5`、Vim syntax 更新为 `1.0.1-beta`，并同步
  grammar、文档与发布元数据。

  Updated the TextMate grammar to `1.0.5` and Vim syntax to `1.0.1-beta`, with
  synchronized grammar, documentation, and release metadata.

## [tm-v1.0.4-20250808] / [vim-v1.0.0-beta-20250808] - 2025-08-08

### ✨ Added / 新增

- 🕊️ **建立双发布轨道** / **Established both release tracks**

  首次发布 TextMate Grammar `1.0.4` 与 Vim Syntax `1.0.0-beta`，提供 BIRD 配置
  高亮资产、编辑器安装说明与初始版本 badge。

  Published the initial TextMate Grammar `1.0.4` and Vim Syntax `1.0.0-beta`
  assets with BIRD configuration highlighting, editor installation guidance,
  and the first release badges.

[1.0.13-20260717]: https://github.com/bird-chinese-community/BIRD-tm-language-grammar/releases/tag/tm-v1.0.13-20260717
[tm-v1.0.11-20260611]: https://github.com/bird-chinese-community/BIRD-tm-language-grammar/releases/tag/tm-v1.0.11-20260611
[vim-v1.0.11-20260611]: https://github.com/bird-chinese-community/BIRD-tm-language-grammar/releases/tag/vim-v1.0.11-20260611
[tm-v1.0.10-20260609]: https://github.com/bird-chinese-community/BIRD-tm-language-grammar/releases/tag/tm-v1.0.10-20260609
[tm-v1.0.9-20260306]: https://github.com/bird-chinese-community/BIRD-tm-language-grammar/releases/tag/tm-v1.0.9-20260306
[tm-v1.0.8-20260301]: https://github.com/bird-chinese-community/BIRD-tm-language-grammar/releases/tag/tm-v1.0.8-20260301
[vim-v1.0.8-20260301]: https://github.com/bird-chinese-community/BIRD-tm-language-grammar/releases/tag/vim-v1.0.8-20260301
[tm-v1.0.7-20260228]: https://github.com/bird-chinese-community/BIRD-tm-language-grammar/releases/tag/tm-v1.0.7-20260228
[vim-v1.0.7-20260228]: https://github.com/bird-chinese-community/BIRD-tm-language-grammar/releases/tag/vim-v1.0.7-20260228
[tm-v1.0.6-20250808]: https://github.com/bird-chinese-community/BIRD-tm-language-grammar/releases/tag/tm-v1.0.6-20250808
[vim-v1.0.6-20250808]: https://github.com/bird-chinese-community/BIRD-tm-language-grammar/releases/tag/vim-v1.0.6-20250808
[vim-v1.0.5-20250808]: https://github.com/bird-chinese-community/BIRD-tm-language-grammar/releases/tag/vim-v1.0.5-20250808
[vim-v1.0.2-beta-20250808]: https://github.com/bird-chinese-community/BIRD-tm-language-grammar/releases/tag/vim-v1.0.2-beta-20250808
[tm-v1.0.5-20250808]: https://github.com/bird-chinese-community/BIRD-tm-language-grammar/releases/tag/tm-v1.0.5-20250808
[vim-v1.0.1-beta-20250808]: https://github.com/bird-chinese-community/BIRD-tm-language-grammar/releases/tag/vim-v1.0.1-beta-20250808
[tm-v1.0.4-20250808]: https://github.com/bird-chinese-community/BIRD-tm-language-grammar/releases/tag/tm-v1.0.4-20250808
[vim-v1.0.0-beta-20250808]: https://github.com/bird-chinese-community/BIRD-tm-language-grammar/releases/tag/vim-v1.0.0-beta-20250808
