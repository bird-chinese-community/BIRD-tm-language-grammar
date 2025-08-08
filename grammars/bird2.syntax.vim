" Vim syntax file
" Language: BIRD2 Configuration
" Scope:    BIRD2 config files (bird2, .conf)
" Version:  1.0.6-20250808
" License:  MPL-2.0
" Author:   BIRD Chinese Community (Alice39s) <dev-bird@xmsl.dev>
" Based on: grammars/bird2.tmLanguage.json (1.0.6-20250808)

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
" Comments (repository.comments)
" ------------------------
syn match  bird2Comment   "#.*$" contains=@Spell
syn region bird2Comment   start=/\/\*/ end=/\*\// contains=@Spell

" ------------------------
" Strings (repository.strings)
" ------------------------
syn region bird2String    start=+"+ skip=+\\"+ end=+"+ contains=bird2Escape
syn region bird2String    start=+'+ skip=+\\'+ end=+'+
syn match  bird2Escape    "\\." contained

" ------------------------
" Numbers & Time Units (repository.numbers)
" ------------------------
syn match  bird2HexNumber   "\<0x[0-9a-fA-F]\+\>"
syn match  bird2Number      "\<[0-9]\+\>"
syn match  bird2TimeUnit    "\<[0-9]\+\s*\(s\|ms\|us\)\>" contains=bird2Number

" ------------------------
" IP Addresses (repository.ip-addresses)
" ------------------------
" IPv4 with optional prefix (simplified for Vim NFA)
syn match  bird2IPv4       "\<[0-9]\{1,3}\.[0-9]\{1,3}\.[0-9]\{1,3}\.[0-9]\{1,3}\>\%(\/[0-9]\{1,2}\)\?"
" IPv6 patterns (simplified for Vim NFA)
syn match  bird2IPv6       "\<[0-9a-fA-F:]\+::[0-9a-fA-F:]*\>\%(\/[0-9]\{1,3}\)\?"
syn match  bird2IPv6       "::[0-9a-fA-F:]\+\>\%(\/[0-9]\{1,3}\)\?"
syn match  bird2IPv6       "\<[0-9a-fA-F:]\{3,}\>\%(\/[0-9]\{1,3}\)\?"

" ------------------------
" VPN Route Distinguisher (repository.vpn-rd)
" ------------------------
syn match  bird2VpnRD      "\<[0-9]\+:[0-9]\+\>"
syn match  bird2VpnRD      "\<[0-9]\{1,3}\.[0-9]\{1,3}\.[0-9]\{1,3}\.[0-9]\{1,3}:[0-9]\+\>"

" ------------------------
" Byte Strings (repository.bytestrings)
" ------------------------
syn match  bird2ByteString "\<hex:[0-9a-fA-F]\{2}\%([:\-\s\.][0-9a-fA-F]\{2}\)\+\>"
syn match  bird2ByteString "\<[0-9a-fA-F]\{2}\%([:\-][0-9a-fA-F]\{2}\)\{2,}\>"
syn match  bird2ByteString "\<[0-9a-fA-F]\{32,}\>"

" ------------------------
" BGP Paths (repository.bgp-paths)
" ------------------------
syn region bird2BgpPath    start="\[=" end="=\]" contains=bird2BgpWildcard,bird2ASN,bird2Number
syn match  bird2BgpWildcard "[*?+]" contained
syn match  bird2ASN        "\<[0-9]\+\>" contained

" ------------------------
" Prefixes (repository.prefixes)
" ------------------------
syn match  bird2Prefix     "\<[0-9]\{1,3}\.[0-9]\{1,3}\.[0-9]\{1,3}\.[0-9]\{1,3}\/[0-9]\{1,2}\>\%([\+\-]\)\?"
syn match  bird2Prefix     "\<[0-9a-fA-F:]\+\/[0-9]\{1,3}\>\%([\+\-]\)\?"
syn match  bird2Prefix     "\<[0-9]\{1,3}\.[0-9]\{1,3}\.[0-9]\{1,3}\.[0-9]\{1,3}\/[0-9]\{1,2}{[0-9]\+,[0-9]\+}\>"

