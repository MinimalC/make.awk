#!/usr/bin/awk -f
# Gemeinfrei. Public Domain.
# 2020 Hans Riehm

@include "../make.awk/meta.awk"
@include "../make.awk/make.C.awk"
@include "../make.awk/make.CSharp.awk"

BEGIN { BEGIN_make() } # END { }

function BEGIN_make(    a,argI,b,c,d,e,f,format,g,h,i,input,j,k,l,m,make,n,
                        o,origin,output,p,paramName,paramWert,q,r,rendered,s,t,u,v,w,x,y,z) {
    FS="";OFS="";RS="\0";ORS="\n"
    fixFS = @/\x01/ #\s*\x01?/
    fix = "\x01"

    make = "compile"
    if (ARGV_length() == 0) { __error("Usage: make.awk [parse|precompile|compile] [include] Program.c"); exit 1 }
    for (argI = 1; argI <= ARGV_length(); ++argI) {

        if (argI == 1 && "make_"ARGV[argI] in FUNCTAB) {
            make = ARGV[argI]
            ARGV[argI] = ""; continue
        }

        paramName = ""
        if (ARGV[argI] ~ /^.*=.*$/) {
            paramWert = index(ARGV[argI], "=")
            paramName = substr(ARGV[argI], 1, paramWert - 1)
            paramWert = substr(ARGV[argI], paramWert + 1)
        } else
        if (ARGV[argI] ~ /^\+.*$/) {
            paramName = substr(ARGV[argI], 2)
            paramWert = 1
        }
        if (ARGV[argI] ~ /^-.*$/) {
            paramName = substr(ARGV[argI], 2)
            paramWert = 0
        }
        if (paramName) {
            # if (paramName == "Namespace") Namespace = paramWert; else
            if (paramName ~ /^D/) {
                paramName = substr(paramName, 2)
                defines[paramName]["body"] = paramWert
            } else
            if (paramName == "debug") DEBUG = paramWert; else
        __warning("Unknown argument: \""paramName "\" = \""paramWert"\"")
            ARGV[argI] = ""; continue
        }
        if (Directory_exists(ARGV[argI])) {
            Array_add(includeDirs, ARGV[argI])
            ARGV[argI] = ""; continue
        }
        if (!File_exists(ARGV[argI])) {
            __error("File not found: "ARGV[argI])
            ARGV[argI] = ""; continue
        }
        Array_add(origin, ARGV[argI])
        ARGV[argI] = ""
    }
    if (!((m = "make_"make) in FUNCTAB)) __error("make.awk: Unknown method "m)

    format["h"] = "C"
    format["c"] = "C"
    format["inc"] = "C"
    format["cs"] = "CSharp"

    format[1] = "C"
    format[2] = "CSharp"
    format[3] = "ASM"
    format["length"] = 3

    C_prepare()

    for (n = 1; n <= origin["length"]; ++n) {
        e = get_FileNameExt(origin[n])
        if (!(e in format)) { __error("No Format for FileName."e); Array_remove(origin, n--); continue }
    }

    for (f = 1; f <= format["length"]; ++f) {
    for (n = 1; n <= origin["length"]; ++n) {
        e = get_FileNameExt(origin[n])
        if (format[e] != format[f]) continue

        c = format[e]"_"make
        if (c in FUNCTAB) @c(origin[n])
        else { __error("No Format function "c); continue }
    } }

if (DEBUG) {
    __debug("Defines: ")
    for (n in defines) {
        Index_push(defines[n]["body"], "", ""); for (r = 1; r <= NF; ++r) if ($r ~ fixFS) $r = " "; rendered = Index_pop()
        if (defines[n]["isFunction"])
             __debug("# define "n" ( "defines[n]["arguments"]["text"]" ) "rendered)
        else __debug("# define "n"  "rendered)
    }
    __debug("Types: "); Array_debug(types)
}

    @m()
    exit
}

function make_parse(    m,n,o,p) {
    for (n in parsed) File_print(parsed[n])
}

function make_precompile(    h,i,j,k,l,m,n,o,p,pprecompiled,q, x,y,z) {

    Index_push("", "", "", "\0", "\n")
    for (z = 1; z <= precompiled["length"]; ++z) {
        Index_reset(precompiled[z])
if (!DEBUG) { for (i = 1; i <= NF; ++i) if ($i ~ fixFS) $i = " " }
        pprecompiled[++pprecompiled["length"]] = $0
    }
    Index_pop()

    File_print(pprecompiled)
}

function make_compile() {

    if (precompiled["length"]) C_compile()

    File_print(compiled, "\0", "\0")
}

