---
bump: patch
category: fixed
---

- 🧰 **安装器与审计错误处理加固** / **Installer and audit error hardening**

  Neovim 安装器改用正确的 `plugin/bird2.lua` 并清理旧入口；grammar 审计现在会对
  无效正则和错误的上游源码路径快速失败，并给出可定位的诊断信息。

  The Neovim installer now uses the correct `plugin/bird2.lua` path and removes
  the legacy entry point. Grammar audits now fail fast on invalid regular
  expressions and invalid upstream source paths with actionable diagnostics.
