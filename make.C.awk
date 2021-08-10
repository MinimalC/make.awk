#
# Gemeinfrei. Public Domain.
# 2020 - 2021 Hans Riehm

#include "../make.awk/meta.awk"
@include "../make.awk/make.C_parse.awk"
@include "../make.awk/make.C_preprocess.awk"

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

function C_precompile(    __,c,f,h,i,n,name,z)
{
    if (!preproc["C"]["length"]) return

    # C_precompile is PROTOTYPE

    precomp["C"][ precomp["C"]["length"] ] = "#"FIX (++precomp["C"]["length"]) FIX"\"make.awk\""

    for (n in preproc["C"]) {
        if (n == "length" || n ~ /^[0-9]/) continue
        if (n !~ /^__FILE__./) continue

        precomp["C"][ ++precomp["C"]["length"] ] = preproc["C"][n]
    }

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
    Index_pullArray(pre, precomp["C"], REFIX, " ")

    options = ""
    options = options" -c -fPIC"
    if (Compiler == "gcc") options = options" -xc -fpreprocessed"

    if (CCompiler_coprocess(options, pre, ".make.o")) return

    compiled["C"]["length"]
    File_read(compiled["C"], ".make.o", "\n", "\n")
    File_remove(".make.o", 1)
    return 1
}

function __gcc(options, input, output, directory) {
    return __command("awk", options, input, output, directory)
}

function Compiler_version(    ) {
    return __command(Compiler, "-dumpversion")
}

function uname_machine(    m,n,o,output) {
    return __command("uname", "-m")
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
