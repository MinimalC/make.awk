#
# Gemeinfrei. Public Domain.
# 2020 Hans Riehm

#include "../make.awk/meta.awk"
@include "../make.awk/make.CExpression_evaluate.awk"

function C_prepare(    a,b,c,input, output)
{
    Array_add(includeDirs, "/usr/include/")
    Array_add(includeDirs, "/usr/include/x86_64-linux-gnu/")
    Array_add(includeDirs, "/usr/lib/gcc/x86_64-linux-gnu/7/include/")

    Array_clear(defines)

    Array_clear(types)
    types["void"]
    types["unsigned"]
    types["signed"]
    types["char"]
    types["short"]
    types["int"]
    types["long"]
    types["float"]
    types["double"]

    if (!("gcc" in parsed)) {
        input["name"] = "gcc"
        input[++input["length"]] = "# define _GNU_SOURCE 1"
        # input[++input["length"]] = "# define _XOPEN_SOURCE 1100"
        # input[++input["length"]] = "# define _XOPEN_SOURCE_EXTENDED 1"

        input[++input["length"]] = "# define CHAR_BIT 8"
        input[++input["length"]] = "# define CHAR_MIN (-CHAR_MAX - 1)"
        input[++input["length"]] = "# define CHAR_MAX 0x7F"
        input[++input["length"]] = "# define UCHAR_MAX 0xFF"

        input[++input["length"]] = "# define SHORT_MIN (-SHORT_MAX - 1)"
        input[++input["length"]] = "# define SHORT_MAX 0x7FFF"
        input[++input["length"]] = "# define USHORT_MAX 0xFFFF"

        input[++input["length"]] = "# define INT_MIN (-INT_MAX - 1)"
        input[++input["length"]] = "# define INT_MAX 0x7FFFFFFF"
        input[++input["length"]] = "# define UINT_MAX 0xFFFFFFFF"

        input[++input["length"]] = "# define LONG_MIN (-LONG_MAX - 1L)"
        input[++input["length"]] = "# define LONG_MAX 0x7FFFFFFFFFFFFFFFL"
        input[++input["length"]] = "# define ULONG_MAX 0xFFFFFFFFFFFFFFFFL"

        input[++input["length"]] = "# include <stdint.h>"

        output["name"] = "gcc"
        gcc_sort_coprocess("-dM -E", input, output)
        gcc_coprocess("-E", input, output)
        C_parse("gcc", output)
    }

    Array_clear(preprocessed)

    Array_clear(precompiled)
}

