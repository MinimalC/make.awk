#!/usr/bin/awk -f
# Gemeinfrei. Public Domain.
# 2020 Hans Riehm

@include "../make.awk/meta.awk"
@include "../make.awk/make.C.awk"
#include "../make.awk/make.CSharp.awk"

BEGIN { BEGIN_make() } # END { }

function BEGIN_make(    a,argI,b,c,d,e,f,formatExt,g,h,i,input,j,k,l,m,make,n,
                        o,origin,output,p,paramName,paramWert,q,r,s,t,u,v,w,x,y,z) {
    FS="";OFS="";RS="\0";ORS="\n"
    fixFS = @/\x01/
    fix = "\x01"

    make = "precompile"

    if (ARGV_length() == 0) { __error("Usage: make.awk include Program.c"); exit 1 }

    Array_add(includeDirs, "/usr/include/")
    Array_add(includeDirs, "/usr/include/x86_64-linux-gnu/")
    Array_add(includeDirs, "/usr/lib/gcc/x86_64-linux-gnu/7/include/")

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
            __error("File doesn't exist: "ARGV[argI])
            ARGV[argI] = ""; continue
        }

        Array_add(origin, ARGV[argI])
        ARGV[argI] = ""
    }

    formatExt["h"] = "C"
    formatExt["c"] = "C"
    formatExt["inc"] = "C"
#    formatExt["cs"] = "CSharp"

    C_prepare()

    for (n = 1; n <= origin["length"]; ++n) {
        e = get_FileNameExt(origin[n])
        if (!(e in formatExt)) { __error("No Format for FileName."e); continue }

        f = formatExt[e]"_precompile"
        if (f in FUNCTAB) @f(origin[n])
        else { __error("No Format function "f); continue }
    }

if (DEBUG == 2 || DEBUG == 3 || DEBUG == 5 || DEBUG == 6) {
    __debug("Defines: ")
    for (n in defines) {
        if (defines[n]["isFunction"])
             __debug("# define "n" ( "defines[n]["arguments"]["text"]" ) "defines[n]["body"])
        else __debug("# define "n"  "defines[n]["body"])
    }
}
if (DEBUG == 6) { __debug("Types: "); Array_debug(types) }

    if ((m = "make_"make) in FUNCTAB) @m()
    else __error("make.awk: Unknown method "m)

    exit
}

function make_parse(    m,n,o,p) {
    for (n in parsed) File_print(parsed[n])
}

function make_precompile(    o,p,pprecompiled,q, x,y,z) {

if (DEBUG == 6)
    Index_push("", fixFS, fix, "\0", "\n")
else
    Index_push("", fixFS, " ", "\0", "\n")
    for (z = 1; z <= precompiled["length"]; ++z) {
        $0 = precompiled[z]; Index_reset()
        pprecompiled[++pprecompiled["length"]] = $0
    }
    Index_pop()

    File_print(pprecompiled)
}

function make_compile() {

    if (precompiled["length"]) C_compile()

    File_print(compiled, "\0", "\0")
}

