#
# Gemeinfrei. Public Domain.
# 2020 Hans Riehm

function Expression_evaluate(expression, defines, replaceUndefinedWith,    h, i, j, k, l,
                             m, n, numbers, o, operators, r, v, w, x)
{
    Index_push(expression, "", "")
    # Insert Spaces to "get" the Expression
    for (i = 1; i <= NF; ++i) {

        if ($i == "<") {
            if (i > 1) if (Index_prepend(i, " ", " ")) ++i
            if (i < NF && $(i + 1) == "=") ++i
            if (i < NF) if (Index_append(i, " ", " ")) ++i
            continue
        }
        if ($i == ">") {
            if (i > 1) if (Index_prepend(i, " ", " ")) ++i
            if (i < NF && $(i + 1) == "=") ++i
            if (i < NF) if (Index_append(i, " ", " ")) ++i
            continue
        }
        if ($i == "!") {
            if (i > 1) if (Index_prepend(i, " ", " ")) ++i
            if (i < NF && $(i + 1) == "=") ++i
            if (i < NF) if (Index_append(i, " ", " ")) ++i
            continue
        }
        if ($i == "=") {
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
        if ($i == "-") {
            if (i > 1) if (Index_prepend(i, " ", " ")) ++i
#            if (i < NF && $(i + 1) ~ /[0-9]/) continue
            if (i < NF) if (Index_append(i, " ", " ")) ++i
            continue
        }
        if ($i == "(") { # || $i == ")") {
            if (i > 1) if (Index_prepend(i, " ", " ")) ++i

            m = ""; o = 0
            for (n = i + 1; n <= NF; ++n) {
                if ($n == "(")  ++o
                if ($n == ")") { if (o) --o; else { $n = ""; break } }
                m = m $n
                $n = ""
            }
            Index_reset()
            m = String_trim(m)
            if (m ~ /^[[:alpha:]_][[:alpha:]_0-9]*$/ || m ~ /^[0-9]+$/) {
                $i = m; --i; Index_reset()
                continue
            }
            x = Expression_evaluate(m, defines)
            Index_push(x, " ", " ")
            y = NF > 1
            Index_pop()
            Index_push(x, "", "")
            if (y) {
                Index_prepend(1, "(")
                Index_append(NF, ")")
            }
            y = NF
            $i = Index_pop()
            i += y - 1
            continue
        }
        if ($i == "+" || $i == "*" || $i == "/") {
            if (i > 1) if (Index_prepend(i, " ", " ")) ++i
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

        # remove
        Index_remove(i--)
    }
    expression = Index_pop()
    Index_push(expression, " ", " ")

    # Evaluate defined AWA
    for (i = 1; i <= NF; ++i) {
        if ($i == "defined") {
            n = $(i + 1)
            if (defines["length"] && Array_contains(defines, n))
                 $i = "1"
            else $i = "0"
            Index_remove(i + 1)
#__error("Defined "n" : "$i)
            continue
        }

#        if ($i ~ /^[[:alpha:]_][[:alpha:]_0-9]*$/) {
#            n = $i
#            if (defines["length"] && (d = Array_contains(defines, n))) {
#                $i = defines[n]["body"]
##__error("Define "n" : "defines[n]["body"])
#                --i; Index_reset()
#                continue
#            }
#            if (typeof(replaceUndefinedWith) != "untyped") {
#                $i = replaceUndefinedWith
#            }
#        }

    }

    # Evaluate Division / Multiplikation *
    for (i = 1; i <= NF; ++i) {
        if ($(i - 1) ~ /^[0-9]+$/ && $(i + 1) ~ /^[0-9]+$/) {
            if ($i == "/") {
                $i = $(i - 1) / $(i + 1)
                Index_remove(i - 1, i + 1); --i
#__error("Division: "$0)
            }
            if ($i == "*") {
                $i = $(i - 1) * $(i + 1)
                Index_remove(i - 1, i + 1); --i
#__error("Multiplikation: "$0)
            }
        }
    }
    # Evaluate Subtraktion - Addition +
    for (i = 1; i <= NF; ++i) {
        if ($(i - 1) ~ /^[0-9]+$/ && $(i + 1) ~ /^[0-9]+$/) {
            if ((i < 3 || ($(i - 2) != "*" && $(i - 2) != "/")) && $(i + 2) != "*" && $(i + 2) != "/") {
                if ($i == "-") {
                    $i = $(i - 1) - $(i + 1)
                    Index_remove(i - 1, i + 1); --i
#__error("Subtraktion: "$0)
                }
                if ($i == "+") {
                    $i = $(i - 1) + $(i + 1)
                    Index_remove(i - 1, i + 1); --i
#__error("Addition: "$0)
                }
            }
        }
    }

    # Evaluate Boolean !
    for (i = 1; i <= NF; ++i) {
        if ($i == "!") {
            if ($(i + 1) == "!") continue
            if ($(i + 1) ~ /^[0-9]+$/) {
                $i = ! $(i + 1)
                Index_remove(i + 1); --i
                if ($i == "!") --i
#__error("Not: "$0)
                continue
            }
        }
    }

    for (i = 1; i <= NF; ++i) {
        if ($(i - 1) ~ /^[0-9]+$/ && $(i + 1) ~ /^[0-9]+$/) {
            if ($i == ">") {
                $i = $(i - 1) > $(i + 1)
                Index_remove(i - 1, i + 1); --i
#__error( "GreaterThan: "$0 )
            }
            if ($i == "<") {
                $i = $(i - 1) < $(i + 1)
                Index_remove(i - 1, i + 1); --i
#__error( "LowerThan: "$0 )
            }
        }
    }

    # Evaluate Boolean && ||
    for (i = 1; i <= NF; ++i) {
        if ($(i - 1) ~ /^[0-9]+$/ && $(i + 1) ~ /^[0-9]+$/) {
            if ($i == "&&") {
                $i = $(i - 1) && $(i + 1)
                Index_remove(i - 1, i + 1); --i
#__error("And: "$0)
            }
            if ($i == "||") {
                $i = $(i - 1) || $(i + 1)
                Index_remove(i - 1, i + 1); --i
#__error("Or: "$0)
            }
        }
    }

    # Evaluate Boolean Equals == <= >= !=
    for (i = 1; i <= NF; ++i) {
        if ($(i - 1) ~ /^[0-9]+$/ && $(i + 1) ~ /^[0-9]+$/) {
            if ($i == "==") {
                $i = $(i - 1) == $(i + 1)
                Index_remove(i - 1, i + 1); --i
#__error("Equals: "$0)
            }
            if ($i == ">=") {
                $i = $(i - 1) >= $(i + 1)
                Index_remove(i - 1, i + 1); --i
#__error( "GreaterThanEquals: "$0 )
            }
            if ($i == "<=") {
                $i = $(i - 1) <= $(i + 1)
                Index_remove(i - 1, i + 1); --i
#__error( "LowerThanEquals: "$0 )
            }
            if ($i == "!=") {
                $i = $(i - 1) != $(i + 1)
                Index_remove(i - 1, i + 1); --i
#__error( "NotEquals: "$0 )
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
