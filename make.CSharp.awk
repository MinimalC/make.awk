#
# Gemeinfrei. Public Domain.

#include "run.awk"
#include "make.C.awk"

function CSharp_prepare_preprocess(config,    __,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) {

    if (typeof(CSharp_keywords) == "untyped") {
        CSharp_keywords["using"]
        CSharp_keywords["namespace"]

        CSharp_keywords["struct"]
        CSharp_keywords["enum"]
        CSharp_keywords["class"]
        CSharp_keywords["interface"]

        CSharp_keywords["const"]
        CSharp_keywords["volatile"]

        CSharp_keywords["public"]
        CSharp_keywords["protected"]
        CSharp_keywords["private"]
        CSharp_keywords["internal"]
        CSharp_keywords["new"]
        CSharp_keywords["abstract"]
        CSharp_keywords["override"]
        CSharp_keywords["static"]
        CSharp_keywords["virtual"]
        CSharp_keywords["sealed"]
        CSharp_keywords["extern"]

        CSharp_keywords["ref"]
        CSharp_keywords["out"]
        CSharp_keywords["params"]

        CSharp_keywords["checked"]
        CSharp_keywords["unchecked"]
    }
}

function CSharp_prepare_precompile(config,    __,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) {

    CSharp_Types["0length"]
    Array_clear(CSharp_Types)
    if (!("System" in CSharp_Types)) ; # TODO

    precomp["CSharp"]["0length"]
    # Array_clear(precomp["CSharp"])
}

function CSharp_parse(fileName, file) {
    return C_parse(fileName, file)
}

function CSharp_preprocess(fileName) {
    return C_preprocess(fileName, "", "CSharp")
}

function CSharp_precompile(name,    __,a,A,AST,b,c,d,e,expressions,f,g,h,i,I,j,k,l,level,m,n,o,p,pre,q,r,s,S,t,T,u,using,v,w,x,y,z)
{
    if (!preproc["CSharp"][name]["0length"]) return

    Index_push("", REFIX, FIX, "\0", "\n")
    for (z = 1; z <= preproc["CSharp"][name]["0length"]; ++z) {
        Index_reset(preproc["CSharp"][name][z])
        if ($1 == "#") continue
        pre = String_concat(pre, FIX, preproc["CSharp"][name][z])
    }
    Index_pop()

    A = AST["0length"] = 1
    S = AST[A]["0length"] = 1
    T = AST[A][S]["0length"] = 1
    using["0length"]

Index_push(pre, REFIX, FIX, "\0", "\n")
for (i = I = 1; i <= NF; ++i) {

    if ($i == "using" || (AST[A][S]["type"] == "using" && $i == ",")) {
        if ($i == "using") AST[A][S]["type"] = "using"
        name = ""
        for (n = i + 1; n <= NF; ++n) {
            if ($n ~ /^[a-zA-Z_][a-zA-Z_0-9]*$/) {
                if ($n in CSharp_keywords) { --n; break }
                name = String_concat(name, ".", $n)
                continue
            }
            if ($n == ".") continue
            --n; break
        }
        if (n == i) { __warning("make.awk: using without name"); continue }
        if (n > i + 1) { Index_removeRange(i + 2, n); n = i + 1; $n = name }
        ++i

        if (List_contains(using, name)) {
            __warning("make.awk: using "name" twice")
            Index_remove(i--)
            if ($i == ",") Index_remove(i--)
        }
        else using[++using["0length"]] = name

        if ($(i + 1) == ",") continue
        if ($(i + 1) != ";") Index_append(i, ";")
        ++i

        precomp["CSharp"][ ++precomp["CSharp"]["0length"] ] = Index_getRange(I, i)
        I = i + 1; S = ++AST[A]["0length"]
        continue
    }

}
Index_pop()

if (DEBUG) { __debug("CSharp_using "); Array_debug(using) }
    return !r
}

#function CSharp_compile(   __,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z)
#{
#    for (z = 1; z <= precomp["CSharp"]["0length"]; ++z)
#        compiled["CSharp"][++compiled["CSharp"]["0length"]] = precomp["CSharp"][z]
#    return 1
#}
