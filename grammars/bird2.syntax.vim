" Vim syntax file
" Language: BIRD2 Configuration
" Scope:    BIRD2 config files (bird2, .conf)
" Version:  1.0.1-beta-20250808
" License:  MPL-2.0
" Author:   BIRD Chinese Community (Alice39s) <dev-bird@xmsl.dev>
" Based on: grammars/bird2.tmLanguage.json (1.0.5-20250808)

" ------------------------
" Initialization
" ------------------------
if exists("b:current_syntax")
  finish
endif

" ------------------------
" Syntax case
" ------------------------
syntax case match

" ------------------------
" Comments
" ------------------------
syn match  bird2Comment   "#.*$" contains=@Spell
syn region bird2Comment   start=/\/\*/ end=/\*\// contains=@Spell

" ------------------------
" Strings
" ------------------------
syn region bird2String    start=+\"+ skip=+\\\"+ end=+\"+
syn region bird2String    start=+'+  skip=+\\'+   end=+'+

" ------------------------
" Numbers & Units
" ------------------------
syn match  bird2Number    /\<0x[0-9A-Fa-f]\+\>/
syn match  bird2Number    /\<[0-9]\+\>/
syn match  bird2TimeUnit  /\<[0-9]\+\s*\(s\|ms\|us\)\>/ contains=bird2Number

" ------------------------
" IP addresses, prefixes, RDs
" ------------------------
" IPv4 with optional prefix and modifiers (+ or {m,n})
syn match bird2IPv4       /\<\%(25[0-5]\|2[0-4][0-9]\|1[0-9][0-9]\|[1-9]\?[0-9]\)\%(\.\%(25[0-5]\|2[0-4][0-9]\|1[0-9][0-9]\|[1-9]\?[0-9]\)\)\{3}\>\%(\/\%([0-2]\?[0-9]\|3[0-2]\)[+-]\?\|{\d\+,\?\d*}\)\?/
" IPv6 (simplified) with optional prefix and modifiers
syn match  bird2IPv6      /\<\%([0-9A-Fa-f]\{0,4}:\)\{2,7}[0-9A-Fa-f]\{0,4}\>\(\/\([0-9]\{1,3}\)\?[+-]\?\|{\d\+,\?\d*}\)\?/
syn match  bird2IPv6      /::\%([0-9A-Fa-f]\{0,4}:\)\{0,6}[0-9A-Fa-f]\{0,4}\(\/\([0-9]\{1,3}\)\?\)\?/
syn match  bird2IPv6      /\%([0-9A-Fa-f]\{0,4}:\)\{1,6}::\%([0-9A-Fa-f]\{0,4}:\)\{0,5}[0-9A-Fa-f]\{0,4}\(\/\([0-9]\{1,3}\)\?\)\?/
" Route Distinguisher (RD) like 65000:100
" RDs: ASN:NN, Type:ASN:NN, IPv4:NN
syn match  bird2RD        /\<\%([0-9]\+:[0-9]\+\|[0-2]:[0-9]\+:[0-9]\+\|\%([0-9]\{1,3}\.\)\{3}[0-9]\{1,3}:[0-9]\+\)\>/

" ------------------------
" Byte strings (hex blobs)
" ------------------------
syn match  bird2ByteStr   /\<\%([Hh][Ee][Xx]:\)\?\%([0-9A-Fa-f]\{2}[:\-\.\ ]\?\)\{2,}[0-9A-Fa-f]\{2}\>/

" ------------------------
" Core keywords (structure)
" ------------------------
syn keyword bird2Keyword  protocol template filter function table define include attribute eval
syn keyword bird2Keyword  router id log debug syslog stderr ipv4 ipv6 local as from where cost time
syn keyword bird2Keyword  limit action area interface source address neighbor via blackhole prohibit
syn keyword bird2Keyword  authentication none mac permissive password generate to algorithm hmac sha1 sha256 sha384 sha512 blake2s128 blake2s256 blake2b256 blake2b512
syn keyword bird2Keyword  flow4 flow6 dst src proto header dport sport icmp code tcp flags dscp dont_fragment is_fragment first_fragment last_fragment fragment label offset
syn keyword bird2Keyword  scan import export where all none limit action block
" Protocol types and extended config keywords from tmLanguage
syn keyword bird2Keyword  static rip ospf bgp babel rpki bfd device direct kernel pipe perf mrt aggregator l3vpn radv
syn keyword bird2Keyword  graceful restart preference disabled hold keepalive connect retry start delay error wait forget scan randomize router id
syn keyword bird2Keyword  interface type wired wireless tunnel rxcost limit hello update interval port tx class dscp priority rx buffer length check link rtt cost min max decay send timestamps
syn keyword bird2Keyword  authentication none mac permissive password generate accept from to algorithm hmac sha1 sha256 sha384 sha512 blake2s128 blake2s256 blake2b256 blake2b512 time
syn keyword bird2Keyword  hostname description debug log syslog stderr bird protocols tables channels timeouts passwords bfd confederation cluster stub dead neighbors area md5 multihop passive rfc1583compat tick ls retransmit transmit ack state database summary external nssa translator always candidate never role stability election action warn block disable keep filtered receive modify add delete withdraw unreachable blackhole prohibit unreach igp_metric localpref med origin community large_community ext_community as_path prepend weight gateway scope onlink recursive multipath igp channel sadr src learn persist via ng
syn keyword bird2Keyword  flow4 flow6 dst src proto header dport sport icmp code tcp flags dscp dont_fragment is_fragment first_fragment last_fragment fragment label offset
syn keyword bird2Keyword  vpn mpls aspa roa roa6

