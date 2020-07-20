#!/usr/bin/awk -f
# Gemeinfrei.
# 2020 Hans Riehm

@include "meta.awk"

function usage() {
    print "fix make.ISO_C.awk Program.c">"/dev/stderr"
}

BEGIN {
    if (ARGC == 1) { usage(); exit 1 }

    make = "make_print"
    includeDirs["length"] = 0
    fixFS = @/[ \x01]*[\x01]/
    fix = "\x01"

    Array_add(includeDirs, "/usr/include/")

    for (argI = 1; argI < ARGC; ++argI) {
        # argL = length(ARGV[argI])

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
}

NF > 0 {  # PreProcess: read what you have, in C

    ++z
    leereZeilen = 0
    inputZ = ++input[inputI]["length"]
    hash = ""

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
                print FileName" Line "z": Comment in Comment /* /*">"/dev/stderr"
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
                print FileName" Line "z": Line Continuation \\ in Comment">"/dev/stderr"
                input[inputI][inputZ] = input[inputI][inputZ] $0
                if (DEBUG) { for (h = 1; h <= NF; ++h) { if ($h == fix) printf "|"; else printf "%s ", $h } printf "" }
                continuation = 1; getline; ++z; i = 0; continue
            }
            continue
        }
        if (inputType == "string") {
            if (i == NF && $i == "\\") {
                if (i != 1) if (Index_prepend(i, fix, fix)) ++i
                print FileName" Line "z": Line Continuation \\ in String">"/dev/stderr"
                input[inputI][inputZ] = input[inputI][inputZ] $0
                if (DEBUG) { for (h = 1; h <= NF; ++h) { if ($h == fix) printf "|"; else printf "%s ", $h } printf "" }
                continuation = 1; getline; ++z; i = 0; continue
            }
            if ($i == "\\" && $(i + 1) == "\"") { ++i; continue }
            if ($i == "\"") {
                inputType = ""
                if (hash == "# include") {
                    if (File_exists(Directory string)) {
                        List_insertBefore(includes, FILENAME, Directory string)
                        ARGV_add(Directory string)
                    }
                    else print "(preprocess) File doesn't exist: \""Directory string"\"">"/dev/stderr"
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
                print FileName" Line "z": Line Continuation \\ in #include <String>">"/dev/stderr"
                input[inputI][inputZ] = input[inputI][inputZ] $0
                if (DEBUG) { for (h = 1; h <= NF; ++h) { if ($h == fix) printf "|"; else printf "%s ", $h } printf "" }
                continuation = 1; getline; ++z; i = 0; continue
            }
            if ($i == ">") {
                inputType = ""
                for (d = 1; d <= includeDirs["length"]; ++d) {
                    if (File_exists(includeDirs[d] includeString)) {
                        List_insertBefore(includes, FILENAME, includeDirs[d] includeString)
                        ARGV_add(includeDirs[d] includeString)
                        break
                    }
                }
                if (d > includeDirs["length"]) print "(preprocess) File doesn't exist: <"includeString">">"/dev/stderr"
                hash = ""
                if (i != NF) if (Index_append(i, fix, fix)) ++i
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
#            # mache, zähle LeerZeichen
#            for (n = i; ++n <= NF; ) {
#                if ($n ~ /[ \b\f\n\r\t\v]/) { $n = " "; continue }
#                break
#            } --n
#            if (n == NF) { # i == 1 ||
#                # eliminiere LeerZeichen
#                for (n = i; ++n <= NF; ) {
#                    if ($n ~ /[ \b\f\n\r\t\v]/) { Index_remove(n--); continue }
#                    break
#                } --n
#                Index_remove(i--)
#            }
            if (i != NF) {
                Index_remove(i--); continue
            }
            if (i != 1) if (Index_prepend(i, fix, fix)) ++i
            print FileName" Line "z": Line Continuation \\">"/dev/stderr"
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
            if (hash == "#") hash = "# "name
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

    # Array_print(includes)

    precompile()

    if (!error) @make()
}



function precompile(    a, b, c, d, defines, e, f, g, h, i, inputType, j, k, l, m, n,
                        o, p, q, r, resultI, resultZ, statement, statementI, statementString, s, structs, structsI,
                        t, typedefs, typedefsI, typeName, u, v, w, varName, x, y, z)
{
    structs["length"] = structsI = 0
    typedefs["length"] = typedefsI = 0
    defines["length"] = definesI = 0

    for (d = 1; d <= includes["length"]; ++d) {
        for (e = 1; e <= input["length"]; ++e)
            if (input[e]["FILENAME"] == includes[d]) break
        if (e > input["length"]) { print "(precompile) File doesn't exist: "includes[d]>"/dev/stderr"; continue }

    resultI = ++result["length"]
    result[resultI]["FILENAME"] = input[e]["FILENAME"]

    inputType = ""
    statement["length"] = statementI = 0

    for (z = 1; z <= input[e]["length"]; ++z) {
        Index_push(input[e][z], fixFS, fix)

    i = 1
    do {
        if ($i ~ /^[ ]*$/) continue
        if (inputType == "comment") {
            if ($i ~ /\*\/$/) inputType = ""
            continue
        }
        if ($i ~ /^\/\*/) {
            inputType = "comment"
            if ($i ~ /\*\/$/) inputType = ""
            continue
        }
        if ($i ~ /^\/\//) {
            break
        }
        if (i == 1 && $i == "#") {

            if ($2 == "define") {
                if (f = Array_contains(defines, $3)) {
                    print "(precompile) define already exists: "$3>"/dev/stderr"
#                    break
                    defines[$3]["function"] = ""
                    defines[$3]["functionL"] = 0
                    defines[$3]["body"] = ""
                    defines[$3]["bodyL"] = 0
                } else f = Array_add(defines, $3)
                n = 4
                if ($4 == "(") {
                    for (; ++n <= NF; ) {
                        if ($n == ")") break
                        defines[$3]["function"] = String_concat(defines[$3]["function"], "\x01", $n)
                        ++defines[$3]["functionL"]
                    }
                    #if (n > NF) ;
                    if (n <= NF) ++n
                }
                for (; n <= NF; ++n) {
                    defines[$3]["body"] = String_concat(defines[$3]["body"], "\x01", $n)
                    ++defines[$3]["bodyL"]
                }

                # if (defines[$3]["body"] == $3) { defines[$3]["body"] = "/* "$3" */" }
                if (defines[$3]["body"] ~ /^[ ]*$/ && defines[$3]["function"] !~ /^[ ]*$/) {
                    defines[$3]["body"] = "("defines[$3]["function"]")"
                    defines[$3]["bodyL"] = defines[$3]["functionL"]
                    defines[$3]["function"] = ""
                    defines[$3]["functionL"] = 0
                }
if (defines[$3]["function"])
printf $3 "(" defines[$3]["function"] ") " defines[$3]["body"]"\n">"/dev/stderr"
else
printf $3 " " defines[$3]["body"]"\n">"/dev/stderr"

                break
            }
            if ($2 == "undef") {
                if (!(f = Array_contains(defines, $3))) {
                    print "(precompile) undef doesn't exist: "$3>"/dev/stderr"
                    break
                }
                Array_remove(defines, f)
                break
            }

            # print # if ($0 !~ /^[ \x01]*$/) {
            resultZ = ++result[resultI]["length"]
            result[resultI][resultZ] = $0
            break
        }

# TODO: This doesn't work. You should read #defines earlier!
#        if (n = Array_contains(defines, $i)) {
#            $i = defines[defines[n]]["body"]
#            Index_reset()
## print
#            --i; continue
#        }

        if ($i == ";") {
            Array_add(statement, $i)

            if (statement["length"]) {
                statementString = String_join(fix, statement)
                if (statementString !~ /^[ \x01]*$/) {

                    resultZ = ++result[resultI]["length"]
                    result[resultI][resultZ] = statementString
                }
            }

            Array_clear(statement)
            continue
        }


        Array_add(statement, $i)

    } while (++i <= NF)

        if (NF == 0) {
            # empty line
        }

        #if (statement["length"]) {
        #    statementString = String_join(fix, statement)
        #    if (statementString !~ /^[ \x01]*$/) {

        #        resultZ = ++result[resultI]["length"]
        #        result[resultI][resultZ] = statementString
        #    }
        #} else
        if (i <= NF) {
            # this is a line comment or a define

        }

        Index_pop()
    } }
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

