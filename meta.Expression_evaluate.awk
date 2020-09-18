#
# Gemeinfrei. Public Domain.
# 2020 Hans Riehm


function Define_apply(i, noredefines,    a, arguments, b, c, d, defineBody, defineBody1, f, g, h, inputType, j, k, l, m,
                                         n, name, notapplied, o, p, q, r, rendered_defineBody, s, t, u, v, w, x, y) # e, z
{
    # Evaluate AWA
    if (Array_contains(defines, $i)) {
        name = $i
        # define AWA AWA
        if (noredefines[name]) {
            __error(input[e]["FILENAME"]" Line "z": self-referencing define "name" "name)
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
                    if (I && Index["length"] == I && ++z <= input[e]["length"]) {
                        $0 = $0 fix input[e][z]
                        defines["__LINE__"]["body"] = z
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
if (DEBUG == 3) __debug(input[e]["FILENAME"]" Line "z": not using "name)
                return 1
            }
            Index_removeRange(i + 1, o)
            if (arguments["length"] < l) __error(input[e]["FILENAME"]" Line "z": using "name": Not enough arguments used")
            else if (arguments["length"] > l && defines[name]["arguments"][l] != "...")
                __error(input[e]["FILENAME"]" Line "z": using "name": Too many arguments used")
#Array_debug(arguments)
            for (n = 1; n <= arguments["length"]; ++n) {
                Index_push(arguments[n], fixFS, fix)
                for (j = 1; j <= NF; ++j) {
                    if (Array_contains(defines, $j)) {
                        if (defines[$j]["isFunction"] && $(j + 1) != "(") {
if (DEBUG == 3) __debug(input[e]["FILENAME"]" Line "z": 2 not applying "$j)
                            continue
                        }
if (DEBUG == 3) __debug(input[e]["FILENAME"]" Line "z": 2 applying "$j)
                        m = Define_apply(j, noredefines)
                        j += m - 1
                    }
                }
                arguments[n] = Index_pop()
            }
            Index_push(defineBody, fixFS, fix)
            for (n = 1; n <= l; ++n) {
                if (n == l && defines[name]["arguments"][l] == "...") break
                for (o = 1; o <= NF; ++o) {
                    if ($o == defines[name]["arguments"][n]) $o = arguments[n]
                    if (o > 1 && $(o - 1) == "#") { $o = "\""$o"\""; $(o - 1) = "" }
                }
            }
            if (defines[name]["arguments"][l] == "...") {
                for (o = 1; o <= NF; ++o) {
                    if ($o == "__VA_ARGS__") {
                        $o = ""
                        for (n = l; n <= arguments["length"]; ++n)
                            $o = String_concat($o, fix","fix, arguments[n])
                        if (o > 1 && $(o - 1) == "#") { $o = "\""$o"\""; $(o - 1) = "" }
                    }
                }
                Index_reset()
            }
            defineBody = Index_pop()
        }
        Index_push(defineBody, fixFS, fix)
        for (o = 1; o <= NF; ++o) {
            if (inputType == "comment") {
                if ($o ~ /\*\/$/) inputType = ""
                Index_remove(o--)
                continue
            }
            if ($o ~ /^\/\*/) {
                inputType = "comment"
                if ($o ~ /\*\/$/) inputType = ""
                Index_remove(o--)
                continue
            }
            if ($o ~ /^\/\//) {
                NF = o - 1; break
            }
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
                    $(o + 1) = "\""$(o + 1)"\""
                    Index_remove(o)
                }
                continue
            }
        }
        defineBody = Index_pop()
        if (defineBody == "") {
            # define unsafe  /* unsafe */
if (DEBUG == 3) __debug(input[e]["FILENAME"]" Line "z": using "name" without body")
            Index_remove(i)
            return 0
        }
        Index_push(defineBody, fixFS, fix)
        ++noredefines[name]
        notapplied = 0
        for (j = 1; j <= NF; ++j) {
            if (Array_contains(defines, $j)) {
                if (defines[$j]["isFunction"] && $(j + 1) != "(") {
if (DEBUG == 3) __debug(input[e]["FILENAME"]" Line "z": 1 not applying "$j)
                    ++notapplied
                    continue
                }
if (DEBUG == 3) __debug(input[e]["FILENAME"]" Line "z": 1 applying "$j)
                n = Define_apply(j, noredefines)
                j += n-1
            }
        }
        --noredefines[name]
        Index_reset()
        n = NF
        $i = defineBody = Index_pop()
        Index_reset()

