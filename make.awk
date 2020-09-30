#!/usr/bin/awk -f
# Gemeinfrei. Public Domain.
# 2020 Hans Riehm

@include "../make.awk/meta.awk"
#include "../make.awk/make.awk"

BEGIN {
    FS="";OFS="";RS="\0";ORS="\n"
    fixFS = @/\x01/
    fix = "\x01"

    make = "make_precompile"

    if (ARGV_length() == 0) { __error("Usage: make.awk include Program.c"); exit 1 }

    Array_add(includeDirs, "/usr/include/")
    Array_add(includeDirs, "/usr/include/x86_64-linux-gnu/")
    Array_add(includeDirs, "/usr/lib/gcc/x86_64-linux-gnu/7/include/")

    target = gcc_precompile()
    Array_add(origin, target)

    Array_add(defines, "_XOPEN_SOURCE")
    defines["_XOPEN_SOURCE"]["body"] = 1100
    Array_add(defines, "_XOPEN_SOURCE_EXTENDED")
    defines["_XOPEN_SOURCE_EXTENDED"]["body"] = 1

    for (argI = 1; argI <= ARGV_length(); ++argI) {

        if (argI == 1 && "make_"ARGV[argI] in FUNCTAB) {
            make = "make_"ARGV[argI]
            ARGV[argI] = ""; continue
        }

        paramName = ""
        if (ARGV[argI] ~ /^.*=.*$/) {
            paramI = index(ARGV[argI], "=")
            paramName = substr(ARGV[argI], 1, paramI - 1)
            paramWert = substr(ARGV[argI], paramI + 1)
        } else
        if (ARGV[argI] ~ /^\+.*$/) {
            paramName = substr(ARGV[argI], 2)
            paramWert = 1
        }
        if (ARGV[argI] ~ /^-.*$/) {
            paramName = substr(ARGV[argI], 2)
            paramWert = 0
        }
        if (paramName) {
            # if (paramName == "Namespace") Namespace = paramWert; else
            if (paramName == "debug") DEBUG = paramWert; else
        __error("Unknown argument: \""paramName "\" = \""paramWert"\"")
            ARGV[argI] = ""; continue
        }

        if (Directory_exists(ARGV[argI])) {
            Array_add(includeDirs, ARGV[argI])
            ARGV[argI] = ""; continue
        }

        if (!File_exists(ARGV[argI])) {
            __error("File doesn't exist: "ARGV[argI])
            ARGV[argI] = ""; continue
        }

        Array_add(origin, ARGV[argI])
        ARGV[argI] = ""
    }

    formatExt["h"] = "C"
    formatExt["c"] = "C"
    formatExt["inc"] = "C"

    Array_add(types, "void")
    Array_add(types, "unsigned")
    Array_add(types, "signed")
    Array_add(types, "char")
    Array_add(types, "short")
    Array_add(types, "int")
    Array_add(types, "long")
    Array_add(types, "float")
    Array_add(types, "double")

    for (n = 1; n <= origin["length"]; ++n) {
        fun = get_FileNameExt(origin[n])
        if (!(fun in formatExt)) {
            __error("No Format for FileName."fun)
            continue
        }
        fun = formatExt[fun]"_precompileFile"
        @fun(origin[n])
    }

if (DEBUG == 2 || DEBUG == 3 || DEBUG == 5) { __error("Defines: "); Array_error(defines) }
if (DEBUG == 6) { __error("Types: "); Array_error(types) }

    if (make in SYMTAB) @make()

    exit
}

function C_parseFile(fileName,    a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z) {
    if (Array_contains(parsed, fileName)) return 1
    Index_push("", "", "", "\n", "\n")
    if ( 0 < y = ( getline < fileName ) ) {
        C_parse($0, fileName)
    }
    if (y == -1) {
        __error("File doesn't exist: "fileName)
        Index_pop()
        return 0
    }
    close(fileName)
    Array_add(parsed, fileName)
    Index_pop()
    return 1
}

