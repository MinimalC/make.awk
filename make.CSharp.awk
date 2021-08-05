#
# Gemeinfrei. Public Domain.
# 2021 Hans Riehm

#include "../make.awk/meta.awk"

function CSharp_prepare_preprocess(config,    a,b,c,class,d,e,f,g,h,i,j,k,l,m,member,members,n,namespace,namespaces,o,p,q,r,s,t,u,v,w,x,y,z) {

    C_prepare_preprocess(config)

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

    if (!("CLI" in parsed)) {
        parsed["CLI"]["name"] = "CLI"
        parsed["CLI"][++parsed["CLI"]["length"]] = "#"fix"include"fix"<meta/System.h>"
    }
    if (!("CLI" in preprocessed["C"])) {
        preprocessed["C"]["CLI"]["length"]
        C_preprocess("CLI", preprocessed["C"]["CLI"])
    }

    if (!("System" in CSharp_Types)) ; # TODO
}

function CSharp_prepare_precompile(config,    a,b,c,class,d,e,f,g,h,i,j,k,l,m,member,members,n,namespace,namespaces,o,p,q,r,s,t,u,v,w,x,y,z) {

    precompiled["CSharp"]["length"]
    Array_clear(precompiled["CSharp"])

    Array_clear(CSharp_Types)
    CSharp_Types["System"]["type"] = "namespace"
}

function CSharp_parse(fileName, file) {
    return C_parse(fileName, file)
}

function CSharp_preprocess(fileName, output) {
    return C_preprocess(fileName, output)
}

function CSharp_precompile(fileName, output,   a,A,AST,b,c,d,e,expressions,f,g,h,i,I,j,k,l,level,m,n,name,o,p,pre,q,r,s,S,t,T,u,using,v,w,x,y,z)
{
    Index_push("", fixFS, fix, "\0", "\n")
    for (z = 1; z <= preprocessed["CSharp"][fileName]["length"]; ++z) {
        Index_reset(preprocessed["CSharp"][fileName][z])
        if ($1 == "#") continue
        pre = String_concat(pre, fix, preprocessed["CSharp"][fileName][z])
    }
    Index_pop()

    A = AST["length"] = 1
    S = AST[A]["length"] = 1
    T = AST[A][S]["length"] = 1
    using["length"]

Index_push(pre, fixFS, fix, "\0", "\n")
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
        else using[++using["length"]] = name

        if ($(i + 1) == ",") continue
        if ($(i + 1) != ";") Index_append(i, ";")
        ++i

        output[++output["length"]] = Index_getRange(I, i)
        I = i + 1; S = ++AST[A]["length"]
        continue
    }

}
Index_pop()

if (DEBUG) { __debug("CSharp_using "); Array_debug(using) }
    return !r
}

function CSharp_compile(output,   a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z)
{

}