if (DEBUG == 3) {
Index_push(defineBody, "", ""); for (m = 1; m <= NF; ++m) if ($m == fix) $m = " "; rendered_defineBody = Index_pop()
if (defines[name]["isFunction"]) {
__debug(input[e]["FILENAME"]" Line "z": using "name" ("defines[name]["arguments"]["text"]")  "rendered_defineBody)
# Array_debug(arguments)
} else __debug(input[e]["FILENAME"]" Line "z": using "name"  "rendered_defineBody)
}
        return n - notapplied
    }
    return 1
}

function Exxpression_evaluate(expression,    a, b, c, d) {
    if (typeof(fixFS) == "untyped") fixFS = @/[\x01]/
    if (typeof(fix) == "untyped") fix = "\x01"
    gsub(" ", fix, expression)
    for (d = 1; d <= defines["length"]; ++d) {
        c = defines[d]
        gsub(/ +/, fix, defines[c]["body"])
    }
    return Expression_evaluate(expression)
}

function Expression_evaluate(expression,    a, arguments, b, c, d, defineBody, e, f, g,
                             h, i, j, k, l, m, n, name, number, o, p, q, r, s, t, u, v, w, x, y, z)
{
    Index_push(expression, fixFS, fix)
    Index_reset()
    for (i = 1; i <= NF; ++i) {
#        if ($i == ")") {
#            Index_remove(i--)
#            continue
#        }
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
            x = Expression_evaluate(m)
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
__debug2("QuestionMark: "q" TrueAnswer: "t" FalseAnswer: "f)
            x = Expression_evaluate(q)
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
            if (Array_contains(defines, n)) $i = "1"; else $i = "0"
if ($i != "0")
__debug2("Defined "n)
else
__debug2("NotDefined "n)
            Index_remove(i + 1, i + 2, i + 3)
            continue
        }
        # Evaluate AWA ( a , b ) or AWA
        if ($i ~ /^[[:alpha:]_][[:alpha:]_0-9]*$/) {
            name = $i
            if (!Array_contains(defines, name)) {
__debug2("NotUsing "name)
                $i = "0"
                continue
            }
            n = Define_apply(i, noredefines)
__debug2("Using "name" "$0)
#gsub(fixFS, " ")
            --i # i += n - 1
#            $i = "x"
            continue
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
__debug2("not: "$0)
            continue
        }
        # Evaluate Binary, Bitwise NOT ~ Negation: the complement of n
        if ($i == "~") {
            if ($(i + 1) == "~") continue
            if ($(i + 1) !~ /^[-+]?[0-9]+$/) continue
            $i = compl($(i + 1))
            Index_remove(i + 1)
            if ($(i - 1) == "~") --i
__debug2("NOT: "$0)
            continue
        }
    }

    for (i = 1; i <= NF; ++i) {
        # Evaluate Multiplikation * Division /
        if ($i == "/") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            if (!$(i + 1)) {
                $i = 0
__debug2("Division through null: "$0)
            }
            else {
                $i = $(i - 1) / $(i + 1)
                Index_remove(i - 1, i + 1); --i
__debug2("Division: "$0)
            }
        }
        if ($i == "*") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) * $(i + 1)
            Index_remove(i - 1, i + 1); --i
