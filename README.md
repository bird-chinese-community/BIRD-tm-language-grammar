# BIRD2 Configuration Language

## Introduction

This repository hosts syntax files (`tmLanguage`) for BIRD2, designed to enhance developer productivity through syntax highlighting in configuration files.

> **BIRD** (BIRD Internet Routing Daemon)  
> Open-source routing daemon for managing routing tables on network infrastructure.

> **BIRD2** (BIRD version 2)  
> Not backward compatible with BIRD v1, with limited forward compatibility to BIRD v3 syntax.

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

Distributed under **[Mozilla Public License 2.0](LICENSE)**

[public-code-search-results-list]: https://github.com/search?q=%22protocol+bgp%22+OR+%22neighbor%22+OR+%22local+as%22+path%3A*.conf+NOT+is%3Afork&type=code&ref=advsearch
[public-repo-search-results-list]: https://github.com/search?q=bird+config&type=repositories&ref=advsearch
