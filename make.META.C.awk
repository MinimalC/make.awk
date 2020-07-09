#!/usr/bin/awk -f
# Gemeinfrei.
# 2020 Hans Riehm

@include "meta.awk"

function usage() {
    print "Use make.ISO_C.awk Program.c">"/dev/stderr"
}

BEGIN {
    if (ARGC == 1) { usage(); exit 1 }

    make = "make_print"
    includeDirs["length"] = 0
    useFS = @/[\x01]+/
    use = "\x01"
    indent = 1

    for (argI = 1; argI < ARGC; ++argI) {
        # argL = length(ARGV[argI])

        if (argI == 1 && "make_"ARGV[argI] in FUNCTAB) {
            make = "make_"ARGV[argI]
            delete ARGV[argI]; continue
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
            if (paramName == "indent") indent = paramWert; else
            if (paramName == "debug") DEBUG = paramWert; else
        print "Unknown argument: \""paramName "\" = \""paramWert"\"">"/dev/stderr"
            delete ARGV[argI]; continue
        }

        if (Directory_exists(ARGV[argI])) {
            Array_add(includeDirs, ARGV[argI])
            delete ARGV[argI]; continue
        }

        if (!File_exists(ARGV[argI])) {
            print "File doesn't exist: "ARGV[argI]>"/dev/stderr"
            delete ARGV[argI]; continue
        }
        else {
            fileName = get_FileName(ARGV[argI])
            directory = get_DirectoryName(ARGV[argI])

            if (fileName ~ /\.h$/) { }
            else if (fileName ~ /\.c$/) { }
            else if (fileName ~ /\.inc$/) { }
            else {
                error = "Unknown inputType format: "fileName
                delete ARGV[argI]; continue
            }

        }
    }
}

BEGINFILE {

    if (FILENAME == "-") { usage(); nextfile }

    FileName = get_FileName(FILENAME)
    Directory = get_DirectoryName(FILENAME)

    leereZeilen = 0
    z = 0
    inputType = ""
    inputI = ++input["length"]

    #FS=" "
    #OFS=" "
    RS="\n"
    #ORS="\n"
}

