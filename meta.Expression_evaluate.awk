#
# Gemeinfrei. Public Domain.
# 2020 Hans Riehm

function Expression_evaluate(expression, defines, replaceUndefinedWith,    a, arguments, b, c, d, defineBody,
                             h, i, I, j, k, l, m, n, name, o, p, q, r, s, t, u, v, w, x, y, z)
{
    if (typeof(fixFS) == "untyped") fixFS = FS
    if (typeof(fix) == "untyped") fix = OFS
    if (typeof(defines) == "untyped") defines["length"] = 0

    Index_push(expression, "", "")
    I = Index["length"]

    i = 0
    # for (i = 1; i <= NF; ++i)
    while (++i) {
        if (i > NF) {
            if ((l = Index["length"]) > I) {
                for (o = 1; o <= NF; ++o)
                    if ($o == "\\") $o = ""
                Index_reset()
                i = Index[l]["i"]
                # n = NF
                $i = Index_pop()
                Index_reset()
                --i # i += n
                continue
            }
            break
        }
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
        if ($i == "+" && $(i + 1) ~ /[0-9]/) ++i
        if ($i == "-" && $(i + 1) ~ /[0-9]/) ++i
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
__debug("Unknown Character: "$i)
        Index_remove(i--)
    }
    expression = Index_pop()
    if (k != 0) __warning("Missing or too many ) (")
    Index_push(expression, " ", " ")

    # Evaluate defined(AWA), AWA(a,b) or just AWA
    for (i = 1; i <= NF; ++i) {
        if ($i == "defined") {
            if ($(i + 1) != "(") Index_append(i, "(")
            n = $(i + 2)
            if ($(i + 3) != ")") Index_append(i + 2, ")")
            if (Array_contains(defines, n)) $i = "1"; else $i = "0"
            Index_remove(i + 1, i + 2, i + 3)
__debug("Defined "n" : "$i)
            continue
        }
        if ($i ~ /^[[:alpha:]_][[:alpha:]_0-9]*$/) {
            name = $i
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
                        m = String_concat(m, fix, $o)
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
                #if (typeof(replaceUndefinedWith) != "untyped")
                #    $i = replaceUndefinedWith
                Index_remove(i--)
                continue
            }
            Index_push(defineBody, fixFS, fix)
            l = Index["length"]
            Index[l]["name"] = name
            Index[l]["i"] = i
            i = 0; continue
        }
    }
    # Evaluate Boolean ! Logical NOT ~ Negation: the complement of n
    for (i = 1; i <= NF; ++i) {
        if ($i == "!") {
            if ($(i + 1) == "!") continue
            if ($(i + 1) ~ /^[-+]?[0-9]+$/) {
                $i = ! $(i + 1)
                Index_remove(i + 1); --i
                if ($i == "!") --i
__debug("Not: "$0)
                continue
            }
        }
        if ($i == "~") {
            if ($(i + 1) == "~") continue
            if ($(i + 1) ~ /^[-+]?[0-9]+$/) {
                $i = compl($(i + 1))
                Index_remove(i + 1); --i
                if ($i == "~") --i
__debug("NOT: "$0)
                continue
            }
        }
    }
    # Evaluate Multiplikation * Division / Modulo %  # triple operator 1 / 3 % remainder
    for (i = 1; i <= NF; ++i) {
        if ($(i - 1) ~ /^[-+]?[0-9]+$/ && $(i + 1) ~ /^[-+]?[0-9]+$/) {
            if ($i == "/") {
                $i = $(i - 1) / $(i + 1)
                Index_remove(i - 1, i + 1); --i
__debug("Division: "$0)
            }
            if ($i == "*") {
                $i = $(i - 1) * $(i + 1)
                Index_remove(i - 1, i + 1); --i
__debug("Multiplikation: "$0)
            }
        }
    }
    # Evaluate Subtraktion - Addition +
    for (i = 1; i <= NF; ++i) {
        if ($(i - 1) ~ /^[-+]?[0-9]+$/ && $(i + 1) ~ /^[-+]?[0-9]+$/) {
            if ((i < 3 || ($(i - 2) != "*" && $(i - 2) != "/")) && $(i + 2) != "*" && $(i + 2) != "/") {
                if ($i == "-") {
                    $i = $(i - 1) - $(i + 1)
                    Index_remove(i - 1, i + 1); --i
__debug("Subtraktion: "$0)
                }
                if ($i == "+") {
                    $i = $(i - 1) + $(i + 1)
                    Index_remove(i - 1, i + 1); --i
__debug("Addition: "$0)
                }
            }
        }
    }

    # Evaluate Left Shift << Right Shift >>
    for (i = 1; i <= NF; ++i) {
        if ($(i - 1) ~ /^[-+]?[0-9]+$/ && $(i + 1) ~ /^[-+]?[0-9]+$/) {
            if ($i == "<<") {
                $i = lshift($(i - 1), $(i + 1))
                Index_remove(i - 1, i + 1); --i
__debug("And: "$0)
            }
            if ($i == ">>") {
                $i = rshift($(i - 1), $(i + 1))
                Index_remove(i - 1, i + 1); --i
__debug("Or: "$0)
            }
        }
    }

    # Evaluate Comparison, Boolean Equality == <= < >= > !=
    for (i = 1; i <= NF; ++i) {
        if ($(i - 1) ~ /^[-+]?[0-9]+$/ && $(i + 1) ~ /^[-+]?[0-9]+$/) {
            if ($i == "==") {
                $i = $(i - 1) == $(i + 1)
                Index_remove(i - 1, i + 1); --i
__debug("Equals: "$0)
            }
            if ($i == "<=") {
                $i = $(i - 1) <= $(i + 1)
                Index_remove(i - 1, i + 1); --i
__debug( "LowerThanEquals: "$0 )
            }
            if ($i == "<") {
                $i = $(i - 1) < $(i + 1)
                Index_remove(i - 1, i + 1); --i
__debug( "LowerThan: "$0 )
            }
            if ($i == ">=") {
                $i = $(i - 1) >= $(i + 1)
                Index_remove(i - 1, i + 1); --i
__debug( "GreaterThanEquals: "$0 )
            }
            if ($i == ">") {
                $i = $(i - 1) > $(i + 1)
                Index_remove(i - 1, i + 1); --i
__debug( "GreaterThan: "$0 )
            }
            if ($i == "!=") {
                $i = $(i - 1) != $(i + 1)
                Index_remove(i - 1, i + 1); --i
__debug( "NotEquals: "$0 )
            }
        }
    }
    # Evaluate Boolean AND && OR ||
    for (i = 1; i <= NF; ++i) {
        if ($(i - 1) ~ /^[-+]?[0-9]+$/ && $(i + 1) ~ /^[-+]?[0-9]+$/) {
            if ($i == "&&") {
                $i = $(i - 1) && $(i + 1)
                Index_remove(i - 1, i + 1); --i
__debug("AND: "$0)
            }
            if ($i == "||") {
                $i = $(i - 1) || $(i + 1)
                Index_remove(i - 1, i + 1); --i
__debug("OR: "$0)
                break
            }
        }
    }
    return Index_pop()
}


