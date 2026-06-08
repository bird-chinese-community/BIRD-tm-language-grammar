#!/usr/bin/env node

import { readFileSync } from "node:fs";

const grammarPath = new URL("../grammars/bird2.tmLanguage.json", import.meta.url);
const grammar = JSON.parse(readFileSync(grammarPath, "utf8"));
const grammarText = JSON.stringify(grammar)
  .toLowerCase()
  .replaceAll("\\\\s+", " ")
  .replaceAll("\\s+", " ");

const checks = [
  {
    label: "BIRD 2.19 protocol keywords",
    tokens: ["bridge", "evpn"],
  },
  {
    label: "BIRD 2.19 EVPN route attributes",
    tokens: [
      "bgp_atomic_aggr",
      "bgp_aggregator",
      "bgp_aigp",
      "bgp_pmsi_tunnel",
      "bgp_otc",
      "babel_metric",
      "krt_prefsrc",
      "krt_realm",
      "radv_preference",
      "radv_lifetime",
    ],
  },
  {
    label: "BIRD 2.19 EVPN method properties",
    tokens: ["vlan_id", "evpn_type", "evpn_tag", "evpn_esi", "router_ip"],
  },
  {
    label: "BIRD 2.19 / 3.3 net type constants",
    tokens: [
      "net_eth",
      "net_aspa",
      "net_evpn",
      "net_evpn_ead",
      "net_evpn_mac",
      "net_evpn_imet",
      "net_evpn_es",
      "ipv4-mpls",
      "ipv6-mpls",
      "ipv6-sadr",
      "vpn4-mc",
      "vpn4-mpls",
      "vpn6-mc",
      "vpn6-mpls",
      "neighbor",
    ],
  },
  {
    label: "BIRD 2.19 / 3.3 channel phrases",
    tokens: [
      "ipv4 multicast",
      "ipv4 mpls",
      "ipv6 multicast",
      "ipv6 mpls",
      "vpn4 multicast",
      "vpn4 mpls",
      "vpn6 multicast",
      "vpn6 mpls",
      "ipv6 sadr",
    ],
  },
  {
    label: "BIRD 2.19 MPLS and protocol phrases",
    tokens: [
      "mpls domain",
      "label range",
      "encapsulation vxlan",
      "vlan filtering",
      "aspa providers",
      "authentication ao",
    ],
  },
  {
    label: "BIRD 3.3 management phrases",
    tokens: [
      "thread group",
      "cork threshold",
      "route refresh export settle time",
      "digest settle time",
      "filter stacks",
      "express thread group",
      "max generation",
      "tx size warning",
    ],
  },
  {
    label: "BIRD 2.19 / 3.3 operations phrases",
    tokens: [
      "router id from",
      "vrf default",
      "receive limit",
      "import keep filtered",
      "rpki reload",
      "mrtdump",
      "timeformat",
      "preexport",
      "noexport",
      "exported",
      "stats",
      "count",
    ],
  },
  {
    label: "BIRD 2.19 / 3.3 protocol-specific phrases",
    tokens: [
      "route distinguisher",
      "import target",
      "export target",
      "route target",
      "tunnel device",
      "router address",
      "monitoring rib in pre_policy",
      "monitoring rib in post_policy",
      "solicited ra unicast",
      "router discovery",
      "split horizon",
      "link lsa suppression",
    ],
  },
];

const missing = [];

for (const check of checks) {
  for (const token of check.tokens) {
    if (!grammarText.includes(token)) {
      missing.push(`${check.label}: ${token}`);
    }
  }
}

if (missing.length > 0) {
  console.error("Missing grammar coverage:");
  for (const item of missing) {
    console.error(`- ${item}`);
  }
  process.exit(1);
}

console.log(`Grammar coverage checks passed (${checks.reduce((sum, check) => sum + check.tokens.length, 0)} tokens).`);