__debug2("Multiplikation: "$0)
        }
    }

    for (i = 1; i <= NF; ++i) {
        # Evaluate Subtraktion - Addition +
        if ($i == "-") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            if ((i > 3 && ($(i - 2) == "*" || $(i - 2) == "/")) || ($(i + 2) == "*" || $(i + 2) == "/")) continue
            $i = $(i - 1) - $(i + 1)
            Index_remove(i - 1, i + 1); --i
__debug2("Subtraktion: "$0)
        }
        if ($i == "+") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            if ((i > 3 && ($(i - 2) == "*" || $(i - 2) == "/")) || ($(i + 2) == "*" || $(i + 2) == "/")) continue
            $i = $(i - 1) + $(i + 1)
            Index_remove(i - 1, i + 1); --i
__debug2("Addition: "$0)
        }
    }

    for (i = 1; i <= NF; ++i) {
        # Evaluate Left Shift << Right Shift >>
        if ($i == "<<") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = lshift($(i - 1), $(i + 1))
            Index_remove(i - 1, i + 1); --i
__debug2("LeftShift: "$0)
        }
        if ($i == ">>") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = rshift($(i - 1), $(i + 1))
            Index_remove(i - 1, i + 1); --i
__debug2("RightShift: "$0)
        }
    }

    for (i = 1; i <= NF; ++i) {
        # Evaluate Comparison, Boolean Equality == <= < >= > !=
        if ($i == "==") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) == $(i + 1)
            Index_remove(i - 1, i + 1); --i
__debug2("Equals: "$0)
        }
        if ($i == "<=") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) <= $(i + 1)
            Index_remove(i - 1, i + 1); --i
__debug2( "LowerThanEquals: "$0 )
        }
        if ($i == "<") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) < $(i + 1)
            Index_remove(i - 1, i + 1); --i
__debug2( "LowerThan: "$0 )
        }
        if ($i == ">=") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) >= $(i + 1)
            Index_remove(i - 1, i + 1); --i
__debug2( "GreaterThanEquals: "$0 )
        }
        if ($i == ">") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) > $(i + 1)
            Index_remove(i - 1, i + 1); --i
__debug2( "GreaterThan: "$0 )
        }
        if ($i == "!=") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) != $(i + 1)
            Index_remove(i - 1, i + 1); --i
__debug2( "NotEquals: "$0 )
        }
    }
    for (i = 1; i <= NF; ++i) {
        # Evaluate Logical Boolean and && or ||
        if ($i == "&&") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) && $(i + 1)
            Index_remove(i - 1, i + 1); --i
__debug2("and: "$0)
            if (!$i) NF = i
        }
        if ($i == "||") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) || $(i + 1)
            Index_remove(i - 1, i + 1); --i
__debug2("or: "$0)
            if (!$i) NF = i
        }
    }
    r = Index_pop()
#__debug2("Expression: "r)
    return r
}



