#
# Gemeinfrei. Public Domain.
# 2020 - 2021 Hans Riehm

#include "run.awk"
@include "make.C_parse.awk"
@include "make.C_preprocess.awk"

function C_prepare_precompile(config,    a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) {

    C_types["void"]
    Array_clear(C_types)
    C_types["void"]["isLiteral"]
    C_types["unsigned"]["isLiteral"]
    C_types["signed"]["isLiteral"]
    C_types["_Bool"]["isLiteral"]
    C_types["char"]["isLiteral"]
    C_types["short"]["isLiteral"]
    C_types["int"]["isLiteral"]
    C_types["long"]["isLiteral"]
    C_types["double"]["isLiteral"]
    C_types["float"]["isLiteral"]
    C_types["_Float32"]["isLiteral"]
    C_types["_Float32x"]["isLiteral"]
    C_types["_Float64"]["isLiteral"]
    C_types["_Float64x"]["isLiteral"]
    C_types["_Float128"]["isLiteral"]
    C_types["__builtin_va_list"]["isLiteral"]

    precomp["C"]["length"]
    Array_clear(precomp["C"])
}

function C_precompile(    __,a,b,c,d,e,f,g,h,i,j,k,l,m,n,name,o,p,q,r,s,t,u,v,w,x,y,z)
{
    if (!preproc["C"]["length"]) return



    # C_precompile is PROTOTYPE

    # precomp["C"][ precomp["C"]["length"] ] = "#"FIX (++precomp["C"]["length"]) FIX"\"make.awk\""

    for (n = 1; n <= preproc["C"]["length"]; ++n) {
        name = preproc["C"][n]
    for (z = 1; z <= preproc["C"][name]["length"]; ++z)
        precomp["C"][ ++precomp["C"]["length"] ] = preproc["C"][name][z]
    }

    return 1
}

function C_compile(    a,b,c,n,o,options,p,pre,x,y,z)
{
    pre["length"]
    precomp["C"]["length"]
#    Index_pullArray(pre, precomp["C"], REFIX, " ")
    Index_push("", "", "")
    for (z = 1; z <= precomp["C"]["length"]; ++z) {
        Index_reset(precomp["C"][z])
    for (n = 1; n <= NF; ++n) {
        if ($n ~ REFIX){ $n = " ";      Index_reset() }   # U0001 to U0020
        if ($n == "¢") { $n = "cent";   Index_reset() }   # U00A2
        if ($n == "£") { $n = "Pound";  Index_reset() }   # U00A3
        if ($n == "¥") { $n = "Yen";    Index_reset() }   # U00A5
        if ($n == "§") { $n = "PARAGRAF";Index_reset()}   # U00A7
        if ($n == "µ") { $n = "micro";  Index_reset() }   # U00B5
        if ($n == "¸") { $n = "cedi";   Index_reset() }   # U00B8
        if ($n == "π") { $n = "PI";     Index_reset() }   # U03C0
        if ($n == "€") { $n = "Euro";   Index_reset() }   # U20AC
        if ($n == "₤") { $n = "Lira";   Index_reset() }   # U20A4
        if ($n == "₱") { $n = "Peso";   Index_reset() }   # U20B1
        if ($n == "₿") { $n = "BTC";    Index_reset() }   # U20BF
        if ($n ~ /[À-ÖÙ-öù-퟿]/) {   # U00C0-U00D6 or U00D9-U00F6 or U00F9-UD7FF
            $n = "X"__HEX(Char_codepoint($n)); Index_reset()
        }
    }
        pre[ ++pre["length"] ] = $0
    }
    Index_pop()

    options = ""
    options = options" -c -fPIC"
    if (Compiler == "gcc") options = options" -xc -fpreprocessed"

    if (CCompiler_coprocess(options, pre, ".make.o")) return

    compiled["C"]["length"]
    File_read(compiled["C"], ".make.o", "\n", "\n")
    File_remove(".make.o", 1)
    return 1
}

function CCompiler_coprocess(options, input, output,    a,b,c,command,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) {
    if (typeof(input) == "string" && input) options = options" "input
    else options = options" -"
    if (typeof(output) == "string" && output) options = options" -o "output
    return __coprocess(Compiler, options, input, output)
}

function __gcc_sort_coprocess(options, input, output,    a,b,c,command,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) {
    if (typeof(input) == "string" && input) options = options" "input
    else options = options" -"
    if (typeof(output) == "string" && output) options = options" -o "output
    command = "gcc -xc "options" | sort"
    if (typeof(input) == "array")
        for (i = 1; i <= input["length"]; ++i)
            print input[i] |& command
    else print "" |& command
    close(command, "to")
    Index_push("", "", "", "\n", "\n")
    while (0 < y = ( command |& getline ))
        if (typeof(output) == "array")
            output[++output["length"]] = $0
    Index_pop()
    if (y == -1) { __error("Command doesn't exist: "command); return }
    return close(command)
}
