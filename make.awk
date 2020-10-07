#!/usr/bin/awk -f
# Gemeinfrei. Public Domain.
# 2020 Hans Riehm

@include "../make.awk/meta.awk"
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

    types["void"]
    types["unsigned"]
    types["signed"]
    types["char"]
    types["short"]
    types["int"]
    types["long"]
    types["float"]
    types["double"]

    input["name"] = "gcc"
#    String_read(input, "/* Gemeinfrei */\n# include <stdint.h>")
    input[++input["length"]] = "/* Gemeinfrei */"
    input[++input["length"]] = "# include <stdint.h>"
    output["name"] = "gcc"
    gcc_sort_coprocess("-dM -E", input, output)
    gcc_coprocess("-E", input, output)
    C_parse(output)
    C_precompile(parsed["gcc"])

#    target = gcc_precompile()
#    Array_insert(origin, 1, target)

    defines["_XOPEN_SOURCE"]["body"] = 1100
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

if (DEBUG == 2 || DEBUG == 3 || DEBUG == 5) { __debug("Defines: "); Array_debug(defines) }
if (DEBUG == 6) { __debug("Types: "); Array_debug(types) }

    if ((m = "make_"make) in FUNCTAB) @m()

    exit
}

function make_parse(    a,b,c,d,e,f) {
    for (e = 1; e <= parsed["length"]; ++e) File_print(parsed[parsed[e]])
}

function make_precompile(    a,b,c,d,e,f, o,p,pprecompiled,q, x,y,z) {

    Index_push("", fixFS, " ", "\0", "\n")
    for (z = 1; z <= precompiled["length"]; ++z) {
        $0 = precompiled[z]; Index_reset()
        Z = ++pprecompiled["length"]; pprecompiled[Z] = $0
    }
    Index_pop()

    File_print(pprecompiled)
}

function make_compile(    a,b,c,d,e,f, o,p,pprecompiled,q, x,y,z,Z) {

    Index_push("", fixFS, " ", "\0", "\n")
    for (z = 1; z <= precompiled["length"]; ++z) {
        $0 = precompiled[z]; Index_reset()
        Z = ++pprecompiled["length"]; pprecompiled[Z] = $0
    }
    Index_pop()

    gcc_coprocess(" -c -fpreprocessed ", pprecompiled, ".make.o")

    Array_clear(compiled)
    File_read(compiled, ".make.o", "\0")
    File_print(compiled, "\0", "\0")
}

function gcc_coprocess(options, input, output,    a,b,c,command,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) {
    if (typeof(input) == "string" && input) options = options" "input
    else options = options" -"
    if (typeof(output) == "string" && output) options = options" -o "output
    command = "gcc -xc "options
    if (typeof(input) == "array") {
        for (i = 1; i <= input["length"]; ++i) {
            print input[i] |& command
        }
    } else print "" |& command
    close(command, "to")
    Index_push("", "", "", "\n", "\n")
    while (0 < y = ( command |& getline )) {
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
    if (typeof(input) == "string" && input) options = options" "input
    else options = options" -"
    if (typeof(output) == "string" && output) options = options" -o "output
    command = "gcc -xc "options" | sort"
    if (typeof(input) == "array") {
        for (i = 1; i <= input["length"]; ++i) {
            print input[i] |& command
        }
    } else print "" |& command
    close(command, "to")
    Index_push("", "", "", "\n", "\n")
    while (0 < y = ( command |& getline )) {
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