" ------------------------
" Filter Definitions (repository.filter-definitions)
" ------------------------
syn region bird2FilterDef  matchgroup=bird2Keyword start="\<filter\>\s\+\ze[a-zA-Z_][a-zA-Z0-9_]*\s*{" matchgroup=bird2Delimiter end="}" contains=bird2FilterName,@bird2All fold keepend
syn match  bird2FilterName "[a-zA-Z_][a-zA-Z0-9_]*" contained nextgroup=bird2FilterBody skipwhite skipnl
syn region bird2FilterBody matchgroup=bird2Delimiter start="{" end="}" contained contains=@bird2All fold

" ------------------------
" Function Definitions (repository.function-definitions)
" ------------------------
syn region bird2FunctionDef matchgroup=bird2Keyword start="\<function\>\s\+\ze[a-zA-Z_][a-zA-Z0-9_]*\s*(" matchgroup=bird2Delimiter end="}" contains=bird2FunctionName,bird2FunctionParams,@bird2All fold keepend
syn match  bird2FunctionName "[a-zA-Z_][a-zA-Z0-9_]*" contained nextgroup=bird2FunctionParams skipwhite
syn region bird2FunctionParams matchgroup=bird2Delimiter start="(" end=")" contained contains=bird2Type,bird2Variable nextgroup=bird2ReturnType,bird2FunctionBody skipwhite skipnl
syn match  bird2ReturnType "->" contained nextgroup=bird2Type skipwhite
syn region bird2FunctionBody matchgroup=bird2Delimiter start="{" end="}" contained contains=@bird2All fold

" ------------------------
" Template Definitions (repository.template-definitions)
" ------------------------
syn match  bird2TemplateDef "\<template\>\s\+[a-zA-Z_][a-zA-Z0-9_]*\s\+[a-zA-Z_][a-zA-Z0-9_]*\s*{" contains=bird2Keyword,bird2ProtocolTypeKw,bird2TemplateName nextgroup=bird2TemplateBody
syn match  bird2ProtocolType "[a-zA-Z_][a-zA-Z0-9_]*" contained nextgroup=bird2TemplateName skipwhite
syn match  bird2TemplateName "[a-zA-Z_][a-zA-Z0-9_]*" contained nextgroup=bird2TemplateBody skipwhite skipnl
syn region bird2TemplateBody matchgroup=bird2Delimiter start="{" end="}" contained contains=@bird2All fold

" ------------------------
" Protocol Definitions (repository.protocol-definitions)
" ------------------------
" Protocol with template
syn match  bird2ProtocolDefWithTemplate "\<protocol\>\s\+[a-zA-Z_][a-zA-Z0-9_]*\s\+[a-zA-Z_][a-zA-Z0-9_]*\s\+from\s\+[a-zA-Z_][a-zA-Z0-9_]*\s*{" contains=bird2Keyword,bird2ProtocolTypeKw,bird2ProtocolName,bird2TemplateName nextgroup=bird2ProtocolBody
" Protocol with name
syn match  bird2ProtocolDefWithName "\<protocol\>\s\+[a-zA-Z_][a-zA-Z0-9_]*\s\+[a-zA-Z_][a-zA-Z0-9_]*\s*{" contains=bird2Keyword,bird2ProtocolTypeKw,bird2ProtocolName nextgroup=bird2ProtocolBody
" Anonymous protocol
syn match  bird2ProtocolDefAnonymous "\<protocol\>\s\+[a-zA-Z_][a-zA-Z0-9_]*\s*{" contains=bird2Keyword,bird2ProtocolTypeKw nextgroup=bird2ProtocolBody
syn match  bird2ProtocolName "[a-zA-Z_][a-zA-Z0-9_]*" contained nextgroup=bird2ProtocolBody skipwhite skipnl
syn region bird2ProtocolBody matchgroup=bird2Delimiter start="{" end="}" contained contains=@bird2All fold

