#
# Gemeinfrei. Public Domain.
# 2020 Hans Riehm

function Expression_evaluate(expression, defines,    a, arguments, b, c, d, defineBody,
                             h, i, I, j, k, l, m, n, name, o, p, q, r, s, t, u, v, w, x, y, z)
{
    if (typeof(fixFS) == "untyped") fixFS = FS
    if (typeof(fix) == "untyped") fix = OFS
    if (typeof(defines) == "untyped") defines["length"] = 0

    Index_push(expression, "", "")
    I = Index["length"]

    for (i = 1; i <= NF; ++i) {
        if ($i == "<") {
            if (i > 1) if (Index_prepend(i, " ", " ")) ++i
            if (i < NF && $(i + 1) == "<") ++i
            if (i < NF && $(i + 1) == "=") ++i
            if (i < NF) if (Index_append(i, " ", " ")) ++i
            continue
        }
        if ($i == ">") {
            if (i > 1) if (Index_prepend(i, " ", " ")) ++i
            if (i < NF && $(i + 1) == ">") ++i
            if (i < NF && $(i + 1) == "=") ++i
            if (i < NF) if (Index_append(i, " ", " ")) ++i
            continue
        }
        if ($i == "!" || $i == "=") {
            if (i > 1) if (Index_prepend(i, " ", " ")) ++i
            if (i < NF && $(i + 1) == "=") ++i
            if (i < NF) if (Index_append(i, " ", " ")) ++i
            continue
        }
        if ($i == "|") {
            if (i > 1) if (Index_prepend(i, " ", " ")) ++i
            if (i < NF && $(i + 1) == "|") ++i
            if (i < NF) if (Index_append(i, " ", " ")) ++i
            continue
        }
        if ($i == "&") {
            if (i > 1) if (Index_prepend(i, " ", " ")) ++i
            if (i < NF && $(i + 1) == "&") ++i
            if (i < NF) if (Index_append(i, " ", " ")) ++i
            continue
        }
        if ($i == "+" && $(i + 1) ~ /[0-9]/ && ($(i - 2) == "-" || $(i - 2) == "+" || $(i - 2) == "*" || $(i - 2) == "/")) ++i
        if ($i == "-" && $(i + 1) ~ /[0-9]/ && ($(i - 2) == "-" || $(i - 2) == "+" || $(i - 2) == "*" || $(i - 2) == "/")) ++i
        if ($i == "," || $i == "+" || $i == "-" || $i == "*" || $i == "/" || $i == "~") {
            if (i > 1) if (Index_prepend(i, " ", " ")) ++i
            if (i < NF) if (Index_append(i, " ", " ")) ++i
            continue
        }
        if ($i == "(") {
            if (i > 1) if (Index_prepend(i, " ", " ")) ++i
            ++k
            if (i < NF) if (Index_append(i, " ", " ")) ++i
            continue
        }
        if ($i == ")") {
            if (i > 1) if (Index_prepend(i, " ", " ")) ++i
            --k
            if (i < NF) if (Index_append(i, " ", " ")) ++i
            continue
        }
        if ($i ~ /[0-9]/) {
            if (i > 1 && $(i - 1) != "-") if (Index_prepend(i, " ", " ")) ++i
            for (; ++i <= NF; ) {
                if ($i ~ /[0-9]/) continue
                break
            } --i
            if ($(i + 1) ~ /[uUlL]/) {
                n = i
                for (; ++n <= NF; ) {
                    if ($n ~ /[uUlL]/) continue
                    break
                } --n
                Index_removeRange(i + 1, n)
            }
            if (i < NF) if (Index_append(i, " ", " ")) ++i
            continue
        }
        if ($i ~ /[[:alpha:]_]/) {
            if (i > 1) if (Index_prepend(i, " ", " ")) ++i
            for (; ++i <= NF; ) {
                if ($i ~ /[[:alpha:]_0-9]/) continue
                break
            } --i
            if (i < NF) if (Index_append(i, " ", " ")) ++i
            continue
        }
        if ($i == " ") {
            if (i == 1 || $(i - 1) == " " || i == NF) Index_remove(i--)
            continue
        }
        if ($i == "\\") {
            # Line Continuation
            Index_remove(i--)
            continue
        }
        # remove
__error("Unknown Character \""$i"\"")
        Index_remove(i--)
    }
    expression = Index_pop()
    if (k != 0) __warning("Missing or too many ) (")
    Index_push(expression, " ", " ")
    i = 0
    while (++i) {
        if (i > NF) {
            if ((l = Index["length"]) > I) {
                for (o = 1; o <= NF; ++o)
                    if ($o == "\\") $o = ""
                Index_reset()
                i = Index[l]["i"]
                n = NF
                $i = Index_pop()
#__debug("Define "name" "$i)
                Index_reset()
                i += n - 1
                continue
            }
            break
        }
#        if ($i == ")") {
#            Index_remove(i--)
#            continue
#        }
        if ($i == "(") {
            m = ""
            for (o = i + 1; o <= NF; ++o) {
                if ($o == "(" || $o == "{") ++p
                if ($o == ")" || $o == "}") { if (p) --p; else break }
                m = String_concat(m, " ", $o)
            }
            Index_removeRange(i + 1, o)
            x = Expression_evaluate(m, defines)
            Index_push(x, " ", " ")
            n = NF
            Index_pop()
            if (n > 1) {
                Index_append(i, x" )")
                i += n + 1
                continue
            }
            $i = x
            --i
            continue
        }
        # Evaluate defined ( AWA )
        if ($i == "defined") {
            if ($(i + 1) != "(") Index_append(i, "(")
            n = $(i + 2)
            if ($(i + 3) != ")") Index_append(i + 2, ")")
            if (Array_contains(defines, n)) $i = "1"; else $i = "0"
__debug("Defined "n" "$i)
            Index_remove(i + 1, i + 2, i + 3)
            continue
        }
        # Evaluate AWA ( a , b ) or AWA
        if ($i ~ /^[[:alpha:]_][[:alpha:]_0-9]*$/) {
            name = $i
            if (!Array_contains(defines, name)) {
__debug("NotDefined "name)
                $i = "0"
                continue
            }
            defineBody = defines[name]["body"]
            Array_clear(arguments)
            if (defines[name]["function"]["length"]) {
                if ($(i + 1) != "(") Index_append(i, "(")

                o = i + 1
                for (n = 1; n <= defines[name]["function"]["length"]; ++n) {
                    m = ""
                    p = 0; for ( ; ++o <= NF; ) {
                        if (!p && $o == ",") { --o; break }
                        if ($o == "(" || $o == "{") ++p
                        if ($o == ")" || $o == "}") { if (p) --p; else { --o; break } }
                        m = String_concat(m, " ", $o)
                    }
                    Array_add(arguments, m)
                    ++o
                }

                if ($o != ")") Index_append(o++, ")")
                Index_removeRange(i + 1, o)

                Index_push(defineBody, fixFS, fix)
                for (n = 1; n <= defines[name]["function"]["length"]; ++n) {
                    for (o = 1; o <= NF; ++o)
                        if ($o == defines[name]["function"][n]) $o = arguments[n]
                }
                defineBody = Index_pop()
            }
            if (defineBody == "") {
                # define unsafe  /* unsafe */
__debug("Define "name" without body")
                $i = "0"
                continue
            }
            gsub(fixFS, " ", defineBody)
__debug("Define "name" "defineBody)
            Index_push(defineBody, " ", " ")
            l = Index["length"]
            Index[l]["name"] = name
            Index[l]["i"] = i
            i = 0; continue
        }
    }

    for (i = 1; i <= NF; ++i) {
        # Evaluate Logical Boolean ! not
        if ($i == "!") {
            if ($(i + 1) == "!") continue
            if ($(i + 1) !~ /^[-+]?[0-9]+$/) continue

            $i = ! ($(i + 1) + 0)

            Index_remove(i + 1)
            if ($(i - 1) == "!") --i
__debug("not: "$0)
            continue
        }
        # Evaluate Binary, Bitwise NOT ~ Negation: the complement of n
        if ($i == "~") {
            if ($(i + 1) == "~") continue
            if ($(i + 1) !~ /^[-+]?[0-9]+$/) continue
            $i = compl($(i + 1))
            Index_remove(i + 1)
            if ($(i - 1) == "~") --i
__debug("NOT: "$0)
            continue
        }
    }

    for (i = 1; i <= NF; ++i) {
        # Evaluate Multiplikation * Division /
        if ($i == "/") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            if (!$(i + 1)) {
                $i = 0
__debug("Division through null: "$0)
            }
            else {
                $i = $(i - 1) / $(i + 1)
                Index_remove(i - 1, i + 1); --i
__debug("Division: "$0)
            }
        }
        if ($i == "*") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) * $(i + 1)
            Index_remove(i - 1, i + 1); --i