function C_parse(fileName, file,    a, b, c, comments, continuation, d, directory, e, f, g, h, hash, i, j, k, l, m,
                                    n, name, o, p, q, r, s, string, t, u, v, w, was, x, y, z, Z, zahl)
{
if (DEBUG == 2) __debug("Q: C_parse0 File "fileName)

    if ( fileName && fileName in parsed && parsed[fileName]["length"] ) return 1
    if ( !file["length"] ) if (!fileName || !File_read(file, fileName)) return
    parsed[fileName]["name"] = fileName

    Index_push("", "", "", "\0", "\n")
while (++z <= file["length"]) {
    Index_reset(file[z])
    was = "newline"
    i = 0
    if (hash) {
        hash = ""
        if (comments) { Index_prepend(1, "/*") }
    }
    while ($NF ~ /\s/)
        Index_remove(NF)
    while ($NF == "\\") {
        Index_remove(NF)
        if (++z <= file["length"]) Index_append(NF, file[z])
    }
    while (++i <= NF) {

        if (comments) {
            n = i - 1; c = 0; while (++n <= NF && ++c) {
                if (hash && n == NF) {
                    Index_append(n, "*/"); n += 2; c += 2
if (DEBUG == 2) __debug(fileName": Line "z":"i".."n": hash comment break")
                    break
                }
                if ($n == "/" && $(n + 1) == "*") {
                    if (c > 1) ++comments
                    if (comments > 1) {
                        __warning(fileName" Line "z": Comment in Comment /* /*")
                        $n = "*"
                    }
                    ++n; ++c
                    if (hash && n == NF) {
                        Index_append(n, "*/"); n += 2; c += 2
if (DEBUG == 2) __debug(fileName": Line "z":"i".."n": hash comment direct break")
                        break
                    }
                    continue
                }
                if ($n == "*" && $(n + 1) == "/") {
                    if (comments > 1) {
                        $n = "*"
                        --comments; ++n; ++c
                        continue
                    }
                    --comments; ++n; ++c
                    break
                }
            }
if (DEBUG == 2) __debug(fileName": Line "z":"i".."n": comments "was)
            i = n
            if (!comments) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "\\") {
            if (i == NF) {
                if (!hash)__warning(fileName": Line "z": Stray Line Continuation \\"$(i + 1))
                was = "\\"
if (DEBUG == 2) __debug(fileName": Line "z":"i": "was)
                Index_remove(i - 1, i); i -= 2
                if (++z <= file["length"]) Index_append(i, file[z])
                continue
            }
            if ($(i + 1) == "n") {
                __warning(fileName": Line "z": Stray \\n")
                Index_remove(i, i + 1); --i
                continue
            }
            __error(fileName": Line "z": Stray \\ or \\"$(i + 1))
            Index_remove(i); --i
            continue
        }
        if ($i == "#") {
            if ($(i + 1) == "#") {
                if (Index_prepend(i, fix, fix)) ++i
                ++i; was = "##"
if (DEBUG == 2) __debug(fileName": Line "z":"i": "was)
                if (Index_append(i, fix, fix)) ++i
                continue
            }
            if (was == "newline") {
                was = "#"; hash = "#"
                if (i > 1) { Index_removeRange(1, i - 1); i = 1 }
                n = i; while (++n <= NF) {
                    if ($n ~ /\s/) continue
                    --n; break
                }
                if (n > i) Index_removeRange(i + 1, n)
# if (DEBUG == 2) __debug(fileName": Line "z":"i": "was)
                if (Index_append(i, fix, fix)) ++i
                continue
            }
            if (Index_prepend(i, fix, fix)) ++i
            was = "#"
if (DEBUG == 2) __debug(fileName": Line "z":"i": "was)
            if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i ~ /\s/) {
            n = i; while (++n <= NF) {
                if ($n ~ /\s/) continue
                --n; break
            }
            # was = "space"
            if (hash) {
if (DEBUG == 2) __debug(fileName": Line "z":"i".."n": space")
                Index_removeRange(i, n); --i
                continue
            }
            if (Index_prepend(i, fix, fix)) ++i
if (DEBUG == 2) __debug(fileName": Line "z":"i".."n": space")
            i = n
            if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "L" && $(i + 1) == "\"") {
            if (Index_prepend(i, fix, fix)) ++i
        }
        if ($i == "\"") {
            if ($(i - 1) != "L") if (Index_prepend(i, fix, fix)) ++i
            was = "\""
            string = ""
            n = i; while (++n <= NF) {
                if ($n == "\\") {
                    string = string"\\"$(n + 1)
                    ++n; continue
                }
                if ($n == "\"") break
                string = string $n
            }
if (DEBUG == 2) __debug(fileName": Line "z":"i".."n": \""string"\"")
            i = n
            if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "<") {
            if (Index_prepend(i, fix, fix)) ++i
            was = "<"
            if (hash == "# include") {
                string = ""
                n = i; while (++n <= NF) {
                    if ($n == "\\") {
                        string = string"\\"$(n++)
                        continue
                    }
                    if ($n == ">") break
                    string = string $n
                }
if (DEBUG == 2) __debug(fileName": Line "z":"i".."n": # include <"string">")
                i = n
                if (Index_append(i, fix, fix)) ++i
                continue
            }
            if ($(i + 1) == "<") { ++i; was = was"<" }
            if ($(i + 1) == "=") { ++i; was = was"=" }
            if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "L" && $(i + 1) == "'") {
            if (Index_prepend(i, fix, fix)) ++i
        }
        if ($i == "'") {
            if ($(i - 1) != "L") if (Index_prepend(i, fix, fix)) ++i
            was = "'"
            string = ""
            n = i; while (++n <= NF) {
                if ($n == "\\") {
                    string = string"\\"$(n++)
                    continue
                }
                if ($n == "'") break
                string = string $n
            }
            i = n
            if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "/") {
            if (Index_prepend(i, fix, fix)) ++i
            if ($(i + 1) == "*") {
                was = "comment"; ++comments; --i
                continue
            }
            if ($(i + 1) == "/") {
                was = "comment"
                $(++i) = "*"
                Index_append(NF, "*/")
if (DEBUG == 2) __debug(fileName": Line "z":"i": // "was)
                i = NF
                continue
            }
            was = "/"
            if ($(i + 1) == "=") { ++i; was = was"=" }
            if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "*") {
            if ($(i + 1) == "/") { Index_remove(i, i + 1); --i; continue }
            if (Index_prepend(i, fix, fix)) ++i
            was = "*"
            if ($(i + 1) == "=") { ++i; was = was"=" }
            if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "=" || $i == "%" || $i == "^" || $i == "!") {
            if (Index_prepend(i, fix, fix)) ++i
            was = $i
            if ($(i + 1) == "=") { ++i; was = was"=" }
            if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "&" || $i == "|") {
            if (Index_prepend(i, fix, fix)) ++i
            was = $i
            if ($(i + 1) == $i) { ++i; was = was $i }
            else if ($(i + 1) == "=") { ++i; was = was "=" }
            if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == ">") {
            if (Index_prepend(i, fix, fix)) ++i
            was = ">"
            if ($(i + 1) == ">") { ++i; was = was">" }
            if ($(i + 1) == "=") { ++i; was = was"=" }
            if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == ".") {
            if (Index_prepend(i, fix, fix)) ++i
            was = "."
            if ( $(i + 1) == "." && $(i + 2) == "." ) { i += 2; was = "..." }
            if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "(" || $i == "[") {
            if (Index_prepend(i, fix, fix)) ++i
            was = $i
            if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == ")" || $i == "]") {
            if (Index_prepend(i, fix, fix)) ++i
            was = $i
            if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "," || $i == "?" || $i == ":" || $i == "~") {
            if (Index_prepend(i, fix, fix)) ++i
            was = $i
            if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == ";" || $i == "{" || $i == "}") {
            if (Index_prepend(i, fix, fix)) ++i
            was = $i
            if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "+") {
            if (Index_prepend(i, fix, fix)) ++i
            if ($(i + 1) ~ /[0-9]/ && was !~ /[0-9]/) continue
            was = "+"
            if ($(i + 1) == "+") { ++i; was = was"+" }
            else if ($(i + 1) == "=") { ++i; was = was"=" }
            if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "-") {
            if (Index_prepend(i, fix, fix)) ++i
            if ($(i + 1) ~ /[0-9]/ && was !~ /[0-9]/) continue
            was = "-"
            if ($(i + 1) == ">") { ++i; was = was">" }
            else if ($(i + 1) == "-") { ++i; was = was"-" }
            else if ($(i + 1) == "=") { ++i; was = was"=" }
            if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i ~ /[0-9]/) {
            if ($i == "0" && $(i + 1) == "x") {
                i += 2
                zahl = "0x"
                while (++i <= NF) {
                    if ($i ~ /[0-9a-fA-F]/) { zahl = zahl $i; continue }
                    --i; break
                }
                while (++i <= NF) {
                    if ($i ~ /[ulUL]/) { zahl = zahl $i; continue }
                    --i; break
                }
                if (Index_append(i, fix, fix)) ++i
                if (hash == "#") hash = "# "zahl
                was = zahl
if (DEBUG == 2) __debug(fileName": Line "z":"i": "was)
                continue
            }
            if ($(i - 1) !~ /[+-]/) if (Index_prepend(i, fix, fix)) ++i
            zahl = $i
            while (++i <= NF) {
                if ($i ~ /[0-9]/) { zahl = zahl $i; continue }
                --i; break
            }
            if ($(i + 1) ~ /[uUlL]/) {
                while (++i <= NF) {
                    if ($i ~ /[uUlL]/) { zahl = zahl $i; continue }
                    --i; break
                }
                if (Index_append(i, fix, fix)) ++i
                if (hash == "#") hash = "# "zahl
                was = zahl
if (DEBUG == 2) __debug(fileName": Line "z":"i": "was)
                continue
            }
            if ($(i + 1) == ".") {
                ++i; zahl = zahl $i
                # lies das Fragment
                while (++i <= NF) {
                    if ($i ~ /[0-9]/) { zahl = zahl $i; continue }
                    --i; break
                }
            }
            if ($(i + 1) ~ /[eE]/) {
                ++i; zahl = zahl $i
                if ($(i + 1) ~ /[+-]/) { ++i; zahl = zahl $i }
                # lies den Exponent
                while (++i <= NF) {
                    if ($i ~ /[0-9]/) { zahl = zahl $i; continue }
                    --i; break
                }
            }
            if ($(i + 1) ~ /[fFlLdD]/) {
                while (++i <= NF) {
                    if ($i ~ /[fFlLdD]/) { zahl = zahl $i; continue }
                    if ($i ~ /[0-9]/) { zahl = zahl $i; continue }
                    --i; break
                }
                if ($(i + 1) ~ /[xX]/) { ++i; zahl = zahl $i }
            }
            if (Index_append(i, fix, fix)) ++i
            if (hash == "#") hash = "# "zahl
            was = zahl
if (DEBUG == 2) __debug(fileName": Line "z":"i": "was)
            continue
        }
        if ($i ~ /[[:alpha:]_]/) {
            if (Index_prepend(i, fix, fix)) ++i
            name = $i
            n = i; while (++n <= NF) {
                if ($n ~ /[[:alpha:]_0-9]/) { name = name $n; continue }
                --n; break
            }
            was = name
if (DEBUG == 2) __debug(fileName": Line "z":"i".."n": "was)
            i = n
            if (hash == "#") hash = "# "name
            if (Index_append(i, fix, fix)) ++i
            continue
        }
        __warning(fileName": Line "z": Unknown Character "$i)
        Index_remove(i--)
    }

    if (hash) {
        if ($NF ~ fixFS) Index_remove(NF)
        parsed[fileName][++parsed[fileName]["length"]] = $0
        continue
    }
    parsed[fileName][++parsed[fileName]["length"]] = $0
}
    Index_pop()
if (DEBUG == 2) __debug("A: C_parse File "fileName)
    return 1
}

