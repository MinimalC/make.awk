#!/usr/bin/awk -f
# Gemeinfrei. Public Domain.
# 2020 Hans Riehm

@include "../make.awk/meta.awk"
#include "../make.awk/make.awk"
@include "../make.awk/make.C.awk"

BEGIN {
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
            paramI = index(ARGV[argI], "=")
            paramName = substr(ARGV[argI], 1, paramI - 1)
            paramWert = substr(ARGV[argI], paramI + 1)
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
            if (paramName == "debug") DEBUG = paramWert; else
        __error("Unknown argument: \""paramName "\" = \""paramWert"\"")
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

    Array_add(types, "void")
    Array_add(types, "unsigned")
    Array_add(types, "signed")
    Array_add(types, "char")
    Array_add(types, "short")
    Array_add(types, "int")
    Array_add(types, "long")
    Array_add(types, "float")
    Array_add(types, "double")

#    target = gcc_coprocess("-E", "/* Gemeinfrei */\n# include <stdint.h>")

    target = gcc_precompile()
    Array_insert(origin, 1, target)

    Array_add(defines, "_XOPEN_SOURCE")
    defines["_XOPEN_SOURCE"]["body"] = 1100
    Array_add(defines, "_XOPEN_SOURCE_EXTENDED")
    defines["_XOPEN_SOURCE_EXTENDED"]["body"] = 1

    for (n = 1; n <= origin["length"]; ++n) {
        fun = get_FileNameExt(origin[n])
        if (!(fun in formatExt)) {
            __error("No Format for FileName."fun)
            continue
        }
        fun = formatExt[fun]"_precompileFile"
        if (!(fun in FUNCTAB)) {
            __error("No Format function "fun)
            continue
        }
        @fun(origin[n])
    }

if (DEBUG == 2 || DEBUG == 3 || DEBUG == 5) { __error("Defines: "); Array_error(defines) }
if (DEBUG == 6) { __error("Types: "); Array_error(types) }

    if ((m = "make"make) in FUNCTAB) @m()

    exit
}

function gcc_precompile(    h, i, j, k, l, m, n, o) {

    i = ".preprocess.C.gcc.c"
    print "/* Gemeinfrei */" > i
    print "#include <stdint.h>" > i
    close(i)

    o = ".preprocess.C.gcc...pre.c"
    system("gcc -std=c11 -E "i"  > "o)
    system("gcc -std=c11 -dM -E "i" | sort >> "o)

    return o
}
