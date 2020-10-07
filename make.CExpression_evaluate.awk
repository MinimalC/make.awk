#
# Gemeinfrei. Public Domain.
# 2020 Hans Riehm

#include "../make.awk/meta.awk"
#include "../make.awk/make.C.awk"

function CDefine_apply(i,    file,    a, arguments, b, c, code, d, defineBody, e, f, g, h, inputType, j, k, l, m,
                                         n, name, notapplied, o, p, q, r, rendered, s, t, u, v, w, x, y, z)
{
    if (!($i in defines)) return 1

    # Evaluate AWA
    name = $i
    # define AWA AWA
    if (noredefines[name]) {
        __warning(file["name"]" Line "file["z"]": self-referencing define "name" "name)
        return 1
    }
    delete noredefines[name]
    # define name ( arg1 , arg2 ) body
    defineBody = defines[name]["body"]
    Array_clear(arguments)
    if (defines[name]["isFunction"]) {
        l = defines[name]["arguments"]["length"]
        o = i; m = ""; p = 0
        while (++o) {
            if (o > NF) {
                if (typeof(file["I"]) == "number" && file["I"] == Index["length"] && ++file["z"] <= file["length"]) {
                    $0 = $0 fix file[file["z"]]
                    # Index_reset()
                    for (j = o; j <= NF; ++j) if ($j ~ /^[ \f\t\v]+$/) Index_remove(j--)
                    defines["__LINE__"]["body"] = file["z"]
                    --o; continue
                }
                break
            }
            if (o == i + 1) {
                if ($o != "(") break
                continue
            }
            if (!p && $o == ",") {
                Array_add(arguments, m)
                m = ""
                continue
            }
            if ($o == "(" || $o == "{") ++p
            if ($o == ")" || $o == "}") {
                if (p) --p
                else { if (l) Array_add(arguments, m); break }
            }
            m = String_concat(m, fix, $o)
        }
        if ($(i + 1) != "(") {
if (DEBUG == 3) __debug(file["name"]" Line "file["z"]": not using "name)
            return 1
        }
        Index_removeRange(i + 1, o)
if (DEBUG == 3) {
__debug("arguments: "defines[name]["arguments"]["text"])
Array_debug(arguments)
}
        if (defines[name]["arguments"][l] != "..." ? arguments["length"] < l : arguments["length"] < l - 1)
            __error(file["name"]" Line "file["z"]": using "name": Not enough arguments") # ("arguments["length"]" insteadof "l") "m)
        else if (arguments["length"] > l && defines[name]["arguments"][l] != "...")
            __error(file["name"]" Line "file["z"]": using "name": Too many arguments")
        for (n = 1; n <= arguments["length"]; ++n) {
            Index_push(arguments[n], fixFS, fix)
            for (j = 1; j <= NF; ++j) {
                if ($j in defines) {
                    if (defines[$j]["isFunction"] && $(j + 1) != "(") {
if (DEBUG == 3) __debug(file["name"]" Line "file["z"]": 2 not applying "$j)
                        continue
                    }
if (DEBUG == 3) __debug(file["name"]" Line "file["z"]": 2 applying "$j)
                    m = CDefine_apply(j, file)
                    j += m - 1
                }
            }
            arguments[n] = Index_pop()
        }
        Index_push(defineBody, fixFS, fix)
        for (n = 1; n <= l; ++n) {
            if (n == l && defines[name]["arguments"][l] == "...") break
            for (o = 1; o <= NF; ++o) {
                if ($o == defines[name]["arguments"][n]) {
                    $o = arguments[n]
                    if (o > 1 && $(o - 1) == "#") {
                        gsub(fixFS, " ", $o)
                        $o = "\""$o"\""
                        Index_remove(--o)
                    }
                }
            }
        }
        if (defines[name]["arguments"][l] == "...") {
            for (o = 1; o <= NF; ++o) {
                if ($o == "__VA_ARGS__") {
                    $o = ""
                    for (n = l; n <= arguments["length"]; ++n)
                        $o = String_concat($o, fix","fix, arguments[n])
                    n = 1
                    if (o > 1 && $(o - n) == "##") {
                        $(o - n) = ""; ++n; __warning(file["name"]" Line "file["z"]": Concatenating Variable Arguments")
                    }
                    if (o > 1 && $(o - n) == "#") {
                        gsub(fixFS, " ", $o)
                        $o = "\""$o"\""
                        $(o - n) = ""; ++n
                    }
                    if (!$o && o > 1 && $(o - n) == ",") $(o - n) = ""
                }
            }
        }
        Index_reset()
        defineBody = Index_pop()
    }
    Index_push(defineBody, fixFS, fix)
    for (o = 1; o <= NF; ++o) {
        if ($o == "\\") { Index_remove(o--); continue }
        if ($o == "##") {
            $o = $(o - 1) $(o + 1)
            Index_remove(o - 1, o + 1)
            --o; continue
        }
        if ($o == "#") {
            if ($(o + 1) !~ /^[[:alpha:]_][[:alpha:]_0-9]*$/) {
                $o = "\"\""
            }
            else {
                gsub(fixFS, " ", $(o + 1))
                $(o + 1) = "\""$(o + 1)"\""
                Index_remove(o)
            }
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
    Index_push(defineBody, fixFS, fix)
    ++noredefines[name]
    notapplied = 0
    for (j = 1; j <= NF; ++j) {
        if ($j in defines) {
            if (defines[$j]["isFunction"] && $(j + 1) != "(") {
if (DEBUG == 3) __debug(file["name"]" Line "file["z"]": 1 not applying "$j)
                ++notapplied
                continue
            }
if (DEBUG == 3) __debug(file["name"]" Line "file["z"]": 1 applying "$j)
            n = CDefine_apply(j, file)
            j += n-1
        }
    }
    --noredefines[name]
    Index_reset()
    n = NF
    $i = defineBody = Index_pop()
    Index_reset()

if (DEBUG == 3) {
Index_push(defineBody, "", ""); for (m = 1; m <= NF; ++m) if ($m == fix) $m = " "; rendered = Index_pop()
if (defines[name]["isFunction"]) {
__debug(file["name"]" Line "file["z"]": using "name" ("defines[name]["arguments"]["text"]")  "rendered)
# Array_debug(arguments)
} else __debug(file["name"]" Line "file["z"]": using "name"  "rendered)
}
    return n - notapplied
}

function CExpression_evaluate(expression,    a, arguments, b, c, d, defineBody, e, f, g,
                             h, i, j, k, l, m, n, name, number, o, p, q, r, s, t, u, v, w, x, y, z)
{
    Index_push(expression, fixFS, fix)
    Index_reset()
    for (i = 1; i <= NF; ++i) {
        if ($i ~ /^[ \f\t\v]+$/) { Index_remove(i--); continue }
        if ($i ~ /^\/\*/) { Index_remove(i--); continue }
        if ($i == "\\") { Index_remove(i--); continue }
        if ($i ~ /^0x/) {
            $i = strtonum($i)
        }
        if ($i ~ /^L/) {
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
                m = String_concat(m, fix, $o)
            }
            Index_removeRange(i + 1, o)
            x = CExpression_evaluate(m)
            # Index_push(x, fixFS, fix); n = NF; Index_pop()
            $i = x
            --i # i += n - 1
            continue
        }
        if ($i == "?") {
            q = ""
            for (n = 1; n < i; ++n) {
                q = String_concat(q, fix, $n)
            }
            t = ""
            p = 0; for (o = i + 1; o <= NF; ++o) {
                if (!p && $o == ":") break
                if ($o == "(" || $o == "{") ++p
                if ($o == ")" || $o == "}") { if (p) --p }
                t = String_concat(t, fix, $o)
            }
            if ($o != ":") __error("QuestionMark isn't followed by :")
            f = ""
            for (p = o + 1; p <= NF; ++p) {
                f = String_concat(f, fix, $p)
            }
if (DEBUG == 5) __debug("QuestionMark: "q" TrueAnswer: "t" FalseAnswer: "f)
            x = CExpression_evaluate(q)
            NF = 1
            if (x) {
                #Index_push(t, fixFS, fix); n = NF; Index_pop()
                $1 = t
            }
            else {
                #Index_push(f, fixFS, fix); n = NF; Index_pop()
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
            if (n in defines) $i = "1"; else $i = "0"
if (DEBUG == 5) {
if ($i != "0") __debug("Defined "n)
else __debug("NotDefined "n)
}
            Index_remove(i + 1, i + 2, i + 3)
            continue
        }
        # Evaluate AWA ( a , b ) or AWA
        if ($i ~ /^[[:alpha:]_][[:alpha:]_0-9]*$/) {
            name = $i
            if (!(name in defines)) {
if (DEBUG == 5) __debug("NotUsing "name)
                $i = "0"
                continue
            }
            n = CDefine_apply(i)
if (DEBUG == 5) __debug("Using "name" "$0)
            --i # i += n - 1
            continue
        }
    }

    Index_reset()
if (DEBUG == 5) __debug("Expression: "$0)

    for (i = 1; i <= NF; ++i) {
        # Evaluate Logical Boolean ! not
        if ($i == "!") {
            if ($(i + 1) == "!") continue
            if ($(i + 1) !~ /^[-+]?[0-9]+$/) continue

            $i = ! ($(i + 1) + 0)

            Index_remove(i + 1)
            if ($(i - 1) == "!") --i
if (DEBUG == 5) __debug("not: "$0)
            continue
        }
        # Evaluate Binary, Bitwise NOT ~ Negation: the complement of n
        if ($i == "~") {
            if ($(i + 1) == "~") continue
            if ($(i + 1) !~ /^[-+]?[0-9]+$/) continue
            $i = compl($(i + 1))
            Index_remove(i + 1)
            if ($(i - 1) == "~") --i
if (DEBUG == 5) __debug("NOT: "$0)
            continue
        }
    }

    for (i = 1; i <= NF; ++i) {
        # Evaluate Multiplikation * Division /
        if ($i == "/") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            if (!$(i + 1)) {
                $i = 0
if (DEBUG == 5) __debug("Division through null: "$0)
            }
            else {
                $i = $(i - 1) / $(i + 1)
                Index_remove(i - 1, i + 1); --i
if (DEBUG == 5) __debug("Division: "$0)
            }
        }
        if ($i == "*") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) * $(i + 1)
            Index_remove(i - 1, i + 1); --i
if (DEBUG == 5) __debug("Multiplikation: "$0)
        }
    }

    for (i = 1; i <= NF; ++i) {
        # Evaluate Subtraktion - Addition +
        if ($i == "-") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            if ((i > 3 && ($(i - 2) == "*" || $(i - 2) == "/")) || ($(i + 2) == "*" || $(i + 2) == "/")) continue
            $i = $(i - 1) - $(i + 1)
            Index_remove(i - 1, i + 1); --i
if (DEBUG == 5) __debug("Subtraktion: "$0)
        }
        if ($i == "+") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            if ((i > 3 && ($(i - 2) == "*" || $(i - 2) == "/")) || ($(i + 2) == "*" || $(i + 2) == "/")) continue
            $i = $(i - 1) + $(i + 1)
            Index_remove(i - 1, i + 1); --i