NF > 0 {  # PreProcess: read what you have, in C

    ++z
    leereZeilen = 0

    Index_push($0, "", "")
    i = 1
    do {
        if (inputType == "comment") {
            if ($i == "/" && $(i + 1) == "*") {
                $(i++) = "*"
                ++comments
                warning = warning FileName" Line "z": Comment in Comment /* /*\n"
            }
            else if ($i == "*" && $(i + 1) == "/") {
                if (comments) {
                    --comments
                    $(++i) = "*"
                    continue
                }
                ++i
                inputType = ""
                if (i != NF) Index_append(i, use, use)
            }
            continue
        }
        if (inputType == "string") {
            if (i == NF && $i != "\"") {
                if (Index_append(i, "\"")) {
                    i += 2
                    warning = warning FileName" Line "z": Missing End of String \"\n"
                }
                inputType = ""
                break
            }
            if ($i == "\\") {
                if ($(i + 1) == "\"") { ++i; continue }
            }
            if ($i == "\"") {
                inputType = ""
                if (i != NF) Index_append(i, use, use)
            }
            continue
        }
        if (inputType == "character") {
            if (i == NF && $i != "'") {
                if (Index_append(i, "'")) i += 2
                inputType = ""
                break
            }
            if ($i == "\\") {
                if ($(i + 1) == "'") { ++i; continue }
            }
            if ($i == "'") {
                inputType = ""
                if (i != NF) Index_append(i, use, use)
            }
            continue
        }
        if (inputType == "include string") {
            if (i == NF && $i != ">") {
                if (Index_append(i, ">")) ++i
                inputType = ""
                break
            }
            if ($i == ">") {
                inputType = ""
                if (i != NF) Index_append(i, use, use)
            }
            continue
        }
        if ($i == use) continue
        if ($i ~ /[ \b\f\n\r\t\v]/) {
            $i = " "
            # mache, zähle LeerZeichen
            for (n = i; ++n <= NF; ) {
                if ($n ~ /[ \b\f\n\r\t\v]/) { $n = " "; continue }
                break
            } --n
            if (n == NF) { # i == 1 ||
                # eliminiere LeerZeichen
                for (n = i; ++n <= NF; ) {
                    if ($n ~ /[ \b\f\n\r\t\v]/) { $n = ""; continue }
                    break
                } --n
                $i = ""; --i
            }
            Index_reset()
            continue
        }
        if ($i == "\"") {
            if (i != 1) if (Index_prepend(i, use, use)) ++i
            inputType = "string"
            continue
        }
        if ( $i == "'" ) {
            if (i != 1) if (Index_prepend(i, use, use)) ++i
            inputType = "character"
            continue
        }
        if ($i == "#") {
            if (i != 1) if (Index_prepend(i, use, use)) ++i
            if ($(i + 1) == "#") {
                ++i
                if (i != NF) Index_append(i, use, use)
                continue
            }
            # eliminiere LeerZeichen
            for (n = i; ++n <= NF; ) {
                if ($n ~ /[ \b\f\n\r\t\v]/) { $n = ""; continue }
                break
            } --n
            Index_reset()
            if (i != NF) Index_append(i, use, use)
            continue
        }
        if ($i == "*") {
            if ($(i + 1) == "/") { $i = ""; $(i + 1) = ""; Index_reset(); --i; continue }
            if (i != 1) if (Index_prepend(i, use, use)) ++i
            if ($(i + 1) == "=") ++i
            if (i != NF) Index_append(i, use, use)
            continue
        }
        if ($i == "/") {
            if (i != 1) if (Index_prepend(i, use, use)) ++i
            if ($(i + 1) == "*") {
                ++i; inputType = "comment"
                continue
            }
            if ($(i + 1) == "/") break
            if ($(i + 1) == "=") ++i
            if (i != NF) Index_append(i, use, use)
            continue
        }
        if ($i == "+") {
            if (i != 1) if (Index_prepend(i, use, use)) ++i
            if ($(i + 1) == "+") ++i
            else if ($(i + 1) == "=") ++i
            if (i != NF) Index_append(i, use, use)
            continue
        }
        if ($i == "-") {
            if (i != 1) if (Index_prepend(i, use, use)) ++i
            if ($(i + 1) == ">") ++i
            else if ($(i + 1) == "-") ++i
            else if ($(i + 1) == "=") ++i
            if (i != NF) Index_append(i, use, use)
            continue
        }
        if ($i == "=") {
            if (i != 1) if (Index_prepend(i, use, use)) ++i
            if ($(i + 1) == "=") ++i
            if (i != NF) Index_append(i, use, use)
            continue
        }
        if ($i == "%" || $i == "^") {
            if (i != 1) if (Index_prepend(i, use, use)) ++i
            if ($(i + 1) == "=") ++i
            if (i != NF) Index_append(i, use, use)
            continue
        }
        if ($i == "&") {
            if (i != 1) if (Index_prepend(i, use, use)) ++i
            if ($(i + 1) == "&") ++i
            else if ($(i + 1) == "=") ++i
            if (i != NF) Index_append(i, use, use)
            continue
        }
        if ($i == "|") {
            if (i != 1) if (Index_prepend(i, use, use)) ++i
            if ($(i + 1) == "|") ++i
            else if ($(i + 1) == "=") ++i
            if (i != NF) Index_append(i, use, use)
            continue
        }
        if ($i == "(" || $i == "{" || $i == "[") {
            if (i != 1) if (Index_prepend(i, use, use)) ++i
            if (i != NF) Index_append(i, use, use)
            continue
        }
        if ($i == ")" || $i == "}" || $i == "]") {
            if (i != 1) if (Index_prepend(i, use, use)) ++i
            if (i != NF) Index_append(i, use, use)
            continue
        }
        if ($i == "<") {
            if (i != 1) if (Index_prepend(i, use, use)) ++i
            if ($1 == "#" && $3 == "i") {
                inputType = "include string"
                continue
            }
            if ($(i + 1) == "<") ++i
            if ($(i + 1) == "=") ++i
            if (i != NF) Index_append(i, use, use)
            continue
        }
        if ($i == ">") {
            if (i != 1) if (Index_prepend(i, use, use)) ++i
            if ($(i + 1) == ">") ++i
            if ($(i + 1) == "=") ++i
            if (i != NF) Index_append(i, use, use)
            continue
        }
        if ($i == "!") {
            if (i != 1) if (Index_prepend(i, use, use)) ++i
            if ($(i + 1) == "=") ++i
            if (i != NF) Index_append(i, use, use)
            continue
        }
        if ($i == "," || $i == ";" || $i == "?" || $i == ":") {
            if (i != 1) if (Index_prepend(i, use, use)) ++i
            if (i != NF) Index_append(i, use, use)
            continue
        }
        if ($i == "\\") {
            if (i != 1) if (Index_prepend(i, use, use)) ++i
            if (i != NF) $i = ""
            for (; ++i <= NF; ) {
                if ($i ~ /[ \b\f\n\r\t\v]/) { $i = ""; continue }
                break
            } --i
            Index_reset()
            continue
        }
        if ($i ~ /[0-9]/) {
            if (i != 1) if (Index_prepend(i, use, use)) ++i
            if ($i == "0" && $(i + 1) == "x") {
                i += 2
                # lies eine HexadezimalZahl
                for (; ++i <= NF; ) {
                    if ($i ~ /[0-9a-fA-F]/) continue
                    break
                } --i
                for (; ++i <= NF; ) {
                    if ($i ~ /[ulUL]/) continue
                    break
                } --i
                if (i != NF) Index_append(i, use, use)
                continue
            }
            # lies eine Zahl
            zahl = "decimal"
            for (; ++i <= NF; ) {
                if ($i ~ /[0-9]/) continue
                break
            } --i
            if ($(i + 1) == ".") {
                ++i; zahl = "floating point"
                # lies eine Zahl, als Fragment
                for (; ++i <= NF; ) {
                    if ($i ~ /[0-9]/) continue
                    break
                } --i
            }
            if ($(i + 1) ~ /[eE]/) {
                ++i; zahl = "floating point"
                if ($(i + 1) ~ /[+-]/) ++i
                # lies den Exponent
                for (; ++i <= NF; ) {
                    if ($i ~ /[0-9]/) continue
                    break
                } --i
            }
            if (zahl != "floating point" && $(i + 1) ~ /[uUlL]/) {
                ++i
                for (; ++i <= NF; ) {
                    if ($i ~ /[uUlL]/) continue
                    break
                } --i
            }
            if (i != NF) Index_append(i, use, use)
            continue
        }
        if ( $i == "." ) {
            if (i != 1) if (Index_prepend(i, use, use)) ++i
            if ( $(i + 1) == "." && $(i + 2) == "." ) i += 2
            if (i != NF) Index_append(i, use, use)
            continue
        }
        if ($i ~ /[[:alpha:]_]/) {
            if (i != 1) if (Index_prepend(i, use, use)) ++i
            # lies einen Namen
            for (; ++i <= NF; ) {
                if ($i ~ /[[:alpha:]_0-9]/) continue
                break
            } --i
            if (i != NF) Index_append(i, use, use)
            continue
        }

        # Just remove everything else!
        Index_remove(i--)

    } while (++i <= NF)

    inputZ = ++input[inputI]["length"]
    input[inputI][inputZ] = $0

    if (DEBUG) {
    for (h = 1; h <= NF; ++h) { if ($h == use) printf "|"; else printf "%s ", $h } print ""
    }

    #resultLineString = $0
    Index_pop()
    #$0 = resultLineString
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

    preprocess()

    if (!error) @make()
}

