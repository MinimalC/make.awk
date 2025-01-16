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
#                __debug(" # newline")
            continue
        }
        if ($i ~ /^\s*$/) {
#                __debug(" # whitespace")
            continue
        }
        if (newline && $i == "#") {
            n = i + 1; while (n <= NF) if ($n ~ /\n/) break ; else ++n
                { r = ""; for (o = i; o < n; ++o) r = r" "$o; __debug(r) }
            i = n
            continue
        }

#                __debug(" # break")
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
    AST[level]["0length"] = zeile = newline = 1

    for (z = 1; z <= preproc["C"][name]["0length"]; ++z) {
        if (preproc["C"][name][z])
            pre = pre FIX preproc["C"][name][z] FIX"\n"
        else
            pre = pre "\n"
    }
    Index_push(pre, REFIX, FIX, "\n", "\n")
    for (i = 1; i <= NF; ++i) {

        i = C_precompile_whitespace(i, newline)
        if (NF < i) break
        newline = 0

        # now comment out everything which is not expected


        if ($i == "*" || ($i == "(" && $(i + 1) == "*")) {
            n = i; while (n <= NF) {
                if ($n == "*") {
                    AST[level][zeile]["pointer"] = AST[level][zeile]["pointer"]"*"
                    ++n; continue
                }
                if ($n == "(" && $(n + 1) == "*") {
                    AST[level][zeile]["pointer"] = AST[level][zeile]["pointer"]"(*"
                    n += 2; continue
                }
                break
            }
            i = n - 1
            continue
        }
        if ($i == "{") {
            AST[level][zeile]["{ }"] = AST[level][zeile]["{ }"]"{"
            __debug(String_repeat("\t", level)" # Zeile "zeile": { klämmerle up")
            continue
        }
        if ($i == "}") {
            if (l = length(AST[level][zeile]["{ }"])) {
                AST[level][zeile]["{ }"] = substr(AST[level][zeile]["{ }"], 1, l - 1)
                if (!(l = length(AST[level][zeile]["{ }"])))
                    delete AST[level][zeile]["{ }"]
                __debug(String_repeat("\t", level)" # Zeile "zeile": } klämmerle down")
                continue
            }
            if (level == 0) {
                __warning(" # Zeile "zeile": too much klämmerle }")
                continue
            }
            __debug(String_repeat("\t", level - 1)" # Zeile "zeile": } "AST[level]["AST"])
            zeile = AST[--level]["0length"]
            continue
        }
        if ($i == "(") {
            AST[level][zeile]["( )"] = AST[level][zeile]["( )"]"("
            __debug(String_repeat("\t", level)" # Zeile "zeile": ( klämmerle up")
            continue
        }
        if ($i == ")") {
            if (l = length(AST[level][zeile]["( )"])) {
                AST[level][zeile]["( )"] = substr(AST[level][zeile]["( )"], 1, l - 1)
                if (!(l = length(AST[level][zeile]["( )"])))
                    delete AST[level][zeile]["( )"]
                __debug(String_repeat("\t", level)" # Zeile "zeile": ) klämmerle down")
                continue
            }
            if (level == 0) {
                __warning(" # Zeile "zeile": too much klämmerle )")
                continue
            }
            was = AST[level]["AST"]
            __debug(String_repeat("\t", level - 1)" # Zeile "zeile": ) "was)
            delete AST[level]["AST"]
            zeile = AST[--level]["0length"]
            continue
        }
        if ($i == ",") {
            Array_debug(AST[level][zeile], level, " # Zeile "zeile" ,")
            if (AST[level]["AST"] == "arguments")
                if ("type" in AST[level][zeile]) delete AST[level][zeile]["type"]
            if ("pointer" in AST[level][zeile]) delete AST[level][zeile]["pointer"]
            if ("name" in AST[level][zeile]) delete AST[level][zeile]["name"]
            continue
        }
        if ($i == ";") {
            Array_debug(AST[level][zeile], level, " # Zeile "zeile" ;")
            # is the old one finished yet?
            delete AST[level]["AST"]
            zeile = ++AST[level]["0length"]
            continue
        }
        if ($i ~ /^[0-9]/) {
            __debug(String_repeat("\t", level)" # Zeile "zeile": "$i)
            continue
        }


        if ($i == "typedef" || $i == "extern" || $i == "volatile" || $i == "const") {
            AST[level][zeile][$i] = 1
            continue
        }

        if ($i == "void" || $i == "_Bool" || $i == "double" || $i == "float") {
            if (AST[level][zeile]["type"]) __warning(String_repeat("\t", level)" # Zeile "zeile": type "$i" was already "AST[level][zeile]["type"])
            AST[level][zeile]["type"] = $i
            continue
        }
        else if ($i == "unsigned" || $i == "signed" || $i == "char" || $i == "short" || $i == "int" || $i == "long") {
            if (AST[level][zeile]["type"]) __warning(String_repeat("\t", level)" # Zeile "zeile": type "$i" was already "AST[level][zeile]["type"])

            n = i + 1; while (n <= NF && $n == "unsigned" || $n == "signed" || $n == "char" || $n == "short" || $n == "int" || $n == "long") ++n
            AST[level][zeile]["type"] = Index_getRange(i, n - 1, " ")
            i = n - 1
            continue
        }
        else if ($i == "struct" || $i == "union" || $i == "enum") {
            if (AST[level][zeile]["type"]) __warning(String_repeat("\t", level)" # Zeile "zeile": type "$i" was already "AST[level][zeile]["type"])

            n = C_precompile_whitespace(i + 1)
            if (is_CName($n)) {
                $i = $i" "$n ; Index_remove(n)
                if (!($i in C_types)) C_types[$i]["baseType"]
            }
            AST[level][zeile]["type"] = was = $i

            n = C_precompile_whitespace(n)
            if ($n == "{") {
                __debug(String_repeat("\t", level)" # Zeile "zeile": "was" {")
                zeile = ++AST[++level]["0length"]
                AST[level]["AST"] = was
            }
            else
                __debug(String_repeat("\t", level)" # Zeile "zeile": "was)
            i = n
            continue
        }

        if ($i in C_types) {
            if (AST[level][zeile]["type"]) __warning(String_repeat("\t", level)" # Zeile "zeile": type "$i" was already "AST[level][zeile]["type"])
            AST[level][zeile]["type"] = $i
            __debug(String_repeat("\t", level)" # Zeile "zeile": "$i" (type)")
            continue
        }

        if (is_CName($i)) {
            was = $i

            if ("pointer" in AST[level][zeile] && index(AST[level][zeile]["pointer"], "(") && $(i + 1) == ")") {
                AST[level][zeile]["pointer"] = AST[level][zeile]["pointer"]")"
                ++i
            }

            n = C_precompile_whitespace(i + 1)

            if ("typedef" in AST[level][zeile]) {
                type = AST[level][zeile]["type"]
                if ("pointer" in AST[level][zeile])
                    type = type" "AST[level][zeile]["pointer"]
                C_types[was]["baseType"] = type
                __debug(String_repeat("\t", level)" # Zeile "zeile": typedef "type" "was)
            }
            else  {
                AST[level][zeile]["name"] = was
                __debug(String_repeat("\t", level)" # Zeile "zeile": "was" (name)")
            }

            if ($n == "(") {
                __debug(String_repeat("\t", level)" # Zeile "zeile": "was" arguments (")
                zeile = ++AST[++level]["0length"]
                AST[level]["AST"] = "arguments"
                i = n
            }
            continue
        }

        __warning(String_repeat("\t", level)" # unknown token X"__HEX($i)" "$i)
    }
    pre1["0length"]
    Index_pullArray(pre1, Index_pop(), REFIX, FIX, "\n", "\n")
    Index_push("", REFIX, FIX, "\n", "\n")
    for (z = 1; z <= pre1["0length"]; ++z) {
        Index_reset(pre1[z])
        for (n = 1; n <= NF; ++n) if ($n == "") Index_remove(n--)
        precomp["C"][name][ ++precomp["C"][name]["0length"] ] = $0
    }
    Index_pop()
    return 1
}