# DEPRECATED

function __Expression_evaluate(expression, defines,    a, b, c, d, e, f, g, h, i, j, k, l, m, n, r) {
    gsub(/\(/, " ( ", expression)
    gsub(/\)/, " ) ", expression)
    gsub(/\+/, " + ", expression)
    gsub(/\-[^0-9]/, " - ", expression)
    gsub(/\*/, " * ", expression)
    gsub(/\//, " / ", expression)
    gsub(/&&/, " && ", expression)
    gsub(/\|\|/, " || ", expression)
    gsub(/==/, " == ", expression)
    gsub(/!=/, " != ", expression)
    gsub(/![^=]/, " ! ", expression)
    gsub(/>[^=]/, " > ", expression)
    gsub(/>=/, " >= ", expression)
    gsub(/<[^=]/, " < ", expression)
    gsub(/<=/, " <= ", expression)
    expression = String_trim(expression)
    Index_push(expression, @/[ ]+/, " ")
print NF": \""($0 = $0)"\""
    for (i = 1; i <= NF; ++i) {
        if ($i == "" && i < NF - 1) {
            for (n = i + 1; n <= NF; ++n) {
                $(n - 1) = $n
            }
            $NF = ""
print "moving"
            --i; Index_reset(); continue
        }
#print
        if ($i ~ /^[a-zA-Z_][a-zA-Z_0-9]*$/ && typeof(defines) == "array" && (d = Array_contains(defines, $i))) {
            $i = defines[$i]["body"]
            --i; Index_reset(); continue
        }
        if ($i == "(") {
            m = ""; h = 0
            for (j = i + 1; j <= NF; ++j) {
                if ($j == "(") ++h
                if ($j == ")") { if (h) --h; else { $j = ""; break } }
                m = String_concat(m, " ", $j)
                $j = ""
            }
            if (j > NF) ;
            $i = __Expression_evaluate(m, defines)
            --i; Index_reset(); continue
        }
        if ($i ~ /^[\-0-9]+$/) {
            if (i > 1) {
                if ($(i - 1) == "!") {
                    $(i - 1) = ! $i; $i = ""; i -= 2; Index_reset()
                    continue
                }
            }
            if (i > 2) {
                if ($(i - 1) == "+") {
                    if ($(i - 2) ~ /^[\-0-9]+$/) {
                        $(i - 2) = $(i - 2) + $i; $(i - 1) = ""; $i = ""; i -= 3; Index_reset()
                    }
                    continue
                }
                if ($(i - 1) == "-") {
                    if ($(i - 2) ~ /^[\-0-9]+$/) {
                        $(i - 2) = $(i - 2) - $i; $(i - 1) = ""; $i = ""; i -= 3; Index_reset()
                    }
                    continue
                }
                if ($(i - 1) == "*") {
                    if ($(i - 2) ~ /^[\-0-9]+$/) {
                        $(i - 2) = $(i - 2) * $i; $(i - 1) = ""; $i = ""; i -= 3; Index_reset()
                    }
                    continue
                }
                if ($(i - 1) == "/") {
                    if ($(i - 2) ~ /^[\-0-9]+$/) {
                        $(i - 2) = $(i - 2) / $i; $(i - 1) = ""; $i = ""; i -= 3; Index_reset()
                    }
                    continue
                }
                if ($(i - 1) == "&&") {
                    if ($(i - 2) ~ /^[\-0-9]+$/) {
                        $(i - 2) = $(i - 2) && $i; $(i - 1) = ""; $i = ""; i -= 3; Index_reset()
                    }
                    continue
                }
                if ($(i - 1) == "||") {
                    if ($(i - 2) ~ /^[\-0-9]+$/) {
                        $(i - 2) = $(i - 2) || $i; $(i - 1) = ""; $i = ""; i -= 3; Index_reset()
                    }
                    continue
                }
                if ($(i - 1) == "==") {
                    if ($(i - 2) ~ /^[\-0-9]+$/) {
                        $(i - 2) = $(i - 2) == $i; $(i - 1) = ""; $i = ""; i -= 3; Index_reset()
                    }
                    continue
                }
                if ($(i - 1) == "!=") {
                    if ($(i - 2) ~ /^[\-0-9]+$/) {
                        $(i - 2) = $(i - 2) != $i; $(i - 1) = ""; $i = ""; i -= 3; Index_reset()
                    }
                    continue
                }
                if ($(i - 1) == ">") {
                    if ($(i - 2) ~ /^[\-0-9]+$/) {
                        $(i - 2) = $(i - 2) > $i; $(i - 1) = ""; $i = ""; i -= 3; Index_reset()
                    }
                    continue
                }
                if ($(i - 1) == ">=") {
                    if ($(i - 2) ~ /^[\-0-9]+$/) {
                        $(i - 2) = $(i - 2) >= $i; $(i - 1) = ""; $i = ""; i -= 3; Index_reset()
                    }
                    continue
                }
                if ($(i - 1) == "<") {
                    if ($(i - 2) ~ /^[\-0-9]+$/) {
                        $(i - 2) = $(i - 2) < $i; $(i - 1) = ""; $i = ""; i -= 3; Index_reset()
                    }
                    continue
                }
                if ($(i - 1) == "<=") {
                    if ($(i - 2) ~ /^[\-0-9]+$/) {
                        $(i - 2) = $(i - 2) <= $i; $(i - 1) = ""; $i = ""; i -= 3; Index_reset()
                    }
                    continue
                }
            }
        }
        if ($i == "defined") {
            j = i + 1
            if ($j == "(") { $j = ""; ++j }
            if (Array_contains(defines, $j)) {
                if (i > 1 && $(i - 1) == "!") { $i = ""; --i; $i = 0 }
                else { $i = 1 }
            } else {
                if (i > 1 && $(i - 1) == "!") { $i = ""; --i; $i = 1 }
                else { $i = 0 }
            }
            $j = ""; ++j
            if ($j == ")") { $j = ""; ++j }
            Index_reset()
            continue
        }
    }

    r = String_trim(Index_pop())
    return r
}