function __Expression_evaluate(expression, defines,    a, arguments, b, c, d, defineBody, e, f, g,
                             h, i, I, j, k, l, m, n, name, number, o, p, q, r, s, t, u, v, w, x, y, z)
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
            if ($i == "0" && $(i + 1) == "x") {
                $(i + 1) = ""
                number = ""
                for (n = i + 2; n <= NF; ++n) {
                    if ($n ~ /[0-9a-fA-F]/) { number = number $n; $n = ""; continue }
                    --n; break
                }
                for (n = n + 1; n <= NF; ++n) {
                    if ($n ~ /[ulUL]/) { $n = ""; continue }
                    --n; break
                }
                $i = strtonum("0x"number)
                i += length($i) - 1
                Index_reset()
                if (i < NF) if (Index_append(i, " ", " ")) ++i
                continue
            }
            for (; ++i <= NF; ) {
                if ($i ~ /[0-9]/) continue
                --i; break
            }
            if ($(i + 1) ~ /[uUlL]/) {
                for (n = i + 1; n <= NF; ++n) {
                    if ($n ~ /[uUlL]/) continue
                    --n; break
                }
                Index_removeRange(i + 1, n)
            }
            if (i < NF) if (Index_append(i, " ", " ")) ++i
            continue
        }
        if ($i == "L" && $(i + 1) == "'") {
            Index_remove(i--); continue
        }
        if ($i == "'") {
            if (Index_prepend(i, " ", " ")) ++i
            if ($(i + 1) == "\\") {
                $(i + 1) = ""
                if ($(i + 2) == "x") {
                    $(i + 2) = ""
                    number = ""
                    for (n = i + 3; n <= NF; ++n) {
                        if ($n ~ /[0-9a-fA-F]/) { number = number $n; $n = ""; continue }
                        --n; break
                    }
                    $i = strtonum("0x"number)
                }
                else {
                    number = ""
                    for (n = i + 2; n <= NF; ++n) {
                        if ($n ~ /[0-7]/) { number = number $n; $n = ""; continue }
                        --n; break
                    }
                    $i = strtonum(number)
                }
                if ($(n + 1) == "'") $(n + 1) = ""
            }
            else {
                number = $(i + 1)
                $i = chartonum(number)
                $(i + 1) = ""
                if ($(i + 2) == "'") $(i + 2) = ""
            }
            i += length($i) - 1
            Index_reset()
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
        if ($i == "?" || $i == ":") {
            if (i > 1) if (Index_prepend(i, " ", " ")) ++i
            if (i < NF) if (Index_append(i, " ", " ")) ++i
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
#            if ((l = Index["length"]) > I) {
#                for (o = 1; o <= NF; ++o)
#                    if ($o == "\\") $o = ""
#                Index_reset()
#                i = Index[l]["i"]
#                n = NF
#                $i = Index_pop()
#                Index_reset()
#                i += n - 1
#                continue
#            }
            break
        }
#        if ($i == ")") {
#            Index_remove(i--)
#            continue
#        }
        if ($i == "(") {
            m = ""
            p = 0; for (o = i + 1; o <= NF; ++o) {
                if ($o == "(" || $o == "{") ++p
                if ($o == ")" || $o == "}") { if (p) --p; else break }
                m = String_concat(m, " ", $o)
            }
            Index_removeRange(i + 1, o)
            x = __Expression_evaluate(m, defines)
            Index_push(x, " ", " ")
            n = NF
            Index_pop()
            $i = x
            --i
            continue
        }
        if ($i == "?") {
            q = ""
            for (n = 1; n < i; ++n) {
                q = String_concat(q, " ", $n)
            }
            t = ""
            p = 0; for (o = i + 1; o <= NF; ++o) {
                if (!p && $o == ":") break
                if ($o == "(" || $o == "{") ++p
                if ($o == ")" || $o == "}") { if (p) --p }
                t = String_concat(t, " ", $o)
            }
            if ($o != ":") __error("QuestionMark isn't followed by :")
            f = ""
            for (p = o + 1; p <= NF; ++p) {
                f = String_concat(f, " ", $p)
            }
__debug2("QuestionMark: "q" TrueAnswer: "t" FalseAnswer: "f)
            x = __Expression_evaluate(q, defines)
            NF = 1
            if (x) {
                Index_push(t, " ", " ")
                n = NF
                Index_pop()
                $1 = t
            }
            else {
                Index_push(f, " ", " ")
                n = NF
                Index_pop()
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
            if (Array_contains(defines, n)) $i = "1"; else $i = "0"
__debug2("Defined "n" "$i)
            Index_remove(i + 1, i + 2, i + 3)
            continue
        }
        # Evaluate AWA ( a , b ) or AWA
        if ($i ~ /^[[:alpha:]_][[:alpha:]_0-9]*$/) {
            name = $i
            if (!Array_contains(defines, name)) {
__debug2("NotDefined "name)
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
                        if ($o == ")" || $o == "}") { if (p) --p; else break }
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
__debug2("Define "name" without body")
                $i = "0"
                continue
            }
            gsub(fixFS, " ", defineBody)
__debug2("Using "name" "defineBody)
#            Index_push(defineBody, " ", " ")
#            l = Index["length"]
#            Index[l]["name"] = name
#            Index[l]["i"] = i
#            i = 0; continue
            $i = __Expression_evaluate(defineBody, defines)
#            $i = defineBody
            Index_reset()
            --i; continue
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
__debug2("not: "$0)
            continue
        }
        # Evaluate Binary, Bitwise NOT ~ Negation: the complement of n
        if ($i == "~") {
            if ($(i + 1) == "~") continue
            if ($(i + 1) !~ /^[-+]?[0-9]+$/) continue
            $i = compl($(i + 1))
            Index_remove(i + 1)
            if ($(i - 1) == "~") --i
__debug2("NOT: "$0)
            continue
        }
    }

    for (i = 1; i <= NF; ++i) {
        # Evaluate Multiplikation * Division /
        if ($i == "/") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            if (!$(i + 1)) {
                $i = 0
__debug2("Division through null: "$0)
            }
            else {
                $i = $(i - 1) / $(i + 1)
                Index_remove(i - 1, i + 1); --i
__debug2("Division: "$0)
            }
        }
        if ($i == "*") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) * $(i + 1)
            Index_remove(i - 1, i + 1); --i
