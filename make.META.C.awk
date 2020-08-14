#!/usr/bin/awk -f
# Gemeinfrei.
# 2020 Hans Riehm

@include "meta.awk"

function usage() {
    print "Usage: make.ISO_C.awk Program.c">"/dev/stderr"
}

BEGIN {
    make = "make_print"

    if (ARGV_length() == 0) { usage(); exit 1 }

    includeDirs["length"] = 0
    fixFS = @/[ \x01]*[\x01]/
    fix = "\x01"

    Array_add(includeDirs, "/usr/include/")
    Array_add(includeDirs, "/usr/include/x86_64-linux-gnu/")
    Array_add(includeDirs, "/usr/lib/gcc/x86_64-linux-gnu/7/include/")

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
        print "Unknown argument: \""paramName "\" = \""paramWert"\"">"/dev/stderr"
            ARGV[argI] = ""; continue
        }

        if (Directory_exists(ARGV[argI])) {
            Array_add(includeDirs, ARGV[argI])
            ARGV[argI] = ""; continue
        }

        if (!File_exists(ARGV[argI])) {
            print "File doesn't exist: "ARGV[argI]>"/dev/stderr"
            ARGV[argI] = ""; continue
        }
        fileName = get_FileName(ARGV[argI])
        directory = get_DirectoryName(ARGV[argI])

        if (fileName ~ /\.h$/) { }
        else if (fileName ~ /\.c$/) { }
        else if (fileName ~ /\.inc$/) { }
        else {
            error = "Unknown inputType format: "fileName
            ARGV[argI] = ""; continue
        }
    }

    n = 0
    for (argI = 1; argI <= ARGV_length(); ++argI) {
        if (ARGV[argI])
            origin[++n] = ARGV[argI]
    }
    origin["length"] = n

    targetDefines = gcc_preprocess()
    ARGV_add(targetDefines)
}

BEGINFILE {

    if (FILENAME == "-") { usage(); nextfile }
    if (ERRNO) { print "(BEGINFILE) File doesn't exist: "FILENAME>"/dev/stderr"; nextfile }

    FileName = get_FileName(FILENAME)
    Directory = get_DirectoryName(FILENAME)

    inputI = ++input["length"]
    input[inputI]["FILENAME"] = FILENAME
    #input[inputI]["FileName"] = FileName
    #input[inputI]["Directory"] = Directory

    leereZeilen = 0
    z = 0
    inputType = ""
    hash = ""
    continuation = 0

    if (!Array_contains(includes, FILENAME))
        Array_add(includes, FILENAME)

    #FS=" "
    #OFS=" "
    RS="\n"
    #ORS="\n"

#    if (DEBUG) print "\n"FILENAME
}

