#
# Gemeinfrei. Public Domain.
# 2020 - 2021 Hans Riehm

#include "run.awk"
@include "make.C.parse.awk"
@include "make.C.preprocess.awk"
@include "make.C.precompile.awk"

function C_compile(name,   __,a,b,c,l,n,o,options,p,pre,t,target,x,y,z)
{
    if (!(name in precomp["C"]) || !precomp["C"][name]["0length"]) return

    pre["0length"]
#    Index_pullArray(pre, precomp["C"], REFIX, " ")
    Index_push("", "", "")
    for (z = 1; z <= precomp["C"][name]["0length"]; ++z) {
        Index_reset(precomp["C"][name][z])
    for (n = 1; n <= NF; ++n) {
        if ($n ~ REFIX){ $n = " ";      Index_reset() }   # U0001 to U0020
        if ($n == "¢") { $n = "cent";   Index_reset() }   # U00A2
        if ($n == "£") { $n = "Pound";  Index_reset() }   # U00A3
        if ($n == "¥") { $n = "Yen";    Index_reset() }   # U00A5
        if ($n == "§") { $n = "PG";     Index_reset() }   # U00A7
        if ($n == "µ") { $n = "micro";  Index_reset() }   # U00B5
        if ($n == "¸") { $n = "cedi";   Index_reset() }   # U00B8
        if ($n == "π") { $n = "PI";     Index_reset() }   # U03C0
        if ($n == "€") { $n = "Euro";   Index_reset() }   # U20AC
        if ($n == "₤") { $n = "Lira";   Index_reset() }   # U20A4
        if ($n == "₱") { $n = "Peso";   Index_reset() }   # U20B1
        if ($n == "₿") { $n = "BTC";    Index_reset() }   # U20BF
#        if ($n ~ /[À-ÖÙ-öù-퟿]/) {   # U00C0-U00D6 or U00D9-U00F6 or U00F9-UD7FF
#            $n = "X"__HEX(Char_codepoint($n)); Index_reset()
#        }
    }
        pre[ ++pre["0length"] ] = $0
    }
    Index_pop()

    if (C_link_shared) options = "-fPIC"

    target = "C"
    if (C_compiler == "gcc") target = "ASM"

    if (target == "ASM") {
        precomp[target][name]["0length"]
        if (C_compiler_coprocess(options, pre, precomp[target][name], target)) return
    }
    else {
        compiled[target][name]["0length"]
        if (C_compiler_coprocess(options, pre, compiled[target][name], target)) return
    }
    return 1
}

function C_compiler_preprocess(final_options, input, output,    a,b,c,command,d,e,f,g,h,i,j,k,l,m,n,o,options,p,q,r,report,s,t,u,v,w,x,y,z) {
    options = "-E"
    input["0length"]
    File_printTo(input, TEMP_DIR".make.c")
    options = options" "TEMP_DIR".make.c"

    r = __coprocess(C_compiler, options" "final_options, input, output)
    File_remove(TEMP_DIR".make.c", 1)
    return r
}

function C_compiler_coprocess(final_options, input, output, target,    a,b,c,command,d,e,f,g,h,i,j,k,l,m,n,o,options,p,q,r,report,s,t,u,v,w,x,y,z) {

    options = "-c"
    if (target == "ASM") options = "-S"
    else if (target && target != "C") __warning("make.awk: C_compiler_coprocess: Unknown target "target)

    if (C_compiler == "gcc") {
        options = options" -xc -fpreprocessed -fcommon"
        options = options" -g" # -On
        if (STANDARD == "MINIMAL") {
            options = options" -nostdinc -fvisibility=hidden"
            options = options" -fno-jump-tables -fomit-frame-pointer -fno-stack-protector" # -fno-plt
            options = options" -fno-exceptions -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-dwarf2-cfi-asm"
        }
    }
    options = options" -o "TEMP_DIR".make.o "TEMP_DIR".make.c"
    input["0length"]
    File_printTo(input, TEMP_DIR".make.c")
    report["0length"]
    r = __pipe(C_compiler, options" "final_options, report)
    File_remove(TEMP_DIR".make.c", 1)
    output["0length"]
    if (!r) {
        File_read(output, TEMP_DIR".make.o", "\n", "\n")
        File_remove(TEMP_DIR".make.o", 1)
    }
    return r
}