" Semantic modifiers
syn keyword bird2Keyword  self remote extended

" ------------------------
" Statements & control flow
" ------------------------
syn keyword bird2Statement if then else case for do while break continue return in
syn keyword bird2Statement accept reject error print printn
syn match   bird2CaseElse /\<else\s*:/

" ------------------------
" Types & constants
" ------------------------
syn keyword bird2Type     int bool ip prefix rd pair quad ec lc string bytestring bgpmask bgppath
syn keyword bird2Type     clist eclist lclist set enum route
syn keyword bird2Constant on off yes no true false empty unknown generic rt ro one ten
syn keyword bird2Constant SCOPE_HOST SCOPE_LINK SCOPE_SITE SCOPE_ORGANIZATION SCOPE_UNIVERSE
syn keyword bird2Constant RTS_STATIC RTS_INHERIT RTS_DEVICE RTS_RIP RTS_OSPF RTS_OSPF_IA RTS_OSPF_EXT1 RTS_OSPF_EXT2 RTS_BGP RTS_PIPE RTS_BABEL
syn keyword bird2Constant RTD_ROUTER RTD_DEVICE RTD_MULTIPATH RTD_BLACKHOLE RTD_UNREACHABLE RTD_PROHIBIT
syn keyword bird2Constant ROA_UNKNOWN ROA_INVALID ROA_VALID ASPA_UNKNOWN ASPA_INVALID ASPA_VALID
syn keyword bird2Constant NET_IP4 NET_IP6 NET_IP6_SADR NET_VPN4 NET_VPN6 NET_ROA4 NET_ROA6 NET_FLOW4 NET_FLOW6 NET_MPLS
syn keyword bird2Constant MPLS_POLICY_NONE MPLS_POLICY_STATIC MPLS_POLICY_PREFIX MPLS_POLICY_AGGREGATE MPLS_POLICY_VRF

" ------------------------
" Builtins and common helpers
" ------------------------
syn keyword bird2Function defined unset print printn roa_check aspa_check aspa_check_downstream aspa_check_upstream from_hex format prepend add delete filter empty reset bt_assert bt_test_suite bt_test_same ebgp_import ebgp_export
syn keyword bird2Property first last last_nonaggregated len asn data data1 data2 is_v4 ip src dst rd maxlen type mask min max
syn keyword bird2RouteAttr net scope preference from gw proto source dest ifname ifindex weight gw_mpls gw_mpls_stack onlink igp_metric mpls_label mpls_policy mpls_class bgp_path bgp_origin bgp_next_hop bgp_med bgp_local_pref bgp_community bgp_ext_community bgp_large_community bgp_originator_id bgp_cluster_list ospf_metric1 ospf_metric2 ospf_tag ospf_router_id rip_metric rip_tag mypath mylclist

" ------------------------
" Operators & punctuation
" ------------------------
syn match  bird2Operator  /\V==\|!=\|>=\|<=\|<\|>\|=\|~\|!~\|&&\|||\|!\|->\|+\|-\|*\|\/\|%\|../
syn match  bird2Accessor  /\./
syn match  bird2Delimiter /[;:,{}()\[\]]/

" ------------------------
" Neighbor/source/next-hop and import/export statements
" ------------------------
syn match  bird2Neighbor  /\<neighbor\>\s\+\%([0-9A-Fa-f:.]\)\+\s\+\%(%\s*'[^']\+'\)\?\s\+as\s\+[0-9]\+\>/ contains=bird2Keyword,bird2IPv4,bird2IPv6,bird2String,bird2Number
syn match  bird2SrcAddr   /\<source\s\+address\s\+\%([0-9A-Fa-f:.]\)\+\>/ contains=bird2Keyword,bird2IPv4,bird2IPv6
syn match  bird2NextHop   /\<next\s\+hop\s\+\(ipv4\|ipv6\)\s\+\S\+/ contains=bird2Keyword,bird2IPv4,bird2IPv6
syn match  bird2NextHopKw /\<next\s\+hop\s\+self\>/ contains=bird2Keyword
syn match  bird2ENH       /\<extended\s\+next\s\+hop\s\+\(on\|off\)\>/ contains=bird2Keyword,bird2Constant
syn region bird2ExportWhere start=/\<export\s\+where\>/ end=/;/ contains=ALLBUT,Spell
syn region bird2ImportInline start=/\<import\s\+filter\s*{/ end=/}/ contains=ALLBUT,Spell
syn match  bird2ImportRef /\<import\s\+filter\s\+[A-Za-z_][A-Za-z0-9_]*\>/ contains=bird2Keyword,bird2FilterName