NF > 0 {  # PreProcess: read what you have, in C

    ++z
    leereZeilen = 0
    inputZ = ++input[inputI]["length"]
    hash = ""
    continuation = 0

    Index_push($0, "", "")
    i = 1
    do {
        if (i == 1 && continuation) {
            if (Index_prepend(i, fix, fix)) ++i
            continuation = 0
            continue
        }
        if (inputType == "comment") {
            if ($i == "/" && $(i + 1) == "*") {
                $(i++) = "*"
                ++comments
                print FILENAME" Line "z": Comment in Comment /* /*">"/dev/stderr"
                continue
            }
            if ($i == "*" && $(i + 1) == "/") {
                if (comments) {
                    --comments
                    $(++i) = "*"
                    continue
                }
                ++i
                inputType = ""
                if (i != NF) if (Index_append(i, fix, fix)) ++i
                continue
            }
            if (i == NF && $i != "\\" && hash ~ /^#/) {
                if (i != 1) if (Index_prepend(i, fix, fix)) ++i
                Index_append(i, "\\"); ++i
                print FILENAME" Line "z": Line Continuation \\ in Comment">"/dev/stderr"
                input[inputI][inputZ] = input[inputI][inputZ] $0
                if (DEBUG) { for (h = 1; h <= NF; ++h) { if ($h == fix) printf "|"; else printf "%s ", $h } printf "" }
                continuation = 1; getline; ++z; i = 0; continue
            }
            continue
        }
        if (inputType == "string") {
            if (i == NF && $i == "\\") {
                if (i != 1) if (Index_prepend(i, fix, fix)) ++i
                print FILENAME" Line "z": Line Continuation \\ in String">"/dev/stderr"
                input[inputI][inputZ] = input[inputI][inputZ] $0
                if (DEBUG) { for (h = 1; h <= NF; ++h) { if ($h == fix) printf "|"; else printf "%s ", $h } printf "" }
                continuation = 1; getline; ++z; i = 0; continue
            }
            if ($i == "\\" && $(i + 1) == "\"") { ++i; continue }
            if ($i == "\"") {
                inputType = ""
                if (hash == "# include") {
                    n = Path_join(Directory, string)
                    if (File_exists(n)) {
                        List_insertBefore(includes, FILENAME, n)
                        ARGV_add(n)
                    }
                    else print "(preprocess) File doesn't exist: \""n"\"">"/dev/stderr"
                }
                hash = ""
                if (i != NF) if (Index_append(i, fix, fix)) ++i
            }
            else string = string $i
            continue
        }
        if (inputType == "character") {
            if (i == NF && $i != "'") {
                Index_append(i, "'")
                Index_reset(); ++i
            }
            if ($i == "\\") {
                if ($(i + 1) == "'") { ++i; continue }
            }
            if ($i == "'") {
                inputType = ""
                if (i != NF) if (Index_append(i, fix, fix)) ++i
            }
            continue
        }
        if (inputType == "include string") {
            if (i == NF && $i == "\\") {
                if (i != 1) if (Index_prepend(i, fix, fix)) ++i
                print FILENAME" Line "z": Line Continuation \\ in #include <String>">"/dev/stderr"
                input[inputI][inputZ] = input[inputI][inputZ] $0
                if (DEBUG) { for (h = 1; h <= NF; ++h) { if ($h == fix) printf "|"; else printf "%s ", $h } printf "" }
                continuation = 1; getline; ++z; i = 0; continue
            }
            if ($i == ">") {
                inputType = ""
                for (d = 1; d <= includeDirs["length"]; ++d) {
                    n = Path_join(includeDirs[d], includeString)
                    if (File_exists(n)) {
                        List_insertBefore(includes, FILENAME, n)
                        ARGV_add(n)
                        break
                    }
                }
                if (d > includeDirs["length"]) print "(preprocess) File doesn't exist: <"includeString">">"/dev/stderr"
                hash = ""
                if (i != NF) if (Index_append(i, fix, fix)) ++i
                break
            }
            else includeString = includeString $i
            continue
        }
        if ($i == fix) continue
        if ($i ~ /[ \b\f\n\r\t\v]/) {
            $i = " "
            # mache, zähle LeerZeichen
            for (n = i; ++n <= NF; ) {
                if ($n ~ /[ \b\f\n\r\t\v]/) { $n = " "; continue }
                break
            } --n
            if (i == 1 || n == NF) {
                # eliminiere LeerZeichen
                for (n = i; ++n <= NF; ) {
                    if ($n ~ /[ \b\f\n\r\t\v]/) { Index_remove(n--); continue }
                    break
                } --n

                # remove
                Index_remove(i--)
            }
            continue
        }
        if ($i == "\\") {
            if (i != NF) {
                Index_remove(i--); continue
            }
            if (i != 1) if (Index_prepend(i, fix, fix)) ++i
            print FILENAME" Line "z": Line Continuation \\">"/dev/stderr"
            input[inputI][inputZ] = input[inputI][inputZ] $0
            if (DEBUG) { for (h = 1; h <= NF; ++h) { if ($h == fix) printf "|"; else printf "%s ", $h } printf "" }
            continuation = 1; getline; ++z; i = 0; continue
        }
        if (i == 1 && $i == "#") {
            hash = "#"
            if (i != NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "#") {
            if (i != 1) if (Index_prepend(i, fix, fix)) ++i
            if ($(i + 1) == "#") {
                ++i
                if (i != NF) if (Index_append(i, fix, fix)) ++i
                continue
            }
            if (i != NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "\"") {
            if (i != 1) if (Index_prepend(i, fix, fix)) ++i
            inputType = "string"
            string = ""
            continue
        }
        if ( $i == "'" ) {
            if (i != 1) if (Index_prepend(i, fix, fix)) ++i
            inputType = "character"
            continue
        }
        if ($i == "*") {
            if ($(i + 1) == "/") { Index_remove(i, i + 1); --i; continue }
            if (i != 1) if (Index_prepend(i, fix, fix)) ++i
            if ($(i + 1) == "=") ++i
            if (i != NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "/") {
            if (i != 1) if (Index_prepend(i, fix, fix)) ++i
            if ($(i + 1) == "*") {
                ++i; inputType = "comment"
                continue
            }
            if ($(i + 1) == "/") break
            if ($(i + 1) == "=") ++i
            if (i != NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "+") {
            if (i != 1) if (Index_prepend(i, fix, fix)) ++i
            if ($(i + 1) == "+") ++i
            else if ($(i + 1) == "=") ++i
            if (i != NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "-") {
            if (i != 1) if (Index_prepend(i, fix, fix)) ++i
            if ($(i + 1) == ">") ++i
            else if ($(i + 1) == "-") ++i
            else if ($(i + 1) == "=") ++i
            if (i != NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "=") {
            if (i != 1) if (Index_prepend(i, fix, fix)) ++i
            if ($(i + 1) == "=") ++i
            if (i != NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "%" || $i == "^") {
            if (i != 1) if (Index_prepend(i, fix, fix)) ++i
            if ($(i + 1) == "=") ++i
            if (i != NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "&") {
            if (i != 1) if (Index_prepend(i, fix, fix)) ++i
            if ($(i + 1) == "&") ++i
            else if ($(i + 1) == "=") ++i
            if (i != NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "|") {
            if (i != 1) if (Index_prepend(i, fix, fix)) ++i
            if ($(i + 1) == "|") ++i
            else if ($(i + 1) == "=") ++i
            if (i != NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "(" || $i == "{" || $i == "[") {
            if (i != 1) if (Index_prepend(i, fix, fix)) ++i
            if (i != NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == ")" || $i == "}" || $i == "]") {
            if (i != 1) if (Index_prepend(i, fix, fix)) ++i
            if (i != NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "<") {
            if (i != 1) if (Index_prepend(i, fix, fix)) ++i
            if (hash == "# include") {
                inputType = "include string"
                includeString = ""
                continue
            }
            if ($(i + 1) == "<") ++i
            if ($(i + 1) == "=") ++i
            if (i != NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == ">") {
            if (i != 1) if (Index_prepend(i, fix, fix)) ++i
            if ($(i + 1) == ">") ++i
            if ($(i + 1) == "=") ++i
            if (i != NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "!") {
            if (i != 1) if (Index_prepend(i, fix, fix)) ++i
            if ($(i + 1) == "=") ++i
            if (i != NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "," || $i == ";" || $i == "?" || $i == ":" || $i == "~") {
            if (i != 1) if (Index_prepend(i, fix, fix)) ++i
            if (i != NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i ~ /[0-9]/) {
            if (i != 1) if (Index_prepend(i, fix, fix)) ++i
            if ($i == "0" && $(i + 1) == "x") {
                i += 2
                zahl = "0x"
                for (; ++i <= NF; ) {
                    if ($i ~ /[0-9a-fA-F]/) { zahl = zahl $i; continue }
                    break
                } --i
                for (; ++i <= NF; ) {
                    if ($i ~ /[ulUL]/) { zahl = zahl $i; continue }
                    break
                } --i
                if (i != NF) if (Index_append(i, fix, fix)) ++i
                if (hash == "#") hash = "# "zahl
                continue
            }
            zahl = $i
            for (; ++i <= NF; ) {
                if ($i ~ /[0-9]/) { zahl = zahl $i; continue }
                break
            } --i
            if ($(i + 1) ~ /[uUlL]/) {
                ++i; zahl = zahl $i
                for (; ++i <= NF; ) {
                    if ($i ~ /[uUlL]/) { zahl = zahl $i; continue }
                    break
                } --i
            }
            else {
                if ($(i + 1) == ".") {
                    ++i; zahl = zahl $i
                    # lies das Fragment
                    for (; ++i <= NF; ) {
                        if ($i ~ /[0-9]/) { zahl = zahl $i; continue }
                        break
                    } --i
                }
                if ($(i + 1) ~ /[eE]/) {
                    ++i; zahl = zahl $i
                    if ($(i + 1) ~ /[+-]/) { ++i; zahl = zahl $i }
                    # lies den Exponent
                    for (; ++i <= NF; ) {
                        if ($i ~ /[0-9]/) { zahl = zahl $i; continue }
                        break
                    } --i
                }
            }
            if (i != NF) if (Index_append(i, fix, fix)) ++i
            if (hash == "#") hash = "# "zahl
            continue
        }
        if ( $i == "." ) {
            if (i != 1) if (Index_prepend(i, fix, fix)) ++i
            if ( $(i + 1) == "." && $(i + 2) == "." ) i += 2
            if (i != NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i ~ /[[:alpha:]_]/) {
            if (i != 1) if (Index_prepend(i, fix, fix)) ++i
            # lies einen Namen
            name = $i
            for (; ++i <= NF; ) {
                if ($i ~ /[[:alpha:]_0-9]/) { name = name $i; continue }
                break
            } --i
            if (i != NF) if (Index_append(i, fix, fix)) ++i
            if (hash == "#") { hash = "# "name }
            continue
        }

        # remove
        Index_remove(i--)

    } while (++i <= NF)

    input[inputI][inputZ] = input[inputI][inputZ] $0

    if (DEBUG) { for (h = 1; h <= NF; ++h) { if ($h == fix) printf "|"; else printf "%s ", $h } print "" }

    Index_pop()
}

NF == 0 {
    if (leereZeilen++ < 2) {
        ++z

        inputZ = ++input[inputI]["length"]
        input[inputI][inputZ] = ""
    }
}

ENDFILE {

}

END {

__debug( "includeDirs:")
 Array_debug(includeDirs)

__debug( "includes:")
 Array_debug(includes)

    #Array_add(defines, "__STDC__")
    #defines["__STDC__"]["body"] = "1"
    #Array_add(defines, "__GNUC__")
    #defines["__GNUC__"]["body"] = "7"
    #Array_add(defines, "__GNUC_MINOR__")
    #defines["__GNUC_MINOR__"]["body"] = "5"
    #Array_add(defines, "__WORDSIZE")
    #defines["__WORDSIZE"]["body"] = "64"
    #Array_add(defines, "__USER_LABEL_PREFIX__")
    #defines["__USER_LABEL_PREFIX__"]["body"] = ""

    #read_gcc_preprocess_defines(defines)

    precompile(targetDefines, defines)

    for (argI = 1; argI <= origin["length"]; ++argI)
        if (origin[argI])
            precompile(origin[argI], defines)

#    if (!error) @make()
}

function gcc_preprocess(    fileIn, fileOut) {

    fileIn = ".preprocess.C.gcc.c"
    print "/* Gemeinfrei */" > fileIn
    close(fileIn)

    fileOut = ".preprocess.C.gcc...pre.c"
    #system("gcc -std=c11 -nostdinc -E "fileIn"  > "fileOut)
    system("gcc -std=c11 -nostdinc -dM -E "fileIn" | sort > "fileOut)

    return fileOut
}

function read_gcc_preprocess_defines(defines,    fileIn, line, name) {
    gcc_preprocess()
    fileIn = ".preprocess.C.gcc...pre.c"
    while (0 < (getline line < fileIn)) {
        Index_push(line, FS, OFS)
        if ($1 == "#define") {
            name = $2
            Index_remove(1, 2)
            Array_add(defines, name)
            defines[name]["body"] = $0
        }
        Index_pop()
    }
}

function precompile(fileName, defines,    a, argumentI, arguments, b, c, count, d, defineBody, e, f, g, h,
                    i, I, ifExpressions, inputType, j, k, l, m, n, name,
                    o, p, q, r, resultI, resultZ, s, t, u, v, w, x, y, z, zeile)
{
    ifExpressions["length"] = 0

    for (e = 1; e <= input["length"]; ++e)
        if (input[e]["FILENAME"] == fileName ) break
    if (e > input["length"]) { print "(precompile) File doesn't exist: "fileName>"/dev/stderr"; return }

    resultI = ++result["length"]
#    result[resultI]["FILENAME"] = input[e]["FILENAME"]

# DEBUG
#resultZ = ++result[resultI]["length"]
#result[resultI][resultZ] = "\n# 1 \""input[e]["FILENAME"]"\""
print "\n/* 1 \""input[e]["FILENAME"]"\" */"

    inputType = ""

    for (z = 1; z <= input[e]["length"]; ++z) {
        Index_push(input[e][z], fixFS, fix)
        I = Index["length"]

    i = 0
    while (++i) {
        if (i > NF) {
#            if ((l = Index["length"]) > I) {
#                i = Index[l]["i"]
#                # name = Index[l]["name"]
#                n = NF
#                $i = Index_pop()
#                Index_reset()
#                i += n - 1
#                continue
#            }
            break
        }

#        if ($i ~ /^[ ]*$/) continue

        if (inputType == "comment") {
            if ($i ~ /\*\/$/) inputType = ""
            Index_remove(i--)
            continue
        }
        if ($i ~ /^\/\*/) {
            inputType = "comment"
            if ($i ~ /\*\/$/) inputType = ""
            Index_remove(i--)
            continue
        }
        if ($i ~ /^\/\//) {
            NF = i - 1; break
        }

        if (i == 1 && $1 == "#") {
        if ($2 == "ifdef") {
            $2 = "if"
            for (n = 3; n <= NF; ++n) {
                if ($n ~ /^[[:alpha:]_][[:alpha:]_0-9]*$/) {
                    Index_prepend(n, "defined "); n += 2
                }
            }
        }
        if ($2 == "ifndef") {
            $2 = "if"
            for (n = 3; n <= NF; ++n) {
                if ($n ~ /^[[:alpha:]_][[:alpha:]_0-9]*$/) {
                    Index_prepend(n, "! defined"); n += 2
                }
            }
        }
        if ($2 == "if") {
            m = ""; c = 0
            for (n = 3; n <= NF; ++n) {
                if ($n ~ /^\/\*/) ++c
                if ($n ~ /\*\/$/) { if (c) --c; continue }
                if (c) continue
                m = String_concat(m, " ", $n)
            }
            x = Expression_evaluate(m, defines, "")
            if (x !~ /^[0-9]+$/) x = 0; else x = x + 0
            f = Array_add(ifExpressions)
__error(input[e]["FILENAME"]" Line "z": "f" if "m"  == "x)
            ifExpressions[f]["if"] = m
            if (x) ifExpressions[f]["do"] = 1
            NF = 0; break
        }
        if ($2 == "elif") {
            m = ""; c = 0
            for (n = 3; n <= NF; ++n) {
                if ($n ~ /^\/\*/) ++c
                if ($n ~ /\*\/$/) { if (c) --c; continue }
                if (c) continue
                m = String_concat(m, " ", $n)
            }
            f = ifExpressions["length"]
            x = Expression_evaluate(m, defines, "")
            if (x !~ /^[0-9]+$/) x = 0; else x = x + 0
            ifExpressions[f]["else if"] = m
            if (ifExpressions[f]["do"] == 1) ifExpressions[f]["do"] = 2
            if (!ifExpressions[f]["do"] && x) {
__error(input[e]["FILENAME"]" Line "z": "f" else if "m"  == "x)
                ifExpressions[f]["do"] = 1
            }
            NF = 0; break
        }
        if ($2 == "else") {
            f = ifExpressions["length"]
            ifExpressions[f]["else"] = 1
            if (ifExpressions[f]["do"] == 1) ifExpressions[f]["do"] = 2
            if (!ifExpressions[f]["do"]) {
__error(input[e]["FILENAME"]" Line "z": "f" else")
                ifExpressions[f]["do"] = 1
            }
            NF = 0; break
        }
        if ($2 == "endif") {
            f = ifExpressions["length"]
__error(input[e]["FILENAME"]" Line "z": "f" endif")
            Array_remove(ifExpressions, f)
            NF = 0; break
        } }

        for (f = 1; f <= ifExpressions["length"]; ++f) {
            if (ifExpressions[f]["do"] == 1) continue
            NF = 0; break
        }
        if (NF == 0) break

        if (i == 1 && $1 == "#") {
        if ($2 == "include") {
            if ($3 ~ /^</) {
                m = substr($3, 2, length($3) - 2)
                for (n = 1; n <= includeDirs["length"]; ++n) {
                    name = Path_join(includeDirs[n], m)
                    if (File_exists(name)) {
__error(input[e]["FILENAME"]" Line "z": including "name)
                        precompile(name, defines)

                        print "/* "z + 1" \""input[e]["FILENAME"]"\" */"
                        break
                    }
                }
                if (n > includeDirs["length"]) print "(precompile) File doesn't exist: <"m">">"/dev/stderr"
            }
            else {
                m = get_DirectoryName(input[e]["FILENAME"])
                m = Path_join(m, substr($3, 2, length($3) - 2))
__error(input[e]["FILENAME"]" Line "z": including "m)
                if (File_exists(m))
                    precompile(m, defines)
                else
                    print "(precompile) File doesn't exist: \""m"\"">"/dev/stderr"

                print "/* "z + 1" \""input[e]["FILENAME"]"\" */"
            }
            NF = 0; break
        }
        if ($2 == "define") {
            name = $3
            if (f = Array_contains(defines, name)) {
                print "(precompile) "input[e]["FILENAME"]" Line "z": define already exists: "name>"/dev/stderr"
                NF = 0; break
            }
            f = Array_add(defines, name)
            Index_remove(1, 2, 3)
            if ($1 == "(") {
                for (n = 2; n <= NF; ++n) {
                    if ($n ~ /^[[:alpha:]_][[:alpha:]_0-9]*$/) continue
                    if ($n == ",") continue
                  # if ($n == "{") break
                    if ($n == ")") break
                    break
                }
                if ($n == ")") { # n < NF
                    m = ""; for (o = 2; o < n; ++o) {
                        m = String_concat(m, " ", $o)
                        if ($o == ",") continue
                        argumentI = ++defines[name]["function"]["length"]
                        defines[name]["function"][argumentI] = $o
                    }
                    defines[name]["function"]["text"] = m
                    defines[name]["isFunctional"] = 1
                    Index_removeRange(1, n)
                }
            }

            m = ""; for (n = 1; n <= NF; ++n) m = String_concat(m, fix, $n)
            defines[name]["body"] = m

if (defines[name]["function"]["length"])
__error(input[e]["FILENAME"]" Line "z": define "name" "defines[name]["function"]["length"]"("defines[name]["function"]["text"]") "defines[name]["body"])
else
__error(input[e]["FILENAME"]" Line "z": define "name" "defines[name]["body"])

            NF = 0; break
        }
        if ($2 == "undef") {
            if (!(f = Array_contains(defines, $3))) {
                print "(precompile) "input[e]["FILENAME"]" Line "z": undef doesn't exist: "$3>"/dev/stderr"
            } else {
                Array_remove(defines, f)
                delete defines[$3]
            }
            NF = 0; break
        }
            $1 = "/*"; $NF = $NF fix "*/"; Index_reset()
            break
        }

        # Evaluate AWA
        if (Array_contains(defines, $i)) {
            # define SOMETHING SOMETHING
            l = Index["length"]
            for (n = I + 1; n <= l; ++n)
                if ($i == Index[n]["name"]) break
            if (n <= l) {
                print input[e]["FILENAME"]" Line "z": self-referencing define "$i" "$i>"/dev/stderr"
                continue
            }
            #define name ( arg1 , arg2 ) body
            name = $i
            defineBody = defines[name]["body"]
            Array_clear(arguments)
            if (defines[name]["isFunctional"]) {
                o = i; m = ""; p = 0
                while (++o) {
                    if (o > NF) {
#                        if ((l = Index["length"]) > I) {
#                            i = o = Index[l]["i"]
#                            # name = Index[l]["name"]
#                            n = NF
#                            $o = Index_pop()
#                            Index_reset()
#                            o += n - 1
#                            continue
#                        }
                        if ((l = Index["length"]) == I) {
                            if (++z <= input[e]["length"]) {
                                $0 = $0 fix input[e][z]
                                --o; continue
                            }
                        }
                        break
                    }
                    if (o == i + 1) continue
                    if (!p && $o == ",") {
                        Array_add(arguments, m)
                        m = ""
                        continue
                    }
                    if ($o == "(" || $o == "{") ++p
                    if ($o == ")" || $o == "}") {
                        if (p) --p
                        else { if (m != "") Array_add(arguments, m); break }
                    }
                    m = String_concat(m, fix, $o)
                }
__error("real arguments length: "defines[name]["function"]["length"])
Array_error(arguments)
__error($0)
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
                print input[e]["FILENAME"]" Line "z": using define "name" without body">"/dev/stderr"
                Index_remove(i--)
                continue
            }
if (defines[name]["function"]["length"]) {
__error(input[e]["FILENAME"]" Line "z": using "name" "defines[name]["function"]["length"]"( "defines[name]["function"]["text"]" ) "defineBody)
# Array_error(arguments)
}
else
__error(input[e]["FILENAME"]" Line "z": using "name" "defineBody)

            Index_push(defineBody, fixFS, fix)
            for (o = 1; o <= NF; ++o) {
                if ($o == "\\") { $o = ""; continue }
                if ($o == "##") {
                    $(o + 1) = $(o - 1) $(o + 1)
                   $(o - 1) = ""; $o = ""
                    ++o; continue
                }
                if ($o == "#") {
                    if ($(o + 1) !~ /^[[:alpha:]_][[:alpha:]_0-9]*$/) {
                        $o = "\"\""
                    }
                    else {
                        $(o + 1) = "\""$(o + 1)"\""
                        $o = ""
                        ++o
                    }
                    continue
                }
            }
            defineBody = Index_pop()

            $i = defineBody
            Index_reset()
            --i; continue

#            Index_push(defineBody, fixFS, fix)
#            l = Index["length"]
#            Index[l]["name"] = name
#            Index[l]["i"] = i
#            i = 0; continue
        }

    }
        if (NF > 0) {
            if (DEBUG) {
                for (h = 1; h <= NF; ++h) { if ($h ~ /^[ ]*$/ || $h == "\\") ; else printf "(%d)%s", h, $h } print ""
            }
            else {
                for (h = 1; h <= NF; ++h) { if ($h ~ /^[ ]*$/ || $h == "\\") ; else printf "%s ", $h } print ""
            }
            # print
            # if ($0 !~ /^[ \x01]*$/)
            # resultZ = ++result[resultI]["length"]
            # result[resultI][resultZ] = $0
        }

        Index_pop()
    }
}

function make_printInput(    a, b, c, d, e, f, g, h, i, j, k, l, x, y, z) {

    for (d = 1; d <= includes["length"]; ++d) {
        for (e = 1; e <= input["length"]; ++e)
            if (input[e]["FILENAME"] == includes[d]) break
        if (e > input["length"]) continue

    if (DEBUG) { print ""; print input[e]["FILENAME"] }

    for (z = 1; z <= input[e]["length"]; ++z) {
        Index_push(input[e][z], fixFS, fix)

        if (DEBUG) {
            for (h = 1; h <= NF; ++h) { if ($h ~ /^[ ]*$/) printf "%s", $h; else printf "(%d)%s", h, $h } print ""
        }
        else {
            for (h = 1; h <= NF; ++h) {  printf "%s", $h } print ""
        }

        Index_pop()
    } }
}

function make_print(    a, b, c, d, e, f, g, h, i, j, k, l, x, y, z) {

    for (e = 1; e <= result["length"]; ++e) {

    if (DEBUG) { print ""; print result[e]["FILENAME"] }

    for (z = 1; z <= result[e]["length"]; ++z) {
        Index_push(result[e][z], fixFS, fix)

        if (DEBUG) {
            for (h = 1; h <= NF; ++h) { if ($h ~ /^[ ]*$/) ; else printf "(%d)%s", h, $h } print ""
        }
        else {
            for (h = 1; h <= NF; ++h) { if ($h ~ /^[ ]*$/) ; else printf "%s ", $h } print ""
        }

        Index_pop()
    } }

}