__debug("Multiplikation: "$0)
        }
    }

    for (i = 1; i <= NF; ++i) {
        # Evaluate Subtraktion - Addition +
        if ($i == "-") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            if ((i > 3 && ($(i - 2) == "*" || $(i - 2) == "/")) || ($(i + 2) == "*" || $(i + 2) == "/")) continue
            $i = $(i - 1) - $(i + 1)
            Index_remove(i - 1, i + 1); --i
__debug("Subtraktion: "$0)
        }
        if ($i == "+") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            if ((i > 3 && ($(i - 2) == "*" || $(i - 2) == "/")) || ($(i + 2) == "*" || $(i + 2) == "/")) continue
            $i = $(i - 1) + $(i + 1)
            Index_remove(i - 1, i + 1); --i
__debug("Addition: "$0)
        }
    }

    for (i = 1; i <= NF; ++i) {
        # Evaluate Left Shift << Right Shift >>
        if ($i == "<<") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = lshift($(i - 1), $(i + 1))
            Index_remove(i - 1, i + 1); --i
__debug("LeftShift: "$0)
        }
        if ($i == ">>") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = rshift($(i - 1), $(i + 1))
            Index_remove(i - 1, i + 1); --i
__debug("RightShift: "$0)
        }
    }

    for (i = 1; i <= NF; ++i) {
        # Evaluate Comparison, Boolean Equality == <= < >= > !=
        if ($i == "==") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) == $(i + 1)
            Index_remove(i - 1, i + 1); --i
__debug("Equals: "$0)
        }
        if ($i == "<=") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) <= $(i + 1)
            Index_remove(i - 1, i + 1); --i
__debug( "LowerThanEquals: "$0 )
        }
        if ($i == "<") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) < $(i + 1)
            Index_remove(i - 1, i + 1); --i
__debug( "LowerThan: "$0 )
        }
        if ($i == ">=") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) >= $(i + 1)
            Index_remove(i - 1, i + 1); --i
__debug( "GreaterThanEquals: "$0 )
        }
        if ($i == ">") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) > $(i + 1)
            Index_remove(i - 1, i + 1); --i
__debug( "GreaterThan: "$0 )
        }
        if ($i == "!=") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) != $(i + 1)
            Index_remove(i - 1, i + 1); --i
__debug( "NotEquals: "$0 )
        }
        # Evaluate Logical Boolean and && or ||
        if ($i == "&&") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) && $(i + 1)
            Index_remove(i - 1, i + 1); --i
__debug("and: "$0)
            if (!$i) NF = i
        }
        if ($i == "||") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) || $(i + 1)
            Index_remove(i - 1, i + 1); --i
__debug("or: "$0)
            if (!$i) NF = i
        }
    }
    return Index_pop()
}

