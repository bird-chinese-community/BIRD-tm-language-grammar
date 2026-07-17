---
bump: patch
category: changed
---

- 🧾 **引入可审计的变更片段** / **Adopt auditable change fragments**

新增零依赖的变更片段工作流，可在 PR 中记录语义版本级别和双语发布说明，
发布时按分类汇总到 CHANGELOG，并让 TextMate/Vim Release 直接复用同一份说明。

Added a dependency-free change-fragment workflow that records semantic version
bumps and bilingual notes in pull requests, groups them into the changelog, and
feeds the same notes into TextMate/Vim Releases.
