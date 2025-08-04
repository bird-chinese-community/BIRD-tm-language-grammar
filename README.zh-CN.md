## BIRD2 Configuration Language

### 项目背景

> **BIRD**（BIRD Internet Routing Daemon）  
> 一个开源的路由守护进程，用于管理网络基础设施中的路由表。

本仓库提供 BIRD2 语法高亮文件（`tmLanguage`），可增强配置文件编写体验。

相较于 INI 或 Nginx 等简单且直观的配置范式，BIRD 采用特别且复杂的配置模型，甚至不能称其为简单的 “配置文件”，而更像是一种 “配置语言”。

### 项目意义

作为当今互联网核心基础设施的关键组成部分，BIRD2 至今仍缺乏主流编辑器（如`VSCode`/`Shiki`）的原生语法高亮与格式化支持。

截至目前, BIRD 网络工程师与开发者们长期依赖着 “变通方案”（如借用 Nginx 语法高亮/直接不使用高亮），但这些方案远远无法满足「准确且清晰地呈现 BIRD2 复杂的语法结构」的需求。

为此，**BIRD 中文社区** 正式开源了基于 TextMate 的 BIRD2 语法规范，致力于提升开发体验并推动生态建设。

### 进展公示

- 已向上游项目提交合并请求：

  - [ ] [GitHub Linguist #7513](https://github.com/github/linguist/pull/7513)
  - [ ] [Shiki #149](https://github.com/shikijs/textmate-grammars-themes/pull/149)

- 🚧 支持完整语法高亮与格式化的 VSCode 插件开发中
  - 👉 [加入 Telegram 封闭测试](https://t.me/bird_cnn/23)（中文社区专属）

### 在线体验

- 🌐 **Playground**（通过 Shiki 预览）：  
  [https://deploy-preview-149--textmate-grammars-themes.netlify.app/?theme=ayu-dark\&grammar=bird2](https://deploy-preview-149--textmate-grammars-themes.netlify.app/?theme=ayu-dark&grammar=bird2)

### 贡献者致谢

向以下贡献者致敬：

- [Alice39s](https://github.com/Alice39s)
- [pppwaw](https://github.com/pppwaw)

### 许可协议

- 语法文件采用 **[Mozilla Public License 2.0](LICENSE.syntax)**
- 示例配置文件（`/sample/*`）采用 **[MIT License](LICENSE.sample)**

[public-code-search-results-list]: https://github.com/search?q=%22protocol+bgp%22+OR+%22neighbor%22+OR+%22local+as%22+path%3A*.conf+NOT+is%3Afork&type=code&ref=advsearch
[public-repo-search-results-list]: https://github.com/search?q=bird+config&type=repositories&ref=advsearch