" ------------------------
" Next Hop Statements (repository.next-hop-statements)
" ------------------------
syn match  bird2NextHopIPv4 "\<next hop\>\s\+ipv4\s\+[0-9\.]\+" contains=bird2RoutingKw,bird2IPv4
syn match  bird2NextHopIPv6 "\<next hop\>\s\+ipv6\s\+[0-9a-fA-F:]\+" contains=bird2RoutingKw,bird2IPv6
syn match  bird2NextHopSelf "\<next hop\>\s\+self\>" contains=bird2RoutingKw,bird2SemanticModifier
syn match  bird2ExtendedNextHop "\<extended next hop\>\s\+\%(on\|off\)\>" contains=bird2RoutingKw,bird2SemanticModifier

" ------------------------
" Neighbor Statements (repository.neighbor-statements)
" ------------------------
syn match  bird2NeighborStmt "\<neighbor\>\s\+[0-9a-fA-F:.]\+\s*\%(%\s*'[^']\+'\)\?\s\+as\s\+[0-9]\+" contains=bird2RoutingKw,bird2IPv4,bird2IPv6,bird2String,bird2Number
syn match  bird2SourceAddress "\<source address\>\s\+[0-9a-fA-F:.]\+" contains=bird2RoutingKw,bird2IPv4,bird2IPv6

" ------------------------
" Import/Export Statements (repository.import-export-statements)
" ------------------------
syn match  bird2ImportFilter "\<import\>\s\+filter\s\+[a-zA-Z_][a-zA-Z0-9_]*" contains=bird2Keyword,bird2FilterReference
syn region bird2ImportFilterInline matchgroup=bird2Keyword start="\<import\>\s\+filter\s*{" matchgroup=bird2Delimiter end="}" contains=@bird2All fold keepend
syn region bird2ExportWhere matchgroup=bird2Keyword start="\<export\>\s\+where\>" end=";" contains=@bird2All
syn match  bird2ExportFilter "\<export\>\s\+filter\s\+[a-zA-Z_][a-zA-Z0-9_]*" contains=bird2Keyword,bird2FilterReference

" ------------------------
" Print Statements (repository.print-statements)
" ------------------------
syn region bird2PrintStmt  matchgroup=bird2Keyword start="\<\%(print\|printn\)\>" end=";" contains=@bird2All

" ------------------------
" Core Keywords (used in definitions)
" ------------------------
syn keyword bird2Keyword    protocol template filter function import export

" ------------------------
" Structural Keywords (repository.structural-keywords)
" ------------------------
syn keyword bird2ControlFlow if then else case for do while break continue return in
syn match   bird2CaseElse   "\<else\s*:"
syn keyword bird2FlowControl accept reject error
syn keyword bird2Structure  table define include attribute eval ipv4 ipv6 local as from where cost limit action

" ------------------------
" Functional Keywords (repository.functional-keywords)
" ------------------------
" Protocol types
syn keyword bird2ProtocolTypeKw static rip ospf bgp babel rpki bfd device direct kernel pipe perf mrt aggregator l3vpn radv
" Routing keywords
syn keyword bird2RoutingKw  graceful restart preference disabled hold keepalive connect retry start delay error wait forget scan randomize router id route neighbor
" Interface keywords
syn keyword bird2InterfaceKw interface type wired wireless tunnel rxcost limit hello update interval port tx class dscp priority rx buffer length check link rtt cost min max decay send timestamps
" Authentication keywords
syn keyword bird2AuthKw     authentication none mac permissive password generate accept from to algorithm hmac sha1 sha256 sha384 sha512 blake2s128 blake2s256 blake2b256 blake2b512
" Time keyword
syn keyword bird2TimeKw     time
" Config keywords
syn keyword bird2ConfigKw   hostname description debug log syslog stderr bird protocols tables channels timeouts passwords bfd confederation cluster stub dead neighbors area md5 multihop passive rfc1583compat tick ls retransmit transmit ack state database summary external nssa translator always candidate never role stability election action warn block disable keep filtered receive modify add delete withdraw unreachable blackhole prohibit unreach igp_metric localpref med origin community large_community ext_community as_path prepend weight gateway scope onlink recursive multipath igp channel sadr src learn persist via ng all none master4
" Flowspec keywords
syn keyword bird2FlowspecKw flow4 flow6 dst src proto header dport sport icmp code tcp flags dscp dont_fragment is_fragment first_fragment last_fragment fragment label offset
" Address keywords
syn keyword bird2AddressKw  vpn mpls aspa roa roa6