function preprocess(    a, b, c, d, e, f, g, h, i, inputType, j, k, l, m, n, o, p, q, r, resultLine, s, t, typeName, u, v, w, x, y, z) {
    for (d = 1; d <= input["length"]; ++d) {
    for (z = 1; z <= input[d]["length"]; ++z) {
        Index_push(input[d][z], useFS, use)

    resultI = ++result["length"]
    Array_create(resultLine)
    i = 1
    do {
        if (inputType == "comment") {
            if ($i ~ /\*\/$/) inputType = ""
            continue
        }
        if ($i ~ /^\/\*/) {
            if ($i !~ /\*\/$/) inputType = "comment"
            continue
        }
        if ($i ~ /^\/\//) {
            for (; ++i <= NF; ) ;
            continue
        }
        if (indent && $i ~ /^[ ]+$/) {
            continue
        }

        if ($i == "extern" || $i == "register" || $i == "static" || $i == "auto") {
            storage = String_concat(storage, " ", $i)
            ++i
        }
        if ($i == "const" || $i == "volatile") {
            qualifier = String_concat(qualifier, " ", $i)
            ++i
        }
        if ($i == "unsigned" || $i == "signed") {
            typeName = String_concat(typeName, " ", $i)
            ++i
        }
        if ($i == "void" || $i == "char" || $i == "long" || $i == "int" || $i == "short") {
            typeName = String_concat(typeName, " ", $i)
            ++i
        }
        if ($i == "struct" || (typeName && $i == "*")) {
            typeName = String_concat(typeName, " ", $i)
            ++i
        }
        if (typeName == "struct" && $i ~ /^[[:alpha:]_0-9]+$/) {
            typeName = String_concat(typeName, " ", $i)
            ++i
        }
        if (typeName) {
            if (storage) { Array_add(resultLine, storage); storage = "" }
            if (qualifier) { Array_add(resultLine, qualifier); qualifier = "" }
            Array_add(resultLine, typeName); typeName = ""
        }

        Array_add(resultLine, $i)

    } while (++i <= NF)
        Index_pop()

        resultLineString = String_join(use, resultLine)
        if (resultLineString !~ /^[\x01 ]*$/) {

            resultZ = ++result[resultI]["length"]
            result[resultI][resultZ] = resultLineString
        }
    } }
}

