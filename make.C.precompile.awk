#
# Gemeinfrei. Public Domain.

#include "run.awk"
#include "make.C.awk"

function C_prepare_precompile(config,    a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) {

    if (typeof(C_types) == "untyped") {
        C_types["void"]["baseType"]
        C_types["unsigned"]["baseType"]
        C_types["signed"]["baseType"]
        C_types["_Atomic"]["baseType"]
        C_types["_Bool"]["baseType"]
        C_types["char"]["baseType"]
        C_types["short"]["baseType"]
        C_types["int"]["baseType"]
        C_types["long"]["baseType"]
        C_types["double"]["baseType"]
        C_types["float"]["baseType"]
        C_types["_Float32"]["baseType"]
        C_types["_Float32x"]["baseType"]
        C_types["_Float64"]["baseType"]
        C_types["_Float64x"]["baseType"]
        C_types["_Float128"]["baseType"]
        C_types["__builtin_va_list"]["baseType"]
    }

    precomp["C"]["0length"]
}

function C_precompile(name,    __,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z)
{
    if (!(name in preproc["C"]) || !preproc["C"][name]["0length"]) return

    # C_precompile is PROTOTYPE

    for (z = 1; z <= preproc["C"][name]["0length"]; ++z)
        precomp["C"][name][ ++precomp["C"][name]["0length"] ] = preproc["C"][name][z]

    #Index_push("", REFIX, FIX, "\0", "\n")
    #for (z = 1; z <= preproc["C"][name]["0length"]; ++z) {
    #    if (!preproc["C"][name][z] || preproc["C"][name][z] ~ /^#/) {
    #        precomp["C"][name][ ++precomp["C"][name]["0length"] ] = preproc["C"][name][z]
    #        continue
    #    }
    #    Index_reset(preproc["C"][name][z])
    #    t = 0; b = ""; s = ""
    #    for (i = 1; i <= NF; ++i) {
    #        if ($i == "typedef") { t = 1; continue }
    #        if ($i == "struct" && is_CName($(i + 1))) {
    #            $i = $i" "$(i + 1)
    #            Index_remove(i + 1)
    #            C_types[$i]["baseType"]
    #            b = $i
    #            continue
    #        }
    #        if (t && b) {
    #            if ($i == "*") { s = String_concat(s, " ", "*"); continue }
    #            if (is_CName($i)) {
    #                C_types[$i]["baseType"] = String_concat(b, " ", s)
    #            }
    #            if ($i == "[" || $i == "]" || $i == "(" || $i == ")") continue # ignore?
    #            if ($i == ",") { s = ""; continue }
    #            if ($i == ";") { t = 0; b = ""; s = "" }
    #        }
    #    }
    #    precomp["C"][name][ ++precomp["C"][name]["0length"] ] = $0
    #}
    #Index_pop()

    return 1
}