function C_precompileFile(fileName,    a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z) {
    if (!C_parseFile(fileName)) return
    C_precompile(fileName)
    #Array_add(precompiled, fileName)
}

function C_parse(code, fileName,     a, b, c, comments, continuation, d, directory, e, f, g, h, hash, i, j, k, l, m, n, name, o,
                                     p, q, r, s, string, t, u, v, w, was, x, y, z, zahl)
{
    if (fileName) {
        parsed[fileName]["name"] = fileName
        z = ++parsed[fileName]["length"]
    }
while (1) {
    continuation = 0
    Index_push(code, "", "", "\0", "\n")
    for (i = 1; i <= NF; ++i) {
        if (comments) {
            for ( ; i <= NF; ++i) {
                if ($i == "\\") {
                    if (i > 1) if (Index_prepend(i, fix, fix)) ++i
                    if (i == NF) break
                }
                if ($i == "/" && $(i + 1) == "*") {
                    ++comments
                    $(i++) = "*"
                    __error(fileName" Line "z": Comment in Comment /* /*")
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
        if ($i == "\n") {
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            z = ++parsed[fileName]["length"]; was = "linebreak"; hash = ""
            while (++i <= NF) {
                if ($i == "\n") continue
                if ($i ~ /[ \f\t\v]/) continue
                --i; break
            }
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "\\") {
            if ($(i + 1) == "n") {
                __error(fileName": Line "z": Stray \\n")
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
                        code = Index_pop()
                        if (0 < ( getline < fileName )) {
                            code = code $0
                            Index_push(code, "", "", "\0", "\n")
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
        __error(fileName": Line "z": Unknown Character "$i)
        Index_remove(i--)
    }
    if (comments && !continuation && hash ~ /^# /)
    {
        $NF = $NF"*/"
        Index_reset()
    }

    if (fileName) parsed[fileName][z] = String_concat(parsed[fileName][z], fix, $0)
    Index_pop()

if (DEBUG == 4 && !continuation) __error(parsed[fileName][z])

    if (fileName) {
    if (0 < ( getline < fileName )) {
        code = $0
        if (comments && !continuation && hash ~ /^# /)
        {
            --comments
            code = "/*"code
        }
        if (!continuation) {
            z = ++parsed[fileName]["length"]
            hash = ""
        }
        continue
    } }
    break
} }

function C_precompile(fileName,    a, b, c, d, e, expressions, f, fun, g, h, I, i, ifExpressions, j, k,
                                   l, leereZeilen, m, n, name, o, p, q, r, s, t, u, v, w, x, y, z)
{
    if (!Array_contains(defines, "__FILE__")) Array_add(defines, "__FILE__")
    if (!Array_contains(defines, "__LINE__")) Array_add(defines, "__LINE__")
    defines["__FILE__"]["body"] = "\""fileName"\""

    print "\n# 1 \""fileName"\""

    for (z = 1; z <= parsed[fileName]["length"]; ++z) {
        Index_push(parsed[fileName][z], fixFS, fix, "\0", "\n")
        Index_reset()

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

            w = Expression_evaluate($0)
            if (w !~ /^[0-9]+$/) x = 0; else x = w + 0

            f = Array_add(ifExpressions)
            ifExpressions[f]["if"] = $0
            if (x) ifExpressions[f]["do"] = 1
if (DEBUG == 2 || DEBUG == 3 || DEBUG == 5) __error(fileName" Line "z": (Level "f") if "$0"  == "w" "(ifExpressions[f]["do"] == 1 ? "okay" : "not okay"))
            NF = 0
        }
        else if ($2 == "elif") {
            Index_remove(1, 2)

            w = Expression_evaluate($0)
            if (w !~ /^[0-9]+$/) x = 0; else x = w + 0

            f = ifExpressions["length"]
            ifExpressions[f]["else if"] = $0
            if (ifExpressions[f]["do"] == 1) ifExpressions[f]["do"] = 2
            if (!ifExpressions[f]["do"] && x) {
                ifExpressions[f]["do"] = 1
            }
if (DEBUG == 2 || DEBUG == 3 || DEBUG == 5) __error(fileName" Line "z": (Level "f") else if "$0"  == "w" "(ifExpressions[f]["do"] == 1 ? "okay" : "not okay"))
            NF = 0
        }
        else if ($2 == "else") {
            f = ifExpressions["length"]
            ifExpressions[f]["else"] = 1
            if (ifExpressions[f]["do"] == 1) ifExpressions[f]["do"] = 2
            if (!ifExpressions[f]["do"]) {
                ifExpressions[f]["do"] = 1
            }
if (DEBUG == 2 || DEBUG == 3 || DEBUG == 5) __error(fileName" Line "z": (Level "f") else "(ifExpressions[f]["do"] == 1 ? "okay" : "not okay"))
            NF = 0
        }
        else if ($2 == "endif") {
            f = ifExpressions["length"]
if (DEBUG == 2 || DEBUG == 3 || DEBUG == 5) __error(fileName" Line "z": (Level "f") endif")
            Array_remove(ifExpressions, f)
            NF = 0
        } }

        for (f = 1; f <= ifExpressions["length"]; ++f) {
            if (ifExpressions[f]["do"] == 1) continue
            NF = 0; break
        }

        if ($1 == "#") {
        if ($2 == "include") {
            if ($3 ~ /^</) {
                m = substr($3, 2, length($3) - 2)
                for (n = 1; n <= includeDirs["length"]; ++n) {
                    o = Path_join(includeDirs[n], m)
                    if (File_exists(o)) {
if (DEBUG == 2 || DEBUG == 3 || DEBUG == 5) __error(fileName" Line "z": including "o)
                        C_precompileFile(o)
                        defines["__FILE__"]["body"] = "\""fileName"\""
                        defines["__LINE__"]["body"] = z

                        print "# "z" \""fileName"\""
                        break
                    }
                }
                if (n > includeDirs["length"]) __error("File doesn't exist: <"m">")
            }
            else {
                m = get_DirectoryName(fileName)
                m = Path_join(m, substr($3, 2, length($3) - 2))
                if (File_exists(m)) {
if (DEBUG == 2 || DEBUG == 3 || DEBUG == 5) __error(fileName" Line "z": including "m)
                    C_precompileFile(m)
                    defines["__FILE__"]["body"] = "\""fileName"\""
                    defines["__LINE__"]["body"] = z
                }
                else __error("File doesn't exist: \""m"\"")

                print "# "z" \""fileName"\""
            }
            NF = 0
        }
        if ($2 == "define") {
            name = $3
            if (Array_contains(defines, name)) {
                __error(fileName" Line "z": define "name" exists already")
            }
            else {
                Array_add(defines, name)
                Index_remove(1, 2, 3)
                # defines[name]["isFunction"] = 0
                if ($1 == "(") {
                    for (n = 2; n <= NF; ++n) {
                        if ($n ~ /^[[:alpha:]_][[:alpha:]_0-9]*$/) {
                            if (Array_contains(types, $n)) break
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

                m = ""; for (n = 1; n <= NF; ++n) {
                    # if ($n == "\\") continue
                    m = String_concat(m, fix, $n)
                }
                defines[name]["body"] = m

if (DEBUG == 2 || DEBUG == 3 || DEBUG == 5) {
Index_push(defines[name]["body"], "", ""); for (m = 1; m <= NF; ++m) if ($m == fix) $m = " "; rendered_defineBody = Index_pop()
if (defines[name]["isFunction"])
__error(fileName" Line "z": define "name" ("defines[name]["arguments"]["text"]")  "rendered_defineBody)
else
__error(fileName" Line "z": define "name"  "rendered_defineBody)
}
            }
            NF = 0
        }
        if ($2 == "undef") {
            if (!(f = Array_contains(defines, $3))) __error(fileName" Line "z": undef doesn't exist: "$3)
            else {
                Array_remove(defines, f)
                delete defines[$3]
if (DEBUG == 2 || DEBUG == 3 || DEBUG == 5) __error(fileName" Line "z": undef "$3)
            }
            NF = 0
        }
        # if (NF > 0) { $1 = "/*"$1; $NF = $NF"*/"; Index_reset() }
        }

        for (i = 1; i <= NF; ++i) {
            if (Array_contains(defines, $i)) {
                name = $i
if (DEBUG == 3) __debug(fileName" Line "z": applying "name)
                I = Index["length"]
                parsed[fileName]["z"] = z
                n = Define_apply(i, I, parsed[fileName])
                z = parsed[fileName]["z"]
                i += n - 1
            }
        }


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
            if ($i == "const" || $i == "struct" || $i == "union" || Array_contains(types, $i)) {
                if (expressions["length"] == 1 && expressions[1]["Type"] == "TypeDefine") { }
                else if (expressions["length"] > 0) {
                    # do you need semikolon?
                }
                e = ++expressions["length"]
                expressions[e]["Type"] = "Type"
                name = ""; fun = ""
#                if (Array_contains(types, $i)) name = $i
                k = 0; o = 0; for (n = i; n <= NF; ++n) {
                    if (name && !fun && !o && $n == "(") {
                        ++k
                        # name = String_concat(name, " ", $n)
                        if (i != n) { $i = String_concat($i, " ", $n); $n = "" } continue
                    }
                    if ($n == "const") {
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
                        if ($(n + 1) !~ /^[[:alpha:]_][[:alpha:]_0-9]*$/) { __error(fileName" Line "z": "$n" without name"); break }
                        name = $n" "$(n + 1)
                        if (i != n) { $i = String_concat($i, " ", $n); $n = "" }
                        $i = String_concat($i, " ", $(n + 1)); $(++n) = ""
                        continue
                    }
                    if (!name && Array_contains(types, $n)) {
                        name = $n; if (i != n) { $i = String_concat($i, " ", $n); $n = ""} continue
                    }
                    break
                }
                Index_reset()
                if (name) if (!Array_contains(types, name)) Array_add(types, name)
                if (expressions["length"] == 2 && expressions[1]["Type"] == "TypeDefine") {
                    if (fun) {
                        if (!Array_contains(types, fun)) Array_add(types, fun)
                    }
                    else {
                        if ($(i + 1) !~ /^[[:alpha:]_][[:alpha:]_0-9]*$/) __error(fileName" Line "z": typedef without name")
                        else { ++i; if (!Array_contains(types, $i)) Array_add(types, $i) }
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

if (DEBUG) {
        if (NF == 0) ++leereZeilen
        else {
            if (leereZeilen <= 3) for (h = 1; h <= leereZeilen; ++h) print ""
            else { print ""; print ""; print "# "z" \""fileName"\"" }
            leereZeilen = 0
            print
        }
}

        precompiled[fileName][z] = Index_pop()

if (!DEBUG) {
        Index_push(precompiled[fileName][z], fixFS, " ", "\0", "\n"); Index_reset()
        if (NF == 0) ++leereZeilen
        else {
            if (leereZeilen <= 3) for (h = 1; h <= leereZeilen; ++h) print ""
            else { print ""; print ""; print "# "z" \""fileName"\"" }
            leereZeilen = 0
            print
        }
        Index_pop()
}

    }
    precompiled[fileName]["length"] = parsed[fileName]["length"]
}

function gcc_precompile(    h, i, j, k, l, m, n, o) {

    i = ".preprocess.C.gcc.c"
    print "/* Gemeinfrei */" > i

    o = ".preprocess.C.gcc...pre.c"
    # system("gcc -std=c11 -E "i"  > "o)
    system("gcc -std=c11 -dM -E "i" | sort > "o)

    return o
}
