#
# Gemeinfrei. Public Domain.
# 2020 Hans Riehm

#include "../make.awk/meta.awk"
@include "../make.awk/make.CExpression_evaluate.awk"

function C_parse(fileName, file,    a, b, c, comments, continuation, d, directory, e, f, g, h, hash, i, j, k, l, m,
                                    n, name, o, p, q, r, s, string, t, u, v, w, was, x, y, z, Z, zahl)
{
    if ( fileName in parsed && parsed[fileName]["length"] ) return 1

    if ( !file["length"] && !File_read(file, fileName)) return

    parsed[fileName]["name"] = file["name"]

    Index_push("", "", "", "\0", "\n")
for (z = 1; z <= file["length"]; ++z) {

    if (!continuation) {
        i = 1
        $0 = file[z]; Index_reset()
        Z = ++parsed[fileName]["length"]

        if (comments && hash ~ /^# /)
        {
            --comments
            $0 = "/*"$0
        }
        hash = ""
    }
    else {
        i += 2
        $0 = String_concat($0, fix, file[z]); Index_reset()
        continuation = 0
    }

    for (; i <= NF; ++i) {
        if (comments) {
            for ( ; i <= NF; ++i) {
                if ($i == "\\") {
                    if (i > 1) if (Index_prepend(i, fix, fix)) ++i
                    if (i == NF) break
                }
                if ($i == "/" && $(i + 1) == "*") {
                    ++comments
                    $(i++) = "*"
                    __warning(fileName" Line "z": Comment in Comment /* /*")
                    continue
                }
                if ($i == "*" && $(i + 1) == "/") {
                    if (comments > 1) {
                        --comments
                        $(++i) = "*"
                        continue
                    }
                    --comments
                    ++i
                    break
                }
            }
            if (i == NF && $i == "\\") {
                continuation = 1
                break
            }
            if (i < NF && !comments) if (Index_append(i, fix, fix)) ++i
            continue
        }
        #if ($i == "\n") {
        #    if (i > 1) if (Index_prepend(i, fix, fix)) ++i
        #    Z = ++output["length"]; was = "linebreak"; hash = ""
        #    while (++i <= NF) {
        #        if ($i == "\n") continue
        #        if ($i ~ /[ \f\t\v]/) continue
        #        --i; break
        #    }
        #    if (i < NF) if (Index_append(i, fix, fix)) ++i
        #    continue
        #}
        if ($i == "\\") {
            if ($(i + 1) == "n") {
                __warning(fileName": Line "z": Stray \\n")
                Index_remove(i, i + 1)
                --i; continue
            }
            if (i < NF) {
                __error(fileName": Line "z": Stray \\"$(i + 1))
#                Index_remove(i--)
                ++i
                continue
            }
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            continuation = 1
            break
        }
        if ($i ~ /[ \f\t\v]/) {
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            while (++i <= NF) {
                if ($i ~ /[ \f\t\v]/) continue
                --i; break
            }
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ((i == 1 || was == "linebreak") && $i == "#") {
            was = "#"; hash = "#"
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "L" && $(i + 1) == "\"") {
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            continue
        }
        if ($i == "\"") {
            if (i > 1 && $(i - 1) != "L") if (Index_prepend(i, fix, fix)) ++i
            was = "string"
            string = ""
            while (++i <= NF) {
                if ($i == "\\") {
                    if (i == NF) {
                        Index_remove(i--)
                        if (++z <= file["length"]) {
                            $0 = $0 file[z]
                            continue
                        }
                        break
                    }
                    string = string"\\"$(i + 1)
                    ++i; continue
                }
                if ($i == "\"") break
                string = string $i
            }
            if (i == NF && $i == "\\") {
                continuation = 1
                break
            }
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            #if (hash == "# include") {
            #    directory = get_DirectoryName(fileName)
            #    n = Path_join(directory, string)
            #    if (File_exists(n)) {
            #        List_add(origin, n) # ARGV_add(n)
            #    }
            #    else __error("File doesn't exist: \""n"\"")
            #}
            continue
        }
        if ($i == "L" && $(i + 1) == "'") {
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            continue
        }
        if ($i == "'") {
            if (i > 1 && $(i - 1) != "L") if (Index_prepend(i, fix, fix)) ++i
            was = "character"
            string = ""
            while (++i <= NF) {
                if ($i == "\\") {
                    if (i == NF) break
                    string = string"\\"$(i + 1)
                    ++i; continue
                }
                if ($i == "'") break
                string = string $i
            }
            if (i == NF && $i == "\\") {
                continuation = 1
                break
            }
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "/") {
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            if ($(i + 1) == "*") {
                was = "comment"; ++comments
                ++i; continue
            }
            if ($(i + 1) == "/") {
                was = "comment"
                $(++i) = "*"
                $NF = $NF"*/"
                break
            }
            was = "/"
            if ($(i + 1) == "=") { ++i; was = was"=" }
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "<") {
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            if (hash == "# include") {
                string = ""
                while (++i <= NF) {
                    if ($i == "\\") {
                        if (i == NF) break
                        string = string"\\"$(i + 1)
                        ++i; continue
                    }
                    if ($i == ">") break
                    string = string $i
                }
                if (i == NF && $i == "\\") {
                    continuation = 1
                    break
                }
                if (i < NF) if (Index_append(i, fix, fix)) ++i
                #for (d = 1; d <= includeDirs["length"]; ++d) {
                #    n = Path_join(includeDirs[d], string)
                #    if (File_exists(n)) {
                #        List_add(origin, n) # ARGV_add(n)
                #        break
                #    }
                #}
                #if (d > includeDirs["length"]) __error("File doesn't exist: <"string">")
                continue
            }
            was = "<"
            if ($(i + 1) == "<") { ++i; was = was"<" }
            if ($(i + 1) == "=") { ++i; was = was"=" }
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "*") {
            if ($(i + 1) == "/") { Index_remove(i, i + 1); --i; continue }
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            was = "*"
            if ($(i + 1) == "=") { ++i; was = was"=" }
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "+") {
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            if ($(i + 1) ~ /[0-9]/ && was != "zahl") continue
            was = "+"
            if ($(i + 1) == "+") { ++i; was = was"+" }
            else if ($(i + 1) == "=") { ++i; was = was"=" }
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "-") {
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            if ($(i + 1) ~ /[0-9]/ && was != "zahl") continue
            was = "-"
            if ($(i + 1) == ">") { ++i; was = was">" }
            else if ($(i + 1) == "-") { ++i; was = was"-" }
            else if ($(i + 1) == "=") { ++i; was = was"=" }
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "#") {
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            was = "#"
            if ($(i + 1) == "#") { ++i; was = was"#" }
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "=" || $i == "%" || $i == "^" || $i == "!") {
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            was = $i
            if ($(i + 1) == "=") { ++i; was = was"=" }
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "&" || $i == "|") {
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            was = $i
            if ($(i + 1) == $i) { ++i; was = was $i }
            else if ($(i + 1) == "=") { ++i; was = was "=" }
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "(" || $i == "{" || $i == "[") {
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            # was
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == ")" || $i == "}" || $i == "]") {
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            # was
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == ">") {
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            was = ">"
            if ($(i + 1) == ">") { ++i; was = was">" }
            if ($(i + 1) == "=") { ++i; was = was"=" }
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == ".") {
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            was = "."
            if ( $(i + 1) == "." && $(i + 2) == "." ) { i += 2; was = "..." }
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "," || $i == ";" || $i == "?" || $i == ":" || $i == "~") {
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            was = $i
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i ~ /[0-9]/) {
            if (i > 1 && $(i - 1) !~ /[+-]/) if (Index_prepend(i, fix, fix)) ++i
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
                if (i != NF) if (Index_append(i, fix, fix)) ++i
                if (hash == "#") hash = "# "zahl
                was = "zahl"
                continue
            }
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
                if (i != NF) if (Index_append(i, fix, fix)) ++i
                if (hash == "#") hash = "# "zahl
                was = "zahl"
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
            if (i != NF) if (Index_append(i, fix, fix)) ++i
            if (hash == "#") hash = "# "zahl
            was = "zahl"
            continue
        }
        if ($i ~ /[[:alpha:]_]/) {
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            name = $i
            while (++i <= NF) {
                if ($i ~ /[[:alpha:]_0-9]/) { name = name $i; continue }
                --i; break
            }
            if (hash == "#") hash = "# "name
            was = name
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        __warning(fileName": Line "z": Unknown Character "$i)
        Index_remove(i--)
    }
    if (!continuation && comments && hash ~ /^# /)
    {
        $NF = $NF"*/"
        Index_reset()
    }

    if (continuation) continue

    parsed[fileName][Z] = $0
}
    Index_pop()
    return 1
}

function C_precompile(fileName,   a, b, c, d, e, expressions, f, file, fileName_declaration, fun, g, h, i, ifExpressions, j, k,
                                  l, leereZeilen, m, n, name, o, p, q, r, rendered, s, t, u, v, w, x, y, z, Z)
{
    if ( !(fileName in parsed) && !C_parse(fileName) ) return

    Index_push(get_FileName(fileName), @/[ \.]+/, "_", "\0", "\0"); fileName_declaration = Index_pop()
    if ( !("declarations" in precompiled) || !("FILENAME_"fileName_declaration in precompiled["declarations"]) ) {
        precompiled[++precompiled["length"]] = "static"fix"char"fix"FILENAME_"fileName_declaration fix"["fix"]"fix"="fix"\""fileName"\""fix";"
        precompiled["declarations"]["FILENAME_"fileName_declaration]
    }
    defines["__FILE__"]["body"] = "FILENAME_"fileName_declaration

    precompiled[++precompiled["length"]] = "\n#"fix"1"fix"\""fileName"\""

    Index_push("", fixFS, fix, "\0", "\n")
    for (z = 1; z <= parsed[fileName]["length"]; ++z) {
        $0 = parsed[fileName][z]; Index_reset()

        for (i = 1; i <= NF; ++i) if ($i ~ /^[ \f\t\v]+$/) Index_remove(i--)

        defines["__LINE__"]["body"] = z

        if ($1 == "#") {
        if ($2 == "ifdef") {
            $2 = "if"
            for (n = 3; n <= NF; ++n) {
                if ($n ~ /^[[:alpha:]_][[:alpha:]_0-9]*$/) {
                    $n = "defined"fix"("fix $n fix")"; Index_reset(); n += 3
                }
            }
        }
        if ($2 == "ifndef") {
            $2 = "if"
            for (n = 3; n <= NF; ++n) {
                if ($n ~ /^[[:alpha:]_][[:alpha:]_0-9]*$/) {
                    $n = "!"fix"defined"fix"("fix $n fix")"; Index_reset(); n += 4
                }
            }
        }
        if ($2 == "if") {
            Index_remove(1, 2)

            f = Array_add(ifExpressions)
            ifExpressions[f]["if"] = $0

            w = CExpression_evaluate($0)
            if (w !~ /^[0-9]+$/) x = 0; else x = w + 0
            if (x) ifExpressions[f]["do"] = 1

            for (e = 1; e <= ifExpressions["length"]; ++e) {
                if (ifExpressions[e]["do"] == 1) continue
                break
            }
            if (e > f) {
if (DEBUG == 2 || DEBUG == 3 || DEBUG == 5) __debug(fileName" Line "z": (Level "f") if "$0"  == "w" "(ifExpressions[f]["do"] == 1 ? "okay" : "not okay"))
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

            for (e = 1; e <= ifExpressions["length"]; ++e) {
                if (ifExpressions[e]["do"] == 1) continue
                break
            }
            if (e > f) {
if (DEBUG == 2 || DEBUG == 3 || DEBUG == 5) __debug(fileName" Line "z": (Level "f") else if "$0"  == "w" "(ifExpressions[f]["do"] == 1 ? "okay" : "not okay"))
            }
            NF = 0
        }
        else if ($2 == "else") {
            f = ifExpressions["length"]
            ifExpressions[f]["else"] = 1

            if (ifExpressions[f]["do"] == 1) ifExpressions[f]["do"] = 2
            else if (!ifExpressions[f]["do"]) ifExpressions[f]["do"] = 1

            for (e = 1; e <= ifExpressions["length"]; ++e) {
                if (ifExpressions[e]["do"] == 1) continue
                break
            }
            if (e > f) {
if (DEBUG == 2 || DEBUG == 3 || DEBUG == 5) __debug(fileName" Line "z": (Level "f") else "(ifExpressions[f]["do"] == 1 ? "okay" : "not okay"))
            }
            NF = 0
        }
        else if ($2 == "endif") {
            f = ifExpressions["length"]
            Array_remove(ifExpressions, f)

            NF = 0
        } }

        for (e = 1; e <= ifExpressions["length"]; ++e) {
            if (ifExpressions[e]["do"] == 1) continue
            NF = 0; break
        }

        if ($1 == "#") {
        if ($2 == "include") {
            if ($3 ~ /^</) {
                m = substr($3, 2, length($3) - 2)
                for (n = 1; n <= includeDirs["length"]; ++n) {
                    o = Path_join(includeDirs[n], m)
                    if (File_exists(o)) {
if (DEBUG == 2 || DEBUG == 3 || DEBUG == 5) __debug(fileName" Line "z": including "o)
                        C_precompile(o)
                        defines["__FILE__"]["body"] = "FILENAME_"fileName_declaration
                        defines["__LINE__"]["body"] = z

                        precompiled[++precompiled["length"]] = "#"fix z fix"\""fileName"\""
                        break
                    }
                }
                if (n > includeDirs["length"]) __warning(fileName" Line "z": File doesn't exist: <"m">")
            }
            else {
                m = get_DirectoryName(fileName)
                m = Path_join(m, substr($3, 2, length($3) - 2))
                if (File_exists(m)) {
if (DEBUG == 2 || DEBUG == 3 || DEBUG == 5) __debug(fileName" Line "z": including "m)
                    C_precompile(m)
                    defines["__FILE__"]["body"] = "FILENAME_"fileName_declaration
                    defines["__LINE__"]["body"] = z
                }
                else __warning(fileName" Line "z": File doesn't exist: \""m"\"")

                precompiled[++precompiled["length"]] = "#"fix z fix"\""fileName"\""
            }
            NF = 0
        }
        # if ($2 == "include_next")
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
                            if ($n in types) break
                            if ($n in defines) break
                            continue
                        }
                        if ($n == ",") continue
                        if ($n == "...") continue
                        if ($n == ")") break
                        break
                    }
                    if ($n == ")") { # n < NF
                        m = ""; for (o = 2; o < n; ++o) {
                            m = String_concat(m, fix, $o)
                            if ($o == ",") continue
                            argumentI = ++defines[name]["arguments"]["length"]
                            defines[name]["arguments"][argumentI] = $o
                        }
                        defines[name]["arguments"]["text"] = m
                        defines[name]["isFunction"] = 1
                        Index_removeRange(1, n)
                    }
                }

                #m = ""; for (n = 1; n <= NF; ++n) {
                #    # if ($n == "\\") continue
                #    m = String_concat(m, fix, $n)
                #}
                defines[name]["body"] = $0

if (DEBUG == 2 || DEBUG == 3 || DEBUG == 5) {
Index_push(defines[name]["body"], "", ""); for (m = 1; m <= NF; ++m) if ($m == fix) $m = " "; rendered = Index_pop()
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
                delete defines[name]
if (DEBUG == 2 || DEBUG == 3 || DEBUG == 5) __debug(fileName" Line "z": undef "name)
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
        if ($2 ~ /^[+-]?[0-9]+$/) NF = 0
        if (NF > 0) {
            Index_push($0, fixFS, " ", "\0", "\n")
            __error("Unknown "$0)
            Index_pop()
            $1 = "/*"$1; $NF = $NF"*/"; Index_reset()
            # NF = 0
        } }

        parsed[fileName]["I"] = Index["length"]
        for (i = 1; i <= NF; ++i) {
            if ($i in defines) {
                name = $i
if (DEBUG == 3) __debug(fileName" Line "z": applying "name)
                parsed[fileName]["z"] = z
                n = CDefine_apply(i, parsed[fileName])
                z = parsed[fileName]["z"]
                i += n - 1
            }
        }
        delete parsed[fileName]["I"]

        for (i = 1; i <= NF; ++i) {
            if (comments) {
                if ($i ~ /\*\/$/) {
                    Index_remove(i--)
                    --comments
                    continue
                }
                Index_remove(i--)
                continue
            }
            if ($i ~ /^\/\*/) {
                ++comments
                --i; continue
            }
            if ($i ~ /^\/\//) {
                NF = --i
                break
            }
            if ($i == "\\") {
                Index_remove(i--)
                continue
            }
        }

        for (i = 1; i <= NF; ++i) {

            if ($i == "typedef") {
                if (e > 0) {
                    # do you need semikolon?
                }
                e = ++expressions["length"]
                expressions[e]["Type"] = "TypeDefine"
                continue
            }
            if ($i == "const" || $i == "volatile" || $i == "struct" || $i == "union" || $i in types) {
                if (expressions["length"] == 1 && expressions[1]["Type"] == "TypeDefine") { }
                else if (expressions["length"] > 0) {
                    # do you need semikolon?
                }
                e = ++expressions["length"]
                expressions[e]["Type"] = "Type"
                name = ""; fun = ""
#                if ($i in types) name = $i
                k = 0; o = 0; for (n = i; n <= NF; ++n) {
                    if (name && !fun && !o && $n == "(") {
                        ++k
                        # name = String_concat(name, " ", $n)
                        if (i != n) { $i = String_concat($i, " ", $n); $n = "" } continue
                    }
                    if ($n == "const" || $n == "volatile") {
                        if (i != n) { $i = String_concat($i, " ", $n); $n = "" } continue
                    }
                    if ($n == "*") {
                        # name = String_concat(name, " ", $n)
                        if (i != n) { $i = String_concat($i, " ", $n); $n = "" } continue
                    }
                    if (!fun && k && $n ~ /^[[:alpha:]_][[:alpha:]_0-9]*$/) {
                        fun = $n
                        # name = String_concat(name, " ", $n)
                        if (i != n) { $i = String_concat($i, " ", $n); $n = "" } continue
                    }
                    if (k && $n == ")") {
                        --k; o = 1
                        # name = String_concat(name, " ", $n)
                        if (i != n) { $i = String_concat($i, " ", $n); $n = "" } continue
                    }
                    if ($n == "void" || $n == "unsigned" || $n == "signed" ||
                        $n == "char" || $n == "short" || $n == "int" || $n == "long" ||
                        $n == "float" || $n == "double")
                    {
                        name = String_concat(name, " ", $n)
                        if (i != n) { $i = String_concat($i, " ", $n); $n = "" } continue
                    }
                    if (!name && ($n == "struct" || $n == "union")) {
                        if ($(n + 1) !~ /^[[:alpha:]_][[:alpha:]_0-9]*$/) { __warning(fileName" Line "z": "$n" without name"); break }
                        name = $n" "$(n + 1)
                        if (i != n) { $i = String_concat($i, " ", $n); $n = "" }
                        $i = String_concat($i, " ", $(n + 1)); $(++n) = ""
                        continue
                    }
                    if (!name && ($n in types)) {
                        name = $n; if (i != n) { $i = String_concat($i, " ", $n); $n = ""} continue
                    }
                    break
                }
                Index_reset()
                if (name) if (!(name in types)) types[name]
                if (expressions["length"] == 2 && expressions[1]["Type"] == "TypeDefine") {
                    if (fun) {
                        if (!(fun in types)) types[fun]
                    }
                    else {
                        if ($(i + 1) !~ /^[[:alpha:]_][[:alpha:]_0-9]*$/) __warning(fileName" Line "z": typedef without name")
                        else { ++i; if (!($i in types)) types[$i] }
                    }
                }
                continue
            }

            if ($i == ";") {
                if (!e) {
                    # you don't need semikolon
                }
                Array_clear(expressions)
                continue
            }
        }

        if (NF == 0) ++leereZeilen
        else {
            if (leereZeilen <= 3) {
                for (h = 1; h <= leereZeilen; ++h) {
                    precompiled[++precompiled["length"]] = ""
                }
            } else {
                precompiled[++precompiled["length"]] = ""
                precompiled[++precompiled["length"]] = ""
                precompiled[++precompiled["length"]] = "#"fix z fix"\""fileName"\""
            }
            leereZeilen = 0
            precompiled[++precompiled["length"]] = $0
        }
    }
    Index_pop()
}

