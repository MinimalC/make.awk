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
    input[++input["length"]] = "# define _GNU_SOURCE 1"
#    input[++input["length"]] = "# define _XOPEN_SOURCE 1100"
#    input[++input["length"]] = "# define _XOPEN_SOURCE_EXTENDED 1"

    input[++input["length"]] = "# define CHAR_BIT 8"
    input[++input["length"]] = "# define CHAR_MIN (-CHAR_MAX - 1)"
    input[++input["length"]] = "# define CHAR_MAX 0x7F"
    input[++input["length"]] = "# define UCHAR_MAX 0xFF"

    input[++input["length"]] = "# define SHORT_MIN (-SHORT_MAX - 1)"
    input[++input["length"]] = "# define SHORT_MAX 0x7FFF"
    input[++input["length"]] = "# define USHORT_MAX 0xFFFF"

    input[++input["length"]] = "# define INT_MIN (-INT_MAX - 1)"
    input[++input["length"]] = "# define INT_MAX 0x7FFFFFFF"
    input[++input["length"]] = "# define UINT_MAX 0xFFFFFFFF"

    input[++input["length"]] = "# define LONG_MIN (-LONG_MAX - 1L)"
    input[++input["length"]] = "# define LONG_MAX 0x7FFFFFFFFFFFFFFFL"
    input[++input["length"]] = "# define ULONG_MAX 0xFFFFFFFFFFFFFFFFL"

#    input[++input["length"]] = "# include <stdint.h>"

    output["name"] = "gcc"
    gcc_sort_coprocess("-dM -E", input, output)
#    gcc_coprocess("-E", "", output)
    C_parse("gcc", output)
    C_preprocess("gcc")

    for (n = 1; n <= origin["length"]; ++n) {
        f = get_FileNameExt(origin[n])
        if (!(f in formatExt)) { __error("No Format for FileName."f); continue }
        f = formatExt[f]"_precompile"
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
    else __error("make.awk: No function "m)

    exit
}

function make_parse(    a,b,c,d,e,f) {
    for (e = 1; e <= parsed["length"]; ++e) File_print(parsed[parsed[e]])
}

function make_precompile(    a,b,c,d,e,f, o,p,pprecompiled,q, x,y,z) {

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

function make_compile(    a,b,c,d,e,f, o,p,pprecompiled,q, x,y,z,Z) {

    Index_push("", fixFS, " ", "\0", "\n")
    for (z = 1; z <= precompiled["length"]; ++z) {
        $0 = precompiled[z]; Index_reset()
        pprecompiled[++pprecompiled["length"]] = $0
    }
    Index_pop()

    if (0 == gcc_coprocess(" -c -fpreprocessed ", pprecompiled, ".make.o")) {
        Array_clear(compiled)
        File_read(compiled, ".make.o", "\0")
        File_print(compiled, "\0", "\0")
    }
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
            output[++output["length"]] = $0
        }
    }
    Index_pop()
    if (y == -1) {
        __error("Command doesn't exist: "command)
        return
    }
    return close(command)
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
            output[++output["length"]] = $0
        }
    }
    Index_pop()
    if (y == -1) {
        __error("Command doesn't exist: "command)
        return
    }
    return close(command)
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