function make_printInput(    a, b, c, d, e, f, g, h, i, j, k, l, x, y, z) {

    if (DEBUG) print ""

    for (d = 1; d <= input["length"]; ++d) {
    for (z = 1; z <= input[d]["length"]; ++z) {
        Index_push(input[d][z], useFS, " ")

        if (DEBUG) {
            for (h = 1; h <= NF; ++h) { if ($h ~ /^[ ]*$/) printf "%s", $h; else printf "(%d)%s", h, $h } print ""
        }
        else {
            # This is GAWK. You can't use just
            # print
            for (h = 1; h <= NF; ++h) {  printf "%s", $h } print ""
        }

        Index_pop()
    } }
}

function make_print(    h, i, j, k, l, x, y, z) {

    if (DEBUG) print ""

    for (d = 1; d <= result["length"]; ++d) {
    for (z = 1; z <= result[d]["length"]; ++z) {
        Index_push(result[d][z], useFS, " ")

        if (DEBUG) {
            for (h = 1; h <= NF; ++h) { if ($h ~ /^[ ]*$/) ; else printf "(%d)%s", h, $h } print ""
        }
        else {
            for (h = 1; h <= NF; ++h) { if ($h ~ /^[ ]*$/) ; else printf "%s ", $h } print ""
        }

        Index_pop()
    } }

}

