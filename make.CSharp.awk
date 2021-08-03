#
# Gemeinfrei. Public Domain.
# 2021 Hans Riehm

#include "../make.awk/meta.awk"

function CSharp_prepare(config,    a,b,c,class,d,e,f,g,h,i,j,k,l,m,member,n,namespace,namespaces,o,p,q,r,s,t,u,v,w,x,y,z)
{
    if (!("CLR" in parsed)) {
        parsed["CLR"]["name"] = "CLR"
        parsed["CLR"][++parsed["CLR"]["length"]] = "#"fix"include"fix"<meta/System.h>"
    }
    C_preprocess("CLR", preprocessed["C"])

    if (!("System" in CSharp_Types)) {
        # read from C_defines
        for (n in C_defines) {
            if (n !~ /_namespace$/) continue
            namespace = substr(n, 1, length(n) - 10)
            namespaces["length"] = split(namespace, namespaces, "_")

            for (c in C_defines) {
                if (c == namespace"_namespace") continue
                if (c !~ "^"namespace"_") continue

                Array_clear(m)
                m["length"] = split(c, m, "_")

                # now read System.Object.toString from System_Object_toString__amd64
                for (x = 1; x <= m["length"]; ++x)
                    if (m[x] == "") break
                for (y = x; y <= m["length"]; ++y)
                    Array_remove(m, y)

                if (m["length"] > namespaces["length"] + 2) continue

                # now the last is MemberName toString
                member = m[m["length"]]
                Array_remove(m, m["length"])

                # all others are Namespace.ClassName
                class = String_join(m, ".")

                if (!(class in CSharp_Types))
                    CSharp_Types[class]["type"]
            }
        }
    }
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

function CSharp_parse(fileName, file) {
    return C_parse(fileName, file)
}

function CSharp_preprocess(fileName, output) {
    return C_preprocess(fileName, output)
}

function CSharp_precompile(output,   a,A,AST,b,c,d,e,E,expressions,f,g,h,i,I,j,k,l,level,m,n,name,o,p,pre,q,r,s,t,u,using,v,w,x,y,z)
{
    Index_push("", fixFS, fix, "\0", "\n")
    for (z = 1; z <= preprocessed["CSharp"]["length"]; ++z) {
        Index_reset(preprocessed["CSharp"][z])
        if ($1 == "#") continue
        pre = String_concat(pre, fix, preprocessed["CSharp"][z])
    }
    Index_pop()

    A = AST["length"] = 1
    E = AST[A]["length"] = 1
    using["length"]

Index_push(pre, fixFS, fix, "\0", "\n")
for (i = I = 1; i <= NF; ++i) {

    if ($i == "using" || (AST[A][E]["type"] == "using" && $i == ",")) {
        if ($i == "using") AST[A][E]["type"] = "using"
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
        if (n == i) { __warning("make.awk: Using without name"); continue }
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
        I = i + 1; E = ++AST[A]["length"]
        continue
    }

}
Index_pop()

if (DEBUG) { __debug("CSharp_using "); Array_debug(using) }
    return !r
}

function CSharp_getName(I, file,    a,b,c,const,d,e,f,g,h,j,k,l,m,n,name,o,p,q,r,s,t,u,v,w,x,y,z)
{

    return name
}

function CSharp_compile(output,   a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z)
{

}