" ------------------------
" Semantic Modifiers (repository.semantic-modifiers)
" ------------------------
syn keyword bird2SemanticModifier self on off remote extended

" ------------------------
" Built-in Functions (repository.builtin-functions)
" ------------------------
syn keyword bird2BuiltinFunc defined unset print printn roa_check aspa_check aspa_check_downstream aspa_check_upstream from_hex format prepend add delete filter empty reset bt_assert bt_test_suite bt_test_same

" ------------------------
" Method Properties (repository.method-properties)
" ------------------------
syn keyword bird2Property   first last last_nonaggregated len asn data data1 data2 is_v4 ip src dst rd maxlen type mask min max

" ------------------------
" Route Attributes (repository.route-attributes)
" ------------------------
syn keyword bird2RouteAttr  net scope preference from gw proto source dest ifname ifindex weight gw_mpls gw_mpls_stack onlink igp_metric mpls_label mpls_policy mpls_class bgp_path bgp_origin bgp_next_hop bgp_med bgp_local_pref bgp_community bgp_ext_community bgp_large_community bgp_originator_id bgp_cluster_list ospf_metric1 ospf_metric2 ospf_tag ospf_router_id rip_metric rip_tag mypath mylclist

" ------------------------
" Data Types (repository.data-types)
" ------------------------
syn keyword bird2Type       int bool ip prefix rd pair quad ec lc string bytestring bgpmask bgppath clist eclist lclist set enum route

" ------------------------
" Operators (repository.operators)
" ------------------------
syn match  bird2Comparison  "=="
syn match  bird2Comparison  "!="
syn match  bird2Comparison  "<="
syn match  bird2Comparison  ">="
syn match  bird2Comparison  "<"
syn match  bird2Comparison  ">"
syn match  bird2Comparison  "\~"
syn match  bird2Comparison  "!\~"
syn match  bird2Logical     "&&"
syn match  bird2Logical     "||"
syn match  bird2Logical     "!"
syn match  bird2Logical     "->"
syn match  bird2Arithmetic  "+"
syn match  bird2Arithmetic  "-"
syn match  bird2Arithmetic  "\*"
syn match  bird2Arithmetic  "/"
syn match  bird2Arithmetic  "%"
syn match  bird2Range       "\.\."
syn match  bird2Assignment  "=" contained
syn match  bird2Accessor    "\."

" ------------------------
" Constants (repository.constants)
" ------------------------
" Boolean constants
syn keyword bird2BoolConst  on off yes no true false
" Special constants
syn keyword bird2SpecialConst empty unknown generic rt ro one ten
" Scope constants
syn keyword bird2ScopeConst SCOPE_HOST SCOPE_LINK SCOPE_SITE SCOPE_ORGANIZATION SCOPE_UNIVERSE
" Source constants
syn keyword bird2SourceConst RTS_STATIC RTS_INHERIT RTS_DEVICE RTS_RIP RTS_OSPF RTS_OSPF_IA RTS_OSPF_EXT1 RTS_OSPF_EXT2 RTS_BGP RTS_PIPE RTS_BABEL
" Destination constants
syn keyword bird2DestConst  RTD_ROUTER RTD_DEVICE RTD_MULTIPATH RTD_BLACKHOLE RTD_UNREACHABLE RTD_PROHIBIT
" ROA constants
syn keyword bird2RoaConst   ROA_UNKNOWN ROA_INVALID ROA_VALID
" ASPA constants
syn keyword bird2AspaConst  ASPA_UNKNOWN ASPA_INVALID ASPA_VALID
" Net type constants
syn keyword bird2NetConst   NET_IP4 NET_IP6 NET_IP6_SADR NET_VPN4 NET_VPN6 NET_ROA4 NET_ROA6 NET_FLOW4 NET_FLOW6 NET_MPLS
" MPLS constants
syn keyword bird2MplsConst  MPLS_POLICY_NONE MPLS_POLICY_STATIC MPLS_POLICY_PREFIX MPLS_POLICY_AGGREGATE MPLS_POLICY_VRF

