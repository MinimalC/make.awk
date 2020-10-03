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
            if (paramName ~ /^D/) {
                paramName = substr(paramName, 2)
                Array_add(defines, paramName)
                defines[paramName]["body"] = paramWert
            } else
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

    input["name"] = "gcc"
    String_read(input, "/* Gemeinfrei */\n# include <stdint.h>")
#    input[++input["length"]] = "/* Gemeinfrei */"
#    input[++input["length"]] = "# include <stdint.h>"
    output["name"] = "gcc"
    gcc_coprocess("-E", input, output)
    gcc_sort_coprocess("-dM -E", input, output)
    C_parse(output)
    C_precompile(parsed["gcc"])

#    target = gcc_precompile()
#    Array_insert(origin, 1, target)

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

    if ((m = "make_"make) in FUNCTAB) @m()

    exit
}

function make_parse(    a,b,c,d,e,f) {
    for (e = 1; e <= parsed["length"]; ++e) File_print(parsed[parsed[e]])
}

function make_precompile(    a,b,c,d,e,f, x,y,z) {

    if (!DEBUG) Index_push("", fixFS, " ", "\0", "\n")
    else        Index_push("", fixFS, fix, "\0", "\n")
    for (z = 1; z <= precompiled["length"]; ++z) {
        $0 = precompiled[z]; Index_reset()
        print
    }
    Index_pop()
}

function make_compile(    a,b,c,d,e,f, x,y,z,Z) {

    Index_push("", fixFS, " ", "\0", "\n")
    for (z = 1; z <= precompiled["length"]; ++z) {
        $0 = precompiled[z]; Index_reset()
        Z = ++compiled["length"]; compiled[Z] = $0
    }
    Index_pop()

    gcc_coprocess(" -fpreprocessed ", compiled, ".make.out")
}

function gcc_coprocess(options, input, output,    a,b,c,command,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) {
    if (typeof(input) == "string") options = options" "input
    if (typeof(output) == "string") options = options" -o "output
    command = "gcc -xc "options" -"
    if (typeof(input) == "array") {
        for (i = 1; i <= input["length"]; ++i) {
            print input[i] |& command
        }
        close(command, "to")
    }
    Index_push("", "", "", "\n", "\n")
    while (1) {
        if (typeof(input) == "array") {
            if (!(0 < y = ( command |& getline ))) break
        } else {
            if (!(0 < y = ( command | getline ))) break
        }
        if (typeof(output) == "array") {
            z = ++output["length"]
            output[z] = $0
        }
        else r = String_concat(r, ORS, $0)
    }
    Index_pop()
    if (y == -1) {
        __error("Command doesn't exist: "command)
        return
    }
    close(command)
    return r
}

function gcc_sort_coprocess(options, input, output,    a,b,c,command,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) {
    command = "gcc -xc "options" - | sort"
    for (i = 1; i <= input["length"]; ++i) {
        print input[i] |& command
    }
    close(command, "to")
    x = output["length"]
    Index_push("", "", "", "\n", "\n")
    while (0 < y = ( command |& getline )) {
        z = ++output["length"]
        output[z] = $0
    }
    Index_pop()
    if (y == -1) {
        __error("Command doesn't exist: "command)
        return
    }
    return z - x
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
