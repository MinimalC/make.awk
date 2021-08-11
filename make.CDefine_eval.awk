#
# Gemeinfrei. Public Domain.
# 2020 Hans Riehm

#include "meta.awk"
#include "make.C.awk"

function CDefine_apply(i, file,
    __,a,arguments,b,c,code,d,defineBody,e,f,g,h,j,k,l,m,n,name,notapplied,o,p,q,r,rendered,s,t,u,v,w,x,y,z)
{
    if (!($i in C_defines)) return 1
    if (typeof(C_defines[$i]) != "array") return 1

    # Evaluate AWA
    name = $i
    # define AWA AWA
    if (typeof(C_noredefines) == "array" && name in C_noredefines) {
        __warning(file["name"]" Line "file["z"]": self-referencing define "name" "name)
        return 1
    }

if (DEBUG == 3) __debug(file["name"]" Line "file["z"]": applying "name)

    defineBody = C_defines[name]["body"]
    arguments["length"]
    if ("arguments" in C_defines[name]) {
        # define expression( arg1 , arg2 ) body
        l = C_defines[name]["arguments"]["length"]
        o = i; m = ""; n = 0; p = 0
        while (++o) {
            if (o > NF) {
                if (typeof(file["I"]) == "number" && file["I"] == Index["length"])
                {
                    if (file["z"] + 1 > file["length"]) break
                    if (file[file["z"] + 1] ~ /^#/) break
                    Index_append(NF, file[++file["z"]])
                    for (j = o; j <= NF; ++j) if ($j ~ /^\s*$/) Index_remove(j--)
                    C_defines["__LINE__"]["body"] = file["z"]
                    --o
                    continue
                }
                break
            }
            if ($o ~ /^\s*$/) { Index_remove(o--); continue } # clean
            if (o == i + 1) {
                if ($o != "(") break
                continue
            }
            if (!p && ($o == "," || $o == ")")) {
                if (l || n) {
                    a = ++arguments["length"]
                    arguments[a]["value"] = m
                    arguments[a]["length"] = n
                    m = ""; n = 0
                }
                if ($o == ",") continue
                break
            }
            if ($o == "(" || $o == "{") ++p
            if (p && ($o == ")" || $o == "}")) --p
            m = String_concat(m, FIX, $o)
            ++n
        }
        if ($(i + 1) != "(") {
if (DEBUG == 3) __debug(file["name"]" Line "file["z"]": not using "name)
            return 1
        }
        if ($o != ")") {
            __error(file["name"]" Line "file["z"]": define "name" expression without )") # i: "i" "$i" o: "o" "$o)
            Index_removeRange(i + 1, o - 1)
        }
        else Index_removeRange(i + 1, o)
if (DEBUG == 3) {
__debug("arguments: ( "C_defines[name]["arguments"]["text"]" )")
rendered = ""; for (a = 1; a <= arguments["length"]; ++a) rendered = rendered ( a > 1 ? " , " : "" ) arguments[a]["value"]
__debug("applying:  ( "rendered" )")
}
        if (C_defines[name]["arguments"][l] != "..." ? arguments["length"] < l : arguments["length"] < l - 1)
            __error(file["name"]" Line "file["z"]": using "name": Not enough arguments") # ("arguments["length"]" insteadof "l") "m)
        else if (arguments["length"] > l && C_defines[name]["arguments"][l] != "...")
            __error(file["name"]" Line "file["z"]": using "name": Too many arguments")
        for (n = 1; n <= arguments["length"]; ++n) {
            Index_push(arguments[n]["value"], REFIX, FIX)
            for (j = 1; j <= NF; ++j) {
                if ($j in C_defines) {
                    if ("arguments" in C_defines[$j] && $(j + 1) != "(") {
if (DEBUG == 3) __debug(file["name"]" Line "file["z"]": 2 not applying "$j)
                        continue
                    }
# if (DEBUG == 3) __debug(file["name"]" Line "file["z"]": 2 applying "$j)
                    m = CDefine_apply(j, file)
                    j += m - 1
                }
            }
            arguments[n]["length"] = NF
            arguments[n]["value"] = Index_pop()
        }
        Index_push(defineBody, REFIX, FIX)
        for (o = 1; o <= NF; ++o) {
            for (n = 1; n <= l; ++n) {
                if (n == l && C_defines[name]["arguments"][l] == "...") break
                if ($o == C_defines[name]["arguments"][n]) { # && !($(o - 1) == "." || $(o - 1) == "->")) {
                    if (o > 1 && $(o - 1) == "#") {
                        Index_push(arguments[n]["value"], "", "")
                        for (s = 1; s <= NF; ++s) {
                            if ($s ~ REFIX) { $s = " "; continue }
                            if (s > 1 && $s == "\"" && $(s - 1) != "\\") { $s = "\\\""; Index_reset(); ++s; continue }
                        }
                        $o = "\""Index_pop()"\""
                        #$o = "\""arguments[n]["value"]"\""
                        Index_remove(--o)
                        continue
                    }
                    $o = arguments[n]["value"]
                    o += arguments[n]["length"] - 1; Index_reset()
                    break
                }
            }
        }
        if (C_defines[name]["arguments"][l] == "...") {
            for (o = 1; o <= NF; ++o) {
                if ($o == "__VA_ARGS__") {
                    code = ""; a = 0
                    for (n = l; n <= arguments["length"]; ++n) {
                        code = String_concat(code, FIX","FIX, arguments[n]["value"])
                        a += arguments[n]["length"]
                        if (n > l) ++a
                    }
                    if (o > 1 && $(o - 1) == "##") {
                        Index_remove(--o); __warning(file["name"]" Line "file["z"]": Concatenating Variable Arguments")
                    }
                    if (o > 1 && $(o - 1) == "#") {
                        Index_push(code, "", "")
                        for (s = 1; s <= NF; ++s) {
                            if ($s ~ REFIX) { $s = " "; continue }
                            if (s > 1 && $s == "\"" && $(s - 1) != "\\") { $s = "\\\""; Index_reset(); ++s; continue }
                        }
                        $o = "\""Index_pop()"\""
                        #$o = "\""$o"\""
                        Index_remove(--o)
                        continue
                    }
                    if (!code) { if (o > 1 && $(o - 1) == ",") Index_remove(--o); Index_remove(o--) }
                    else {
                        $o = code
                        o += a - 1; Index_reset()
                    }
                }
            }
        }
        defineBody = Index_pop()
    }
    Index_push(defineBody, REFIX, FIX)
    for (o = 1; o <= NF; ++o) {
        # if ($o == "\\") { Index_remove(o--); continue }
        if ($o == "##") {
            s = ""
            if ($(o - 1) ~ /^[a-zA-Z_0-9]+$/) {
                s = $(o - 1)
                Index_remove(--o)
            }
            if ($(o + 1) ~ /^[a-zA-Z_0-9]+$/) {
                s = s $(o + 1)
                Index_remove(o + 1)
            }
            if (s == "") Index_remove(o--)
            else $o = s
            continue
        }
        if ($o == "#") {
            s = ""
            if ($(o + 1) ~ /^[a-zA-Z_0-9]+$/) {
                s = "\""$(o + 1)"\""
                Index_remove(o + 1)
            }
            if (s != "") $o = s
            else $o = "\"\""
            continue
        }
    }
    defineBody = Index_pop()
    if (defineBody == "") {
        # define unsafe  /* unsafe */
if (DEBUG == 3) __debug(file["name"]" Line "file["z"]": using "name" without body")
        Index_remove(i)
        return 0
    }
    Index_push(defineBody, REFIX, FIX)
    ++C_noredefines[name]
    notapplied = 0
    for (j = 1; j <= NF; ++j) {
        #if ($j == name) {
        #    __warning(file["name"]" Line "file["z"]": self-referencing define0 "name" "name)
        #    continue
        #}
        if ($j in C_defines) {
            if ("arguments" in C_defines[$j] && $(j + 1) != "(") {
if (DEBUG == 3) __debug(file["name"]" Line "file["z"]": 1 not applying "$j)
                ++notapplied
                continue
            }
#if (DEBUG == 3) __debug(file["name"]" Line "file["z"]": 1 applying "$j)
            n = CDefine_apply(j, file)
            j += n-1
        }
    }
    --C_noredefines[name]; if (!C_noredefines[name]) delete C_noredefines[name]
    Index_reset()
    n = NF
    defineBody = Index_pop()
    $i = defineBody
    Index_reset()

if (DEBUG == 3) {
rendered = Index_pull(defineBody, REFIX, " ")
if ("arguments" in C_defines[name]) {
__debug(file["name"]" Line "file["z"]": using "name" ("C_defines[name]["arguments"]["text"]")  "rendered)
# Array_debug(arguments)
} else __debug(file["name"]" Line "file["z"]": using "name"  "rendered)
}
    return n - notapplied
}

function CDefine_eval(expression,
    __, a, arguments, b, c, d, defineBody, e, f, g, h, i, j, k, l, m, n, name, number, o, p, q, r, s, t, u, v, w, x, y, z)
{
    Index_push(expression, REFIX, FIX)
    Index_reset()
    for (i = 1; i <= NF; ++i) {
        if ($i ~ /^\s*$/) Index_remove(i--)
        else if ($i == "\\") Index_remove(i--)
        else if ($i ~ /^\/\*/) Index_remove(i--)
        else if ($i ~ /^L?"/) Index_remove(i--)
    }
    for (i = 1; i <= NF; ++i) {
        if ($i ~ /^0x/) {
            $i = strtonum($i)
        }
        if ($i ~ /^L'/) {
            $i = substr($i, 2)
        }
        if ($i ~ /^'/) {
            if ($i ~ /^'\\x/) {
                n = substr($i, 4, length($i) - 4)
                $i = strtonum("0x"n)
            }
            else if ($i ~ /^'\\/) {
                # TODO
                n = substr($i, 3, length($i) - 3)
                $i = strtonum(n)
            }
            else {
                n = substr($i, 2, length($i) - 2)
                $i = chartonum(n)
            }
        }
        if ($i ~ /[lL]$/) {
            $i = substr($i, 1, length($i) - 1)
            if ($i ~ /[lL]$/)
                $i = substr($i, 1, length($i) - 1)
        }
        if ($i ~ /[uU]$/) {
            $i = substr($i, 1, length($i) - 1)
        }
        if ($i == "(") {
            m = ""
            p = 0; for (o = i + 1; o <= NF; ++o) {
                if ($o == "(" || $o == "{") ++p
                if ($o == ")" || $o == "}") { if (!p) break; --p }
                m = String_concat(m, FIX, $o)
            }
            Index_removeRange(i + 1, o)
            x = CDefine_eval(m)
            # Index_push(x, REFIX, FIX); n = NF; Index_pop()
            $i = x
            --i # i += n - 1
            continue
        }
        if ($i == "?") {
            q = ""
            for (n = 1; n < i; ++n) {
                q = String_concat(q, FIX, $n)
            }
            t = ""
            p = 0; for (o = i + 1; o <= NF; ++o) {
                if (!p && $o == ":") break
                if ($o == "(" || $o == "{") ++p
                if ($o == ")" || $o == "}") { if (p) --p }
                t = String_concat(t, FIX, $o)
            }
            if ($o != ":") __error("QuestionMark isn't followed by :")
            f = ""
            for (p = o + 1; p <= NF; ++p) {
                f = String_concat(f, FIX, $p)
            }
if (DEBUG == 4) __debug("QuestionMark: "Index_pull(q, REFIX, " ")" TrueAnswer: "Index_pull(t, REFIX, " ")" FalseAnswer: "Index_pull(f, REFIX, " "))
            x = CDefine_eval(q)
            NF = 1
            if (x) {
                #Index_push(t, REFIX, FIX); n = NF; Index_pop()
                $1 = t
            }
            else {
                #Index_push(f, REFIX, FIX); n = NF; Index_pop()
                $1 = f
            }
            Index_reset()
            i = 0; continue
        }
        # Evaluate defined ( AWA )
        if ($i == "defined") {
            if ($(i + 1) != "(") Index_append(i, "(")
            n = $(i + 2)
            if ($(i + 3) != ")") Index_append(i + 2, ")")
            x = 0; if (n in C_defines) x = 1
            Index_remove(i + 1, i + 2, i + 3)
            if (i > 1 && $(i - 1) == "!") {
                x = !x
                Index_remove(--i)
            }
            $i = x
if (DEBUG == 4) {
if (x) __debug("Defined "n)
else __debug("NotDefined "n)
}
            continue
        }
        # Evaluate AWA ( a , b ) or AWA
        if ($i ~ /^[a-zA-Z_][a-zA-Z_0-9]*$/) {
            name = $i
            if (!(name in C_defines)) {
if (DEBUG == 4) __debug("NotUsing "name)
                $i = "0"
                continue
            }
            n = CDefine_apply(i)
            for (d = i; d <= NF; ++d) {
                if ($d ~ /^\s*$/) Index_remove(d--)
                else if ($d == "\\") Index_remove(d--)
                else if ($d ~ /^\/\*/) Index_remove(d--)
                else if ($d ~ /^L?"/) Index_remove(d--)
            }
if (DEBUG == 4) __debug("Using "name" "Index_pull($0, REFIX, " "))
            --i # i += n - 1
            continue
        }
    }

    Index_reset()
if (DEBUG == 4) __debug("Expression: "Index_pull($0, REFIX, " "))

    for (i = 1; i <= NF; ++i) {
        # Evaluate Logical Boolean ! not
        if ($i == "!") {
            if ($(i + 1) == "!") continue
            if ($(i + 1) !~ /^[-+]?[0-9]+$/) continue

            $i = ! ($(i + 1) + 0)

            Index_remove(i + 1)
            if ($(i - 1) == "!") --i
if (DEBUG == 4) __debug("not: "Index_pull($0, REFIX, " "))
            continue
        }
        # Evaluate Binary, Bitwise NOT ~ Negation: the complement of n
        if ($i == "~") {
            if ($(i + 1) == "~") continue
            if ($(i + 1) !~ /^[-+]?[0-9]+$/) continue
            $i = compl($(i + 1))
            Index_remove(i + 1)
            if ($(i - 1) == "~") --i
if (DEBUG == 4) __debug("NOT: "Index_pull($0, REFIX, " "))
            continue
        }
    }

    for (i = 1; i <= NF; ++i) {
        # Evaluate Multiplikation * Division /
        if ($i == "/") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            if (!$(i + 1)) {
                $i = 0
if (DEBUG == 4) __debug("Division through null: "Index_pull($0, REFIX, " "))
            }
            else {
                $i = $(i - 1) / $(i + 1)
                Index_remove(i - 1, i + 1); --i
if (DEBUG == 4) __debug("Division: "Index_pull($0, REFIX, " "))
            }
        }
        if ($i == "*") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) * $(i + 1)
            Index_remove(i - 1, i + 1); --i
if (DEBUG == 4) __debug("Multiplikation: "Index_pull($0, REFIX, " "))
        }
    }

    for (i = 1; i <= NF; ++i) {
        # Evaluate Subtraktion - Addition +
        if ($i == "-") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            if ((i > 3 && ($(i - 2) == "*" || $(i - 2) == "/")) || ($(i + 2) == "*" || $(i + 2) == "/")) continue
            $i = $(i - 1) - $(i + 1)
            Index_remove(i - 1, i + 1); --i
if (DEBUG == 4) __debug("Subtraktion: "Index_pull($0, REFIX, " "))
        }
        if ($i == "+") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            if ((i > 3 && ($(i - 2) == "*" || $(i - 2) == "/")) || ($(i + 2) == "*" || $(i + 2) == "/")) continue
            $i = $(i - 1) + $(i + 1)
            Index_remove(i - 1, i + 1); --i
if (DEBUG == 4) __debug("Addition: "Index_pull($0, REFIX, " "))
        }
    }

    for (i = 1; i <= NF; ++i) {
        # Evaluate Left Shift << Right Shift >>
        if ($i == "<<") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = lshift($(i - 1), $(i + 1))
            Index_remove(i - 1, i + 1); --i
if (DEBUG == 4) __debug("LeftShift: "Index_pull($0, REFIX, " "))
        }
        if ($i == ">>") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = rshift($(i - 1), $(i + 1))
            Index_remove(i - 1, i + 1); --i