" ------------------------
" Filter Names (repository.filter-names)
" ------------------------
syn match  bird2FilterReference "[a-zA-Z_][a-zA-Z0-9_]*_filter\>"

" ------------------------
" User Variables (repository.user-variables)
" ------------------------
syn match  bird2UserVariable "[A-Z][a-zA-Z0-9_]*\>"

" ------------------------
" Function Calls (repository.function-calls)
" ------------------------
syn match  bird2FunctionCall "[a-zA-Z_][a-zA-Z0-9_]*\ze\s*(" contains=bird2BuiltinFunc

" ------------------------
" Method Calls (repository.method-calls)
" ------------------------
syn match  bird2MethodCall  "\.\s*[a-zA-Z_][a-zA-Z0-9_]*\s*(" contains=bird2Accessor
syn match  bird2PropertyAccess "\.\s*[a-zA-Z_][a-zA-Z0-9_]*" contains=bird2Accessor,bird2Property

" ------------------------
" Variable Declarations (repository.variable-declarations)
" ------------------------
syn match  bird2VarDecl     "\<\%(int\|bool\|ip\|prefix\|rd\|pair\|quad\|ec\|lc\|string\|bytestring\|bgpmask\|bgppath\|clist\|eclist\|lclist\|set\|enum\|route\)\>\s\+[a-zA-Z_][a-zA-Z0-9_]*\s*\%(=\|;\)" contains=bird2Type,bird2Variable

" ------------------------
" Symbols/Variables (repository.symbols)
" ------------------------
syn match  bird2Variable    "[a-zA-Z_][a-zA-Z0-9_]*\>"

" ------------------------
" Blocks & Delimiters (repository.blocks)
" ------------------------
syn match  bird2Delimiter   "[{}()\[\];,]"

" ------------------------
" Cluster for all patterns
" ------------------------
syn cluster bird2All contains=bird2Comment,bird2String,bird2Escape,bird2HexNumber,bird2Number,bird2TimeUnit,bird2IPv4,bird2IPv6,bird2VpnRD,bird2ByteString,bird2BgpPath,bird2BgpWildcard,bird2ASN,bird2Prefix,bird2FilterDef,bird2FunctionDef,bird2TemplateDef,bird2ProtocolDefWithTemplate,bird2ProtocolDefWithName,bird2ProtocolDefAnonymous,bird2NextHopIPv4,bird2NextHopIPv6,bird2NextHopSelf,bird2ExtendedNextHop,bird2NeighborStmt,bird2SourceAddress,bird2ImportFilter,bird2ImportFilterInline,bird2ExportWhere,bird2ExportFilter,bird2PrintStmt,bird2ControlFlow,bird2CaseElse,bird2FlowControl,bird2Structure,bird2ProtocolTypeKw,bird2RoutingKw,bird2InterfaceKw,bird2AuthKw,bird2TimeKw,bird2ConfigKw,bird2FlowspecKw,bird2AddressKw,bird2SemanticModifier,bird2BuiltinFunc,bird2Property,bird2RouteAttr,bird2Type,bird2Comparison,bird2Logical,bird2Arithmetic,bird2Range,bird2Assignment,bird2Accessor,bird2BoolConst,bird2SpecialConst,bird2ScopeConst,bird2SourceConst,bird2DestConst,bird2RoaConst,bird2AspaConst,bird2NetConst,bird2MplsConst,bird2FilterReference,bird2UserVariable,bird2FunctionCall,bird2MethodCall,bird2PropertyAccess,bird2VarDecl,bird2Variable,bird2Delimiter,bird2Keyword

