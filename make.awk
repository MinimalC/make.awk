#!/usr/bin/awk -f
# Gemeinfrei. Public Domain.
# 2020 Hans Riehm

@include "../make.awk/meta.awk"
#include "../make.awk/make.awk"

BEGIN {
    FS="";OFS="";RS="\0";ORS="\n"
    fixFS = @/[\x01 \f\t\v]*[\x01]/
    fix = "\x01"

    make = "make_precompile"

    if (ARGV_length() == 0) { __error("Usage: make.awk include Program.c"); exit 1 }

    Array_add(includeDirs, "/usr/include/")
    Array_add(includeDirs, "/usr/include/x86_64-linux-gnu/")
    Array_add(includeDirs, "/usr/lib/gcc/x86_64-linux-gnu/7/include/")

    target = gcc_precompile()
    Array_add(origin, target)

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

    for (n = 1; n <= origin["length"]; ++n) {
        fun = get_FileNameExt(origin[n])
        if (!(fun in formatExt)) {
            __error("No Format for FileName."fun)
            continue
        }
        fun = formatExt[fun]"_precompileFile"
        if (SYMTAB[fun]) {
            __error("No function defined: "fun)
            continue
        }
        @fun(origin[n])
    }

    if (make in SYMTAB) @make()

    exit
}

function C_parseFile(fileName,    a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z) {
    if (Array_contains(parsed, fileName)) return 1
    Index_push("", "", "", "\0", "\n")
    if ( -1 == ( getline < fileName ) ) {
        __error("File doesn't exist: "fileName)
        Index_pop()
        return 0
    }
    close(fileName)
    parsed[fileName] = C_parse($0, fileName)
    Array_add(parsed, fileName)
    Index_pop()
    return 1
}

function C_precompileFile(fileName,    a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z) {
    if (!C_parseFile(fileName)) return
    precompiled[fileName] = C_precompile(parsed[fileName], fileName)
    Array_add(precompiled, fileName)
}

function C_parse(code, fileName,    a, b, c, comments, d, directory, e, f, g, h, hash, i, j, k, l, m, n, name, o,
                                    p, q, r, s, string, t, u, v, w, was, x, y, z, zahl)
{
    directory = get_DirectoryName(fileName)

    z = 1

    Index_push(code, "", "", "\0", "\n")
    for (i = 1; i <= NF; ++i) {
        if ($i == "\r") {
            Index_remove(i--)
            continue
        }
        if ($i == "\n") {
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            ++z; was = "linebreak"; hash = ""
            while (++i <= NF) {
                if ($i == "\n") continue
                if ($i ~ /[ \f\t\v]/) continue
                --i; break
            }
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "\\") {
            if ($(i + 1) == "\r") Index_remove(i + 1)
            if ($(i + 1) == "\n") {
                if (i > 1) if (Index_prepend(i, fix, fix)) ++i
                ++i; ++z; was = "continuation"
                if (i < NF) if (Index_append(i, fix, fix)) ++i
                continue
            }
            __error(fileName": Line "z": Stray \\")
            Index_remove(i--)
            continue
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
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            was = "#"; hash = "#"
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
                    string = string"\\"$(i + 1)
                    ++i; continue
                }
                if ($i == "\"") break
                string = string $i
            }
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            #if (hash == "# include") {
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
                    string = string"\\"$(i + 1)
                    ++i; continue
                }
                if ($i == "'") break
                string = string $i
            }
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
        if ($i == "/") {
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            if ($(i + 1) == "*") {
                ++i; was = "comment"
                while (++i <= NF) {
                    if ($i == "/" && $(i + 1) == "*") {
                        $(i++) = "*"
                        ++comments
                        __error(fileName" Line "z": Comment in Comment /* /*")
                        continue
                    }
                    if ($i == "*" && $(i + 1) == "/") {
                        if (comments) {
                            --comments
                            $(++i) = "*"
                            continue
                        } ++i
                        break
                    }
                    if ($i == "\r") { Index_remove(i--); continue }
                    if ($i == "\n" && hash ~ /^#/)
                    {
                        $i = "*/\n/*"
                        i += 4
                        hash = ""
                        continue
                    }
                }
                if (i < NF) if (Index_append(i, fix, fix)) ++i
                continue
            }
            if ($(i + 1) == "/") {
                ++i; was = "comment"
                while (++i <= NF) if ($i == "\n") break
                --i; continue
            }
            was = "/"
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
        if ($i == "<") {
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            if (hash == "# include") {
                string = ""
                while (++i <= NF) {
                    if ($i == "\\") {
                        string = string"\\"$(i + 1)
                        ++i; continue
                    }
                    if ($i == ">") break
                    string = string $i
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
if (DEBUG == 2) __error($0)
    return Index_pop()
}

function C_precompile(code,    a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z) {

    Index_push(code, fixFS, fix, "\0", "\n")
    Index_reset()

    for (i = 1; i <= NF; ++i) {
        if ($i ~ /^\/\*/) { $i = ""; continue }
        if ($i ~ /^\/\//) { $i = ""; continue }
    }
    Index_reset()

    print

    code = Index_pop()
#    Index_push(code, fixFS, " ", "\0", "\n"); Index_reset(); print; Index_pop()
    return code
}

function gcc_precompile(    h, i, j, k, l, m, n, o) {

    i = ".preprocess.C.gcc.c"
    print "/* Gemeinfrei */" > i

    o = ".preprocess.C.gcc...pre.c"
    system("gcc -std=c11 -E "i"  > "o)
    system("gcc -std=c11 -dM -E "i" | sort >> "o)

    return o
}