if (DEBUG == 5) __debug("Addition: "$0)
        }
    }

    for (i = 1; i <= NF; ++i) {
        # Evaluate Left Shift << Right Shift >>
        if ($i == "<<") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = lshift($(i - 1), $(i + 1))
            Index_remove(i - 1, i + 1); --i
if (DEBUG == 5) __debug("LeftShift: "$0)
        }
        if ($i == ">>") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = rshift($(i - 1), $(i + 1))
            Index_remove(i - 1, i + 1); --i
if (DEBUG == 5) __debug("RightShift: "$0)
        }
    }

    for (i = 1; i <= NF; ++i) {
        # Evaluate Comparison, Boolean Equality == <= < >= > !=
        if ($i == "==") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) == $(i + 1)
            Index_remove(i - 1, i + 1); --i
if (DEBUG == 5) __debug("Equals: "$0)
        }
        if ($i == "<=") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) <= $(i + 1)
            Index_remove(i - 1, i + 1); --i
if (DEBUG == 5) __debug( "LowerThanEquals: "$0 )
        }
        if ($i == "<") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) < $(i + 1)
            Index_remove(i - 1, i + 1); --i
if (DEBUG == 5) __debug( "LowerThan: "$0 )
        }
        if ($i == ">=") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) >= $(i + 1)
            Index_remove(i - 1, i + 1); --i
if (DEBUG == 5) __debug( "GreaterThanEquals: "$0 )
        }
        if ($i == ">") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) > $(i + 1)
            Index_remove(i - 1, i + 1); --i
if (DEBUG == 5) __debug( "GreaterThan: "$0 )
        }
        if ($i == "!=") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) != $(i + 1)
            Index_remove(i - 1, i + 1); --i
if (DEBUG == 5) __debug( "NotEquals: "$0 )
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
if (DEBUG == 5) __debug("and: "$0)
            if (!x) NF = i
        }
        if ($i == "||") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            v = $(i - 1) + 0
            w = $(i + 1) + 0
            x = v || w
            $i = x
            Index_remove(i - 1, i + 1); --i
if (DEBUG == 5) __debug("or: "$0)
        }
    }
    r = Index_pop()
#if (DEBUG == 5) __debug("Expression: "r)
    return r
}