" ------------------------
" Links to default highlight groups
" ------------------------
hi def link bird2Comment          Comment
hi def link bird2String           String
hi def link bird2Escape           SpecialChar
hi def link bird2HexNumber        Number
hi def link bird2Number           Number
hi def link bird2TimeUnit         Number
hi def link bird2IPv4             Constant
hi def link bird2IPv6             Constant
hi def link bird2VpnRD            Constant
hi def link bird2ByteString       Constant
hi def link bird2BgpPath          Special
hi def link bird2BgpWildcard      Special
hi def link bird2ASN              Number
hi def link bird2Prefix           Constant

hi def link bird2FilterDef        Structure
hi def link bird2FilterName       Function
hi def link bird2FilterBody       Normal
hi def link bird2FunctionDef      Structure
hi def link bird2FunctionName     Function
hi def link bird2FunctionParams   Normal
hi def link bird2ReturnType       Operator
hi def link bird2FunctionBody     Normal
hi def link bird2TemplateDef      Structure
hi def link bird2ProtocolType     Type
hi def link bird2TemplateName     Function
hi def link bird2TemplateBody     Normal
hi def link bird2ProtocolDefWithTemplate Structure
hi def link bird2ProtocolDefWithName Structure
hi def link bird2ProtocolDefAnonymous Structure
hi def link bird2ProtocolName     Function
hi def link bird2ProtocolBody     Normal

hi def link bird2NextHopIPv4      Statement
hi def link bird2NextHopIPv6      Statement
hi def link bird2NextHopSelf      Statement
hi def link bird2ExtendedNextHop  Statement
hi def link bird2NeighborStmt     Statement
hi def link bird2SourceAddress    Statement
hi def link bird2ImportFilter     Statement
hi def link bird2ImportFilterInline Statement
hi def link bird2ExportWhere      Statement
hi def link bird2ExportFilter     Statement
hi def link bird2PrintStmt        Statement

hi def link bird2ControlFlow      Statement
hi def link bird2CaseElse         Statement
hi def link bird2FlowControl      Statement
hi def link bird2Structure        Keyword
hi def link bird2Keyword          Keyword
hi def link bird2ProtocolTypeKw   Keyword
hi def link bird2RoutingKw        Keyword
hi def link bird2InterfaceKw      Keyword
hi def link bird2AuthKw           Keyword
hi def link bird2TimeKw           Keyword
hi def link bird2ConfigKw         Keyword
hi def link bird2FlowspecKw       Keyword
hi def link bird2AddressKw        Keyword
hi def link bird2SemanticModifier Keyword

hi def link bird2BuiltinFunc      Function
hi def link bird2Property         Identifier
hi def link bird2RouteAttr        Identifier
hi def link bird2Type             Type

hi def link bird2Comparison       Operator
hi def link bird2Logical          Operator
hi def link bird2Arithmetic       Operator
hi def link bird2Range            Operator
hi def link bird2Assignment       Operator
hi def link bird2Accessor         Delimiter

hi def link bird2BoolConst        Constant
hi def link bird2SpecialConst     Constant
hi def link bird2ScopeConst       Constant
hi def link bird2SourceConst      Constant
hi def link bird2DestConst        Constant
hi def link bird2RoaConst         Constant
hi def link bird2AspaConst        Constant
hi def link bird2NetConst         Constant
hi def link bird2MplsConst        Constant

hi def link bird2FilterReference  Function
hi def link bird2UserVariable     Identifier
hi def link bird2FunctionCall     Function
hi def link bird2MethodCall       Function
hi def link bird2PropertyAccess   Identifier
hi def link bird2VarDecl          Identifier
hi def link bird2Variable         Normal
hi def link bird2Delimiter        Delimiter

" ------------------------
" Folding markers
" ------------------------
syn sync fromstart
setlocal foldmethod=syntax

let b:current_syntax = 'bird2'

" vim: ts=2 sw=2 et