# BIRD2 Configuration Language

## Introduction

> **BIRD** (BIRD Internet Routing Daemon)  
> Open-source routing daemon for managing routing tables on network infrastructure.

This repository hosts syntax files (`tmLanguage`) for BIRD2, designed to enhance developer productivity through syntax highlighting in configuration files.

Unlike the straightforward paradigms of INI or Nginx configurations, BIRD employs a distinctly intricate configuration model with unique implementation challenges.

## Why This Project

Despite its role in core internet infrastructure, BIRD2 still lacks native syntax highlighting and formatting support in mainstream editors like `VSCode` and `Shiki`.

Network engineers and developers have long relied on workarounds, such as using Nginx or INI syntax modes. However, these do not accurately represent the complex grammar of BIRD2.

To address this issue, the **BIRD Chinese Community** has officially open-sourced a TextMate-based syntax grammar for BIRD2. Our goal is to improve developer experience and foster broader ecosystem support.

## Project Status

- Pull requests have been submitted to upstream projects:

  - [GitHub Linguist #7513](https://github.com/github/linguist/pull/7513)
  - [Shiki #149](https://github.com/shikijs/textmate-grammars-themes/pull/149)

- 🚧 A VSCode plugin with full syntax highlighting and formatting support is actively under development.
  - 👉 [Join the closed beta on Telegram](https://t.me/bird_cnn/23) (Chinese only)

## Try It Live

- 🌐 **Playground** (via Shiki preview):
  [https://deploy-preview-149--textmate-grammars-themes.netlify.app/?theme=ayu-dark\&grammar=bird2](https://deploy-preview-149--textmate-grammars-themes.netlify.app/?theme=ayu-dark&grammar=bird2)

## Community Adoption Evidence

### GitHub Usage Statistics

- **27k+** BIRD2 configuration snippets found in public repositories ([View search results][public-code-search-results-list])
- **883+** active repositories using BIRD configurations ([View search results][public-repo-search-results-list])

### Production Deployment at Internet Scale

BIRD2 powers critical internet infrastructure for major operators:

- **AMS-IX** (World's largest IXP)  
  Handles **>870 ASNs** with 20k+ IPv4/5k+ IPv6 prefixes at **14Tb/s+** traffic  
  [Route-Server Platform](https://www.ams-ix.net/ams/documentation/ams-ix-route-servers)

- **LINX** (London Internet Exchange)  
  Migrated 1,000+ peer sessions to BIRD 2.13 across 7 global sites (2024)  
  [Technology Update](https://www.linx.net/wp-content/uploads/2024/05/Day-1-P4-LINX_Technology-Presentation_v3.0.pdf)

- **Cloudflare Anycast Edge**  
  Deployed on every server in 280+ PoPs for sub-second failover routing  
  [Architecture Deep Dive](https://blog.cloudflare.com/cloudflares-architecture-eliminating-single-p/)

## Contributors

The [BIRD Chinese Community](https://github.com/bird-chinese-community) extends gratitude to these contributors:

- [Alice39s](https://github.com/Alice39s)
- [pppwaw](https://github.com/pppwaw)

## License

- Syntax files are distributed under **[Mozilla Public License 2.0](LICENSE.syntax)**
- Sample configuration files (`/sample/*`) are distributed under **[MIT License](LICENSE.sample)**

[public-code-search-results-list]: https://github.com/search?q=%22protocol+bgp%22+OR+%22neighbor%22+OR+%22local+as%22+path%3A*.conf+NOT+is%3Afork&type=code&ref=advsearch
[public-repo-search-results-list]: https://github.com/search?q=bird+config&type=repositories&ref=advsearch