if (DEBUG == 4) __debug("RightShift: "Index_pull($0, REFIX, " "))
        }
    }

    for (i = 1; i <= NF; ++i) {
        # Evaluate Comparison, Boolean Equality == <= < >= > !=
        if ($i == "==") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) == $(i + 1)
            Index_remove(i - 1, i + 1); --i
if (DEBUG == 4) __debug("Equals: "Index_pull($0, REFIX, " "))
        }
        if ($i == "<=") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) <= $(i + 1)
            Index_remove(i - 1, i + 1); --i
if (DEBUG == 4) __debug( "LowerThanEquals: "Index_pull($0, REFIX, " ") )
        }
        if ($i == "<") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) < $(i + 1)
            Index_remove(i - 1, i + 1); --i
if (DEBUG == 4) __debug( "LowerThan: "Index_pull($0, REFIX, " ") )
        }
        if ($i == ">=") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) >= $(i + 1)
            Index_remove(i - 1, i + 1); --i
if (DEBUG == 4) __debug( "GreaterThanEquals: "Index_pull($0, REFIX, " ") )
        }
        if ($i == ">") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) > $(i + 1)
            Index_remove(i - 1, i + 1); --i
if (DEBUG == 4) __debug( "GreaterThan: "Index_pull($0, REFIX, " ") )
        }
        if ($i == "!=") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) != $(i + 1)
            Index_remove(i - 1, i + 1); --i
if (DEBUG == 4) __debug( "NotEquals: "Index_pull($0, REFIX, " ") )
        }
    }
    for (i = 1; i <= NF; ++i) {
        # Evaluate Logical Boolean and && or ||
        if ($i == "&&") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            v = $(i - 1) + 0
            w = $(i + 1) + 0
            x = v && w
            $i = x
            Index_remove(i - 1, i + 1); --i
if (DEBUG == 4) __debug("and: "Index_pull($0, REFIX, " "))
#            if (!x) NF = i
        }
        if ($i == "||") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            v = $(i - 1) + 0
            w = $(i + 1) + 0
            x = v || w
            $i = x
            Index_remove(i - 1, i + 1); --i
if (DEBUG == 4) __debug("or: "Index_pull($0, REFIX, " "))
        }
    }
    r = Index_pop()
#if (DEBUG == 4) __debug("Expression: "r)
    return r
}