function C_preprocess(fileName,   a, b, c, comments, d, e, expressions, f, __FILE__Name, fun, g, h,
                                  i, ifExpressions, j, k, l, leereZeilen, level, m, moved, n, name, o, p, q,
                                  r, rendered, s, t, u, v, w, x, y, z, zZ, Z)
{
    if ( !(fileName in parsed) && !C_parse(fileName) ) return

    Index_push("", fixFS, fix, "\0", "\n")

    Index_push(get_FileName(fileName), @/[ *|+-:$%!?\^\.]+/, "_", "\0", "\0")
    __FILE__Name = "__FILE__"Index_pop()

    # if (!preprocessed["length"]) ++preprocessed["length"]

    preprocessed["declarations"]["length"]
    if (!(__FILE__Name in preprocessed["declarations"])) {
        preprocessed["declarations"][__FILE__Name]["body"] = fix"static"fix"char"fix __FILE__Name fix"["fix"]"fix"="fix"\""fileName"\""fix";"fix
    }

    # preprocessed[++preprocessed["length"]] = "#"fix 1 fix"\""fileName"\""
    preprocessed[preprocessed["length"]] = "#"fix"1"fix"\""fileName"\""" /* Zeile "++preprocessed["length"]" */"
    ++preprocessed["length"]

    defines["__FILE__"]["body"] = __FILE__Name

    for (z = 1; z <= parsed[fileName]["length"]; ++z) {
        Index_reset(parsed[fileName][z])

        defines["__LINE__"]["body"] = z

        # for (i = 1; i <= NF; ++i) if ($i ~ /^\s+$/) Index_remove(i--)

    if ($1 == "#") {
        if ($2 == "ifdef") {
            $2 = "if"
            for (n = 3; n <= NF; ++n)
                if ($n ~ /^[[:alpha:]_][[:alpha:]_0-9]*$/) {
                    $n = "defined"fix"("fix $n fix")"; Index_reset(); n += 3
                }
        }
        if ($2 == "ifndef") {
            $2 = "if"
            for (n = 3; n <= NF; ++n)
                if ($n ~ /^[[:alpha:]_][[:alpha:]_0-9]*$/) {
                    $n = "!"fix"defined"fix"("fix $n fix")"; Index_reset(); n += 4
                }
        }
        if ($2 == "if") {
            Index_remove(1, 2)

            f = Array_add(ifExpressions)
            ifExpressions[f]["if"] = $0

            w = CExpression_evaluate($0)
            if (w !~ /^[0-9]+$/) x = 0; else x = w + 0
            if (x) ifExpressions[f]["do"] = 1

if (DEBUG == 3 || DEBUG == 4 || DEBUG == 5) {
for (e = 1; e <= ifExpressions["length"]; ++e) { if (ifExpressions[e]["do"] == 1) continue; break }
if (e > f) __debug(fileName" Line "z": (Level "f") if "$0"  == "w" "(ifExpressions[f]["do"] == 1 ? "okay" : "not okay"))
}
            NF = 0
        }
        else if ($2 == "elif") {
            Index_remove(1, 2)

            f = ifExpressions["length"]
            ifExpressions[f]["else if"] = $0

            w = CExpression_evaluate($0)
            if (w !~ /^[0-9]+$/) x = 0; else x = w + 0
            if (ifExpressions[f]["do"] == 1) ifExpressions[f]["do"] = 2
            else if (!ifExpressions[f]["do"] && x) ifExpressions[f]["do"] = 1

if (DEBUG == 3 || DEBUG == 4 || DEBUG == 5) {
for (e = 1; e <= ifExpressions["length"]; ++e) { if (ifExpressions[e]["do"] == 1) continue; break }
if (e > f) __debug(fileName" Line "z": (Level "f") else if "$0"  == "w" "(ifExpressions[f]["do"] == 1 ? "okay" : "not okay"))
}
            NF = 0
        }
        else if ($2 == "else") {
            f = ifExpressions["length"]
            ifExpressions[f]["else"] = 1

            if (ifExpressions[f]["do"] == 1) ifExpressions[f]["do"] = 2
            else if (!ifExpressions[f]["do"]) ifExpressions[f]["do"] = 1

if (DEBUG == 3 || DEBUG == 4 || DEBUG == 5) {
for (e = 1; e <= ifExpressions["length"]; ++e) { if (ifExpressions[e]["do"] == 1) continue; break }
if (e > f) __debug(fileName" Line "z": (Level "f") else "(ifExpressions[f]["do"] == 1 ? "okay" : "not okay"))
}
            NF = 0
        }
        else if ($2 == "endif") {
            f = ifExpressions["length"]
            Array_remove(ifExpressions, f)

            NF = 0
        }
        if (NF == 0) { ++leereZeilen; continue }
    }

        for (e = 1; e <= ifExpressions["length"]; ++e) {
            if (ifExpressions[e]["do"] == 1) continue
            NF = 0; break
        }
        if (NF == 0) { ++leereZeilen; continue }

    if ($1 == "#") { # if ($2 == "include_next")
        if ($2 == "include") {
            if ($3 ~ /^</) {
                m = substr($3, 2, length($3) - 2)
                for (n = 1; n <= includeDirs["length"]; ++n) {
                    o = Path_join(includeDirs[n], m)
                    if (File_exists(o)) {
if (DEBUG == 3 || DEBUG == 4 || DEBUG == 5) __debug(fileName" Line "z": including "o)
                        zZ = preprocessed["length"]
                        C_preprocess(o)
                        defines["__FILE__"]["body"] = __FILE__Name
                        defines["__LINE__"]["body"] = z
                        break
                    }
                }
                if (n > includeDirs["length"]) __warning(fileName" Line "z": File doesn't exist: <"m">")
            }
            else {
                m = get_DirectoryName(fileName)
                m = Path_join(m, substr($3, 2, length($3) - 2))
                if (File_exists(m)) {
if (DEBUG == 3 || DEBUG == 4 || DEBUG == 5) __debug(fileName" Line "z": including "m)
                    zZ = preprocessed["length"]
                    C_preprocess(m)
                    defines["__FILE__"]["body"] = __FILE__Name
                    defines["__LINE__"]["body"] = z
                }
                else __warning(fileName" Line "z": File doesn't exist: \""m"\"")
            }
            if (zZ && zZ < preprocessed["length"]) {
            # preprocessed[++preprocessed["length"]] = "#"fix z fix"\""fileName"\""
                preprocessed[preprocessed["length"]] = "#"fix z fix"\""fileName"\""" /* Zeile "++preprocessed["length"]" */"
                ++preprocessed["length"]
                zZ = 0
            }
            NF = 0
        }
        if ($2 == "define") {
            name = $3
            if (name in defines) {
                __warning(fileName" Line "z": define "name" exists already")
            }
            else {
                Index_remove(1, 2, 3)
                # defines[name]["isFunction"] = 0
                if ($1 == "(") {
                    for (n = 2; n <= NF; ++n) {
                        if ($n ~ /^[[:alpha:]_][[:alpha:]_0-9]*$/) {
                            if ($n in types) { __warning(fileName" Line "z": Ambiguous define "name" argument "$n" (typedef)"); break }
                            if ($n in defines) { __warning(fileName" Line "z": Ambiguous define "name" argument "$n" (define)"); break }
                            continue
                        }
                        if ($n == ",") continue
                        if ($n == "...") continue
                        if ($n == ")") break
                        break
                    }
                    if ($n == ")") { # n < NF
                        m = ""; for (o = 2; o < n; ++o) {
                            # if ($o in types) __warning(fileName" Line "z": Ambiguous define "name" argument "$o" (typedef)")
                            # if ($o in defines) __warning(fileName" Line "z": Ambiguous define "name" argument "$o" (define)")
                            m = String_concat(m, fix, $o)
                            if ($o == ",") continue
                            g = ++defines[name]["arguments"]["length"]
                            defines[name]["arguments"][g] = $o
                        }
                        defines[name]["arguments"]["text"] = m
                        defines[name]["isFunction"] = 1
                        Index_removeRange(1, n)
                    }
                }

                defines[name]["body"] = $0

if (DEBUG == 3 || DEBUG == 4 || DEBUG == 5) {
Index_push(defines[name]["body"], "", ""); for (m = 1; m <= NF; ++m) if ($m ~ fixFS) $m = " "; rendered = Index_pop()
if (defines[name]["isFunction"])
__debug(fileName" Line "z": define "name" ("defines[name]["arguments"]["text"]")  "rendered)
else
__debug(fileName" Line "z": define "name"  "rendered)
}
            }
            NF = 0
        }
        if ($2 == "undef") {
            name = $3
            if (!(name in defines)) __warning(fileName" Line "z": undef doesn't exist: "name)
            else {
if (DEBUG) {
Index_push(defines[name]["body"], "", ""); for (m = 1; m <= NF; ++m) if ($m ~ fixFS) $m = " "; rendered = Index_pop()
if (defines[name]["isFunction"])
__debug(fileName" Line "z": undef "name" ("defines[name]["arguments"]["text"]")  "rendered)
else
__debug(fileName" Line "z": undef "name"  "rendered)
}
                delete defines[name]
            }
            NF = 0
        }
        if ($2 == "warning") {
            Index_push($0, fixFS, " ", "\0", "\n")
            __warning($0)
            Index_pop()
            NF = 0
        }
        if ($2 == "error") {
            Index_push($0, fixFS, " ", "\0", "\n")
            __error($0)
            Index_pop()
            NF = 0
        }
        # if ($2 == "pragma")

        if ($2 ~ /^[+-]?[0-9]+$/) NF = 0 # Line Numbers

        if (NF > 0) {
            Index_push($0, fixFS, " ", "\0", "\n")
            __error("Unknown "$0)
            Index_pop()
            # $1 = "/*"$1; $NF = $NF"*/"; Index_reset()
            NF = 0
        }
        if (NF == 0) { ++leereZeilen; continue }
        preprocessed[++preprocessed["length"]] = $0; ++preprocessed["length"]; continue
    }

        parsed[fileName]["I"] = Index["length"]
        for (i = 1; i <= NF; ++i) {
            if ($i in defines) {
                name = $i
if (DEBUG == 4) __debug(fileName" Line "z": applying "name)
                parsed[fileName]["z"] = z
                n = CDefine_apply(i, parsed[fileName])
                z = parsed[fileName]["z"]
                i += n - 1
            }
        }
        delete parsed[fileName]["I"]

        for (i = 1; i <= NF; ++i) {
            if (comments) {
                if ($i ~ /\*\/$/) { Index_remove(i--); --comments; continue }
                Index_remove(i--); continue
            }
            if ($i ~ /^\/\* \w[^#]\w* \*\/$/) continue
            if ($i ~ /^\/\*/) { ++comments; --i; continue }
            if ($i ~ /^\/\//) { NF = --i; break }
            if ($i == "\\") { Index_remove(i--); continue }
        }
        # cleanup
        for (i = 1; i <= NF; ++i) {
            if ($i ~ /^\n+$/ && $(i + 1) ~ /^\n+$/) { $i = $i $(i + 1); Index_remove(i + 1); --i; continue }
            if (i > 1 && $i == "") { Index_remove(i); --i; continue }
        }

        level = expressions["length"]
        if (!level) level = ++expressions["length"]
        expressions[level]["length"]
        for (i = 1; i <= NF; ++i) {

            # Get typedef struct SomeThing { ... }  * SomeThing ,  * * Array ,  SomeThing ( * function_Delegate ) ( void ) ;

            # and for ISO C also typedef struct SomeThing { ... } SomeThing_t ,  SomeThing_t ( * fun_Action ) ( void ) ;

            # or just struct SomeThing { ... }

            if ($i == "{") {
                level = ++expressions["length"]
                expressions[level]["length"]
                continue
            }
            if ($i == ";") {
                # if (!e) ; # you don't need semikolon
                Array_clear(expressions[level])
                continue
            }
            if ($i == "}") {
                delete expressions[level]
                level = --expressions["length"]
                continue
            }
            if ($i == "typedef") {
                # if (level > 1) __error()
                # if (e > 0) ; # do you need semikolon?
                expressions[level]["isTypedef"]
                continue
            }
            if ($i == "const" || $i == "volatile" || $i == "struct" || $i == "union" || $i == "enum" || $i in types) {
                # expressions[level]["Type"]
                name = ""; fun = ""
                # if ($i in types) name = $i
                k = 0; o = 0; for (n = i; n <= NF; ++n) {
                    if (name && !fun && !o && $n == "(") {
                        ++k # name = String_concat(name, " ", $n)
                        if (i != n) { $i = String_concat($i, " ", $n); $n = "\a\b" } continue
                    }
                    if ($n == "const" || $n == "volatile") {
                        if (i != n) { $i = String_concat($i, " ", $n); $n = "\a\b" } continue
                    }
                    if ($n == "*") {
                        # name = String_concat(name, " ", $n)
                        if (i != n) { $i = String_concat($i, " ", $n); $n = "\a\b" } continue
                    }
                    if (!fun && k && $n ~ /^[[:alpha:]_][[:alpha:]_0-9]*$/) {
                        fun = $n # name = String_concat(name, " ", $n)
                        if (i != n) { $i = String_concat($i, " ", $n); $n = "\a\b" } continue
                    }
                    if (k && $n == ")") {
                        --k; o = 1 # name = String_concat(name, " ", $n)
                        if (i != n) { $i = String_concat($i, " ", $n); $n = "\a\b" } continue
                    }
                    if ($n == "void" || $n == "unsigned" || $n == "signed" ||
                        $n == "char" || $n == "short" || $n == "int" || $n == "long" ||
                        $n == "float" || $n == "double")
                    {
                        name = String_concat(name, " ", $n)
                        if (i != n) { $i = String_concat($i, " ", $n); $n = "\a\b" } continue
                    }
                    if (!name && ($n == "struct" || $n == "union" || $n == "enum")) {
                        if ($(n + 1) !~ /^[[:alpha:]_][[:alpha:]_0-9]*$/) { __warning(fileName" Line "z": "$n" without name"); break }
                        name = $n" "$(n + 1)
                        if (i != n) { $i = String_concat($i, " ", $n); $n = "\a\b" }
                        $i = String_concat($i, " ", $(n + 1)); $(++n) = "\a\b"
                        continue
                    }
                    if (!name && ($n in types)) {
                        name = $n; if (i != n) { $i = String_concat($i, " ", $n); $n = "\a\b"} continue
                    }
                    break
                }
                Index_reset()
                if (name) if (!(name in types)) types[name]
                if ("isTypedef" in expressions[level]) {
                    if (fun) { if (!(fun in types)) types[fun] }
                    else {
                        if ($(i + 1) ~ /^[[:alpha:]_][[:alpha:]_0-9]*$/)
                            if (!($(i + 1) in types))
                                types[$(i + 1)] = name
                    }
                }
                continue
            }
        }
        if (NF == 0) { ++leereZeilen; continue }

        #if (leereZeilen <= 5) preprocessed["length"] += leereZeilen
        #else {
        #    preprocessed["length"] += 2
        ## preprocessed[++preprocessed["length"]] = "#"fix z fix"\""fileName"\""
        ## preprocessed[preprocessed["length"]] = "#"fix z fix"\""fileName"\""" /* Zeile "++preprocessed["length"]" */"
        #}
        #leereZeilen = 0
        #preprocessed[++preprocessed["length"]] = $0

        # Index_prepend(1, "")
        Index_append(NF, "\n")

        # if (leereZeilen > 5) leereZeilen = 5; for (l = leereZeilen; l; --l) $NF = $NF"\n"
        if (leereZeilen) $NF = $NF"\n"; leereZeilen = 0

        preprocessed[preprocessed["length"]] = preprocessed[preprocessed["length"]] $0
    }
    Index_pop()
    return 1
}

function C_precompile(fileName,   h,i,j,k,l,m,n,x,y,z) {

    List_clear(preprocessed)
    if (!("gcc" in preprocessed)) {
        preprocessed["gcc"]
        C_preprocess("gcc")
    }
    if ( !C_preprocess(fileName) ) return

    # C_precompile is PROTOTYPE

    for (n in preprocessed["declarations"])
        if (typeof(preprocessed["declarations"][n]) == "array")
            precompiled[++precompiled["length"]] = preprocessed["declarations"][n]["body"]
    for (z = 1; z <= preprocessed["length"]; ++z)
        precompiled[++precompiled["length"]] = preprocessed[z]

    return 1
}

function C_compile(fileName,    o,p,pprecompiled,x,y,z)
{
    if ( !C_precompile(fileName) ) return

    Index_push("", fixFS, " ", "\0", "\n")
    for (z = 1; z <= precompiled["length"]; ++z)
        pprecompiled[++pprecompiled["length"]] = Index_reset(precompiled[z])
    Index_pop()

    Array_clear(compiled)
    if (gcc_coprocess(" -c -fpreprocessed -fPIC ", pprecompiled, ".make.o")) return
    File_read(compiled, ".make.o", "\0", "\0")
    return 1
}

function gcc_coprocess(options, input, output,    a,b,c,command,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) {
    if (typeof(input) == "string" && input) options = options" "input
    else options = options" -"
    if (typeof(output) == "string" && output) options = options" -o "output
    command = "gcc -xc "options
    if (typeof(input) == "array") {
        for (i = 1; i <= input["length"]; ++i) {
            print input[i] |& command
        }
    } else print "" |& command
    close(command, "to")
    Index_push("", "", "", "\n", "\n")
    while (0 < y = ( command |& getline )) {
        if (typeof(output) == "array") {
            output[++output["length"]] = $0
        }
    }
    Index_pop()
    if (y == -1) {
        __error("Command doesn't exist: "command)
        return
    }
    return close(command)
}

function gcc_sort_coprocess(options, input, output,    a,b,c,command,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) {
    if (typeof(input) == "string" && input) options = options" "input
    else options = options" -"
    if (typeof(output) == "string" && output) options = options" -o "output
    command = "gcc -xc "options" | sort"
    if (typeof(input) == "array") {
        for (i = 1; i <= input["length"]; ++i) {
            print input[i] |& command
        }
    } else print "" |& command
    close(command, "to")
    Index_push("", "", "", "\n", "\n")
    while (0 < y = ( command |& getline )) {
        if (typeof(output) == "array") {
            output[++output["length"]] = $0
        }
    }
    Index_pop()
    if (y == -1) {
        __error("Command doesn't exist: "command)
        return
    }
    return close(command)
}

function gcc_precompile(    h, i, j, k, l, m, n, o) {

    i = ".preprocess.C.gcc.c"
    print "/* Gemeinfrei */" > i
    print "#include <stdint.h>" > i
    close(i)

    o = ".preprocess.C.gcc...pre.c"
    system("gcc -std=c11 -E "i"  > "o)
    system("gcc -std=c11 -dM -E "i" | sort >> "o)

    return o
}