__debug2("Multiplikation: "$0)
        }
    }

    for (i = 1; i <= NF; ++i) {
        # Evaluate Subtraktion - Addition +
        if ($i == "-") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            if ((i > 3 && ($(i - 2) == "*" || $(i - 2) == "/")) || ($(i + 2) == "*" || $(i + 2) == "/")) continue
            $i = $(i - 1) - $(i + 1)
            Index_remove(i - 1, i + 1); --i
__debug2("Subtraktion: "$0)
        }
        if ($i == "+") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            if ((i > 3 && ($(i - 2) == "*" || $(i - 2) == "/")) || ($(i + 2) == "*" || $(i + 2) == "/")) continue
            $i = $(i - 1) + $(i + 1)
            Index_remove(i - 1, i + 1); --i
__debug2("Addition: "$0)
        }
    }

    for (i = 1; i <= NF; ++i) {
        # Evaluate Left Shift << Right Shift >>
        if ($i == "<<") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = lshift($(i - 1), $(i + 1))
            Index_remove(i - 1, i + 1); --i
__debug2("LeftShift: "$0)
        }
        if ($i == ">>") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = rshift($(i - 1), $(i + 1))
            Index_remove(i - 1, i + 1); --i
__debug2("RightShift: "$0)
        }
    }

    for (i = 1; i <= NF; ++i) {
        # Evaluate Comparison, Boolean Equality == <= < >= > !=
        if ($i == "==") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) == $(i + 1)
            Index_remove(i - 1, i + 1); --i
__debug2("Equals: "$0)
        }
        if ($i == "<=") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) <= $(i + 1)
            Index_remove(i - 1, i + 1); --i
__debug2( "LowerThanEquals: "$0 )
        }
        if ($i == "<") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) < $(i + 1)
            Index_remove(i - 1, i + 1); --i
__debug2( "LowerThan: "$0 )
        }
        if ($i == ">=") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) >= $(i + 1)
            Index_remove(i - 1, i + 1); --i
__debug2( "GreaterThanEquals: "$0 )
        }
        if ($i == ">") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) > $(i + 1)
            Index_remove(i - 1, i + 1); --i
__debug2( "GreaterThan: "$0 )
        }
        if ($i == "!=") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) != $(i + 1)
            Index_remove(i - 1, i + 1); --i
__debug2( "NotEquals: "$0 )
        }
    }
    for (i = 1; i <= NF; ++i) {
        # Evaluate Logical Boolean and && or ||
        if ($i == "&&") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) && $(i + 1)
            Index_remove(i - 1, i + 1); --i
__debug2("and: "$0)
            if (!$i) NF = i
        }
        if ($i == "||") {
            if ($(i + 1) !~ /^[-+]?[0-9]+$/ || $(i - 1) !~ /^[-+]?[0-9]+$/) continue
            $i = $(i - 1) || $(i + 1)
            Index_remove(i - 1, i + 1); --i
__debug2("or: "$0)
            if (!$i) NF = i
        }
    }
    return Index_pop()
}

