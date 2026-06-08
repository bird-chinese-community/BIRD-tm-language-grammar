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
  {
    label: "BIRD 2.19 / 3.3 core configuration phrases",
    tokens: [
      "generate from",
      "generate to",
      "accept from",
      "accept to",
      "import limit",
      "export limit",
      "tx class",
      "tx dscp",
      "tx priority",
      "rx buffer",
      "tx length",
      "check link",
      "debug latency",
      "debug latency limit",
      "watchdog warning",
      "watchdog timeout",
      "min settle time",
      "max settle time",
      "gc threshold",
      "export settle time",
      "allow bgp_local_pref",
      "allow bgp_med",
      "enable route refresh",
      "require extended next hop",
      "local role",
      "require roles",
      "merge paths",
      "netlink rx buffer",
      "mrtdump protocols",
    ],
  },
  {
    label: "BIRD 2.19 / 3.3 extended protocol phrases",
    tokens: [
      "enable enhanced route refresh",
      "require route refresh",
      "require enhanced route refresh",
      "enable as4",
      "require as4",
      "enable extended messages",
      "require extended messages",
      "require hostname",
      "require graceful restart",
      "require long lived graceful restart",
      "allow as sets",
      "disable after error",
      "disable after cease",
      "enforce first as",
      "neighbor range",
      "interface range",
      "next hop prefer global",
      "next hop prefer local",
      "require add paths",
      "next hop keep",
      "igp table",
      "system description",
      "system name",
      "tx buffer limit",
      "accept ipv4",
      "accept multihop",
      "min rx interval",
      "min tx interval",
      "min ra interval",
      "max ra interval",
      "default lifetime",
      "current hop limit",
      "next header",
      "icmp type",
      "icmp code",
      "tcp flags",
      "route aspa",
    ],
  },
  {
    label: "BIRD 2.19 OSPF, Babel, and RPKI phrases",
    tokens: [
      "stub router",
      "graceful restart aware",
      "graceful restart time",
      "ecmp limit",
      "merge external",
      "instance id",
      "default nssa",
      "default cost",
      "default cost2",
      "translator stability",
      "virtual link",
      "real broadcast",
      "ptp netmask",
      "strict nonbroadcast",
      "show ospf neighbors",
      "show ospf topology all",
      "show ospf state all",
      "show ospf lsadb",
      "randomize router id",
      "next hop ipv4",
      "authentication mac permissive",
      "show babel interfaces",
      "show babel entries",
      "refresh keep",
      "retry keep",
    ],
  },
  {
    label: "BIRD 2.19 Static and RPKI phrases",
    tokens: [
      "recursive mpls",
      "show static",
      "igp table",
      "check link",
      "transport tcp",
      "transport ssh",
      "authentication none",
      "authentication md5",
      "expire keep",
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
