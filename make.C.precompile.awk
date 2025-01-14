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

function C_precompile_whitespace(i, newline,   __, n,o,r) {

    for (i = i ? i : 1; i <= NF; ++i) {

        if ($i ~ /^\n+$/) {
            newline = 1
#if (DEBUG == 5) __debug(" # newline")
            continue
        }
        if ($i ~ /^\s*$/) {
#if (DEBUG == 5) __debug(" # whitespace")
            continue
        }
        if (newline && $i == "#") {
            n = i + 1; while (n <= NF) if ($n ~ /\n/) break ; else ++n
if (DEBUG == 5) { r = ""; for (o = i; o < n; ++o) r = r" "$o; __debug(r) }
            i = n
            continue
        }

#if (DEBUG == 5) __debug(" # break")
        break
    }

    return i
}

function C_precompile(name,    __,a,AST,b,c,d,e,f,g,h,i,j,k,l,level,m,n,newline,o,p,pre,pre1,q,r,s,t,type,u,v,w,was,x,y,z,zeile)
{
    if (!(name in preproc["C"]) || !preproc["C"][name]["0length"]) return

if (DEBUG != 5) {
    for (z = 1; z <= preproc["C"][name]["0length"]; ++z)
        precomp["C"][name][ ++precomp["C"][name]["0length"] ] = preproc["C"][name][z]
    return 1
}

    # C_precompile is PROTOTYPE

    level = 0
    AST[level]["AST"] = "global"
    AST[level]["0length"] = zeile = 1
    newline = 1

    for (z = 1; z <= preproc["C"][name]["0length"]; ++z) {
        pre = String_concat(pre, FIX"\n"FIX, preproc["C"][name][z])
    }
    Index_push(pre, REFIX, FIX, "\n", "\n")
    for (i = 1; i <= NF; ++i) {

        i = C_precompile_whitespace(i, newline)
        if (NF < i) break
        newline = 0

        # now comment out everything which is not expected


        if ($i == "{") {
            AST[level][zeile]["{ }"] = AST[level][zeile]["{ }"]"{"
if (DEBUG == 5) __debug(" # klämmerle up")
            continue
        }
        if ($i == "}") {
            if (l = length(AST[level][zeile]["{ }"])) {
                AST[level][zeile]["{ }"] = substr(AST[level][zeile]["{ }"], 1, l - 1)
if (DEBUG == 5) __debug(" # klämmerle down")
                continue
            }
            # was = AST[level]["AST"]
if (DEBUG == 5) __debug(" # type: "AST[level]["AST"]" level down")
            # is this one finished yet?
            Array_clear(AST[level])
            zeile = AST[--level]["0length"]
            continue
        }
        if ($i == ";") {
if (DEBUG == 5) Array_debug(AST[level][zeile], level, " # Zeile "zeile":")
            # is the old one finished yet?
            zeile = ++AST[level]["0length"]
            continue
        }


        if ($i == "typedef" || $i == "extern" || $i == "volatile") {
            was = $i
            AST[level][zeile][was] = 1
            continue
        }

        if ($i == "void") {
if (DEBUG == 5) if (AST[level][zeile]["type"]) __warning(" # type "$i" was already "AST[level][zeile]["type"])
            AST[level][zeile]["type"] = "void"
            continue
        }
        if ($i == "unsigned" || $i == "signed" || $i == "_Bool" || $i == "char" || $i == "short" || $i == "int" || $i == "long" || $i == "double" || $i == "float") {
if (DEBUG == 5) if (AST[level][zeile]["type"]) __warning(" # type "$i" was already "AST[level][zeile]["type"])
            n = i + 1; while (n <= NF && $n == "int" || $n == "long") ++n
            AST[level][zeile]["type"] = Index_getRange(i, --n, " ")
            i = n
            continue
        }
        if ($i == "*") {
            n = i + 1; while (n <= NF && $n == "*") ++n
            for (v = i; v < n; ++v) AST[level][zeile]["pointer"] = AST[level][zeile]["pointer"]"*"
            i = --n
            continue
        }

        if ($i == "struct" || $i == "union" || $i == "enum") {
if (DEBUG == 5) if (AST[level][zeile]["type"]) __warning(" # type "$i" was already "AST[level][zeile]["type"])

            n = i + 1
            n = C_precompile_whitespace(n)
            if (is_CName($n)) {
                $i = $i" "$n ; Index_remove(n--)
            }
            AST[level][zeile]["type"] = $i

            n = C_precompile_whitespace(n)
            if ($n == "{") {
                was = AST[level][zeile]["type"]
if (DEBUG == 5) __debug(" # type "was" level up")
                AST[++level]["0length"] = zeile = 1
                AST[level]["AST"] = was
            }
            i = n
            continue
        }

        if (is_CName($i)) {
            AST[level][zeile]["name"] = $i
            continue
        }


if (DEBUG == 5) __warning(" # unknown token X"__HEX(Char_codepoint($i))" "$i)

    }
    Index_pullArray(precomp["C"][name], Index_pop(), REFIX, FIX, "\n"FIX, "\n")
# if (DEBUG == 5) __debug
    return 1
}