" Templates, filters, functions, protocols
syn region bird2Template  start=/\<template\>\s\+[A-Za-z_][A-Za-z0-9_]*\s\+[A-Za-z_][A-Za-z0-9_]*\s*{/ end=/}/ contains=ALLBUT,Spell
syn region bird2FilterDef start=/\<filter\>\s\+[A-Za-z_][A-Za-z0-9_]*\s*{/ end=/}/ contains=ALLBUT,Spell
syn region bird2FuncDef   start=/\<function\>\s\+[A-Za-z_][A-Za-z0-9_]*\s*(/ end=/}/ contains=ALLBUT,Spell
syn region bird2Protocol  start=/\<protocol\>\s\+[A-Za-z_][A-Za-z0-9_]*\%\s\+[A-Za-z_][A-Za-z0-9_]*\%\(\s\+from\s\+[A-Za-z_][A-Za-z0-9_]*\)\?\s*{/ end=/}/ contains=ALLBUT,Spell

" BGP path list [= ... =]
syn region bird2BgpPath   start=/\[=/ end=/=\]/ contains=bird2Number,bird2Operator,bird2Wildcard
syn match  bird2Wildcard  /[*?+]/

" Filter names and user variables
syn match  bird2FilterName /\<[A-Za-z_][A-Za-z0-9_]*_filter\>/
syn match  bird2UserVar    /\<[A-Z][A-Za-z0-9_]*\>/

" Function/method calls and property access
syn match  bird2FuncCall    /\<[A-Za-z_][A-Za-z0-9_]*\s*(/ contains=bird2Function
syn match  bird2MethodCall  /\.\s*[A-Za-z_][A-Za-z0-9_]*\s*(/ contains=bird2Accessor
syn match  bird2PropertyRef /\.\s*[A-Za-z_][A-Za-z0-9_]*/ contains=bird2Accessor

" Variable declarations and print statements
syn match  bird2VarDecl   /\<\(int\|bool\|ip\|prefix\|rd\|pair\|quad\|ec\|lc\|string\|bytestring\|bgpmask\|bgppath\|clist\|eclist\|lclist\|set\|enum\|route\)\s\+[A-Za-z_][A-Za-z0-9_]*\s*\(=\|;\)/ contains=bird2Type
syn region bird2Print     start=/\<\(print\|printn\)\>/ end=/;/ contains=ALLBUT,Spell

" Block/set/tuple punctuation
syn match  bird2Terminator /;/
syn match  bird2Comma      /,/

" ------------------------
" Links to default highlight groups
" ------------------------
hi def link bird2Comment     Comment
hi def link bird2String      String
hi def link bird2Number      Number
hi def link bird2TimeUnit    Number
hi def link bird2IPv4        Constant
hi def link bird2IPv6        Constant
hi def link bird2RD          Constant
hi def link bird2ByteStr     Constant
hi def link bird2Keyword     Keyword
hi def link bird2Statement   Statement
hi def link bird2CaseElse    Statement
hi def link bird2Type        Type
hi def link bird2Constant    Constant
hi def link bird2Function    Function
hi def link bird2Property    Identifier
hi def link bird2RouteAttr   Identifier
hi def link bird2Identifier  Identifier
hi def link bird2Operator    Operator
hi def link bird2Accessor    Delimiter
hi def link bird2Delimiter   Delimiter

hi def link bird2Neighbor    Statement
hi def link bird2SrcAddr     Statement
hi def link bird2NextHop     Statement
hi def link bird2NextHopKw   Statement
hi def link bird2ENH         Statement
hi def link bird2ExportWhere Statement
hi def link bird2ImportInline Statement
hi def link bird2ImportRef   Statement

hi def link bird2Template    Structure
hi def link bird2FilterDef   Structure
hi def link bird2FuncDef     Structure
hi def link bird2Protocol    Structure

hi def link bird2BgpPath     Special
hi def link bird2Wildcard    Special
hi def link bird2FilterName  Function
hi def link bird2UserVar     Identifier
hi def link bird2FuncCall    Function
hi def link bird2MethodCall  Function
hi def link bird2PropertyRef Identifier
hi def link bird2VarDecl     Identifier
hi def link bird2Print       Statement
hi def link bird2Terminator  Delimiter
hi def link bird2Comma       Delimiter

let b:current_syntax = 'bird2'

" vim: ts=2 sw=2 et
