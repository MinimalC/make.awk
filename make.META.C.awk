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
            if (paramName == "indent") indent = paramWert; else
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
    if (ERRNO) { print "File doesn't exist: "FILENAME>"/dev/stderr"; nextfile }

    FileName = get_FileName(FILENAME)
    Directory = get_DirectoryName(FILENAME)

    inputI = ++input["length"]
    input[inputI]["FILENAME"] = FILENAME
    #input[inputI]["FileName"] = FileName
    #input[inputI]["Directory"] = Directory

    leereZeilen = 0
    z = 0
    inputType = ""
    was = ""

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

    Index_push($0, "", "")
    i = 1
    do {
        if (inputType == "comment") {
            if ($i == "/" && $(i + 1) == "*") {
                $(i++) = "*"
                ++comments
                print FileName" Line "z": Comment in Comment /* /*" >"/dev/stderr"
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
            if (i == NF && $i == "\\") {
                print FileName" Line "z": Line Continuation \\ in String">"/dev/stderr"
                break
            }
            if ($i == "\\" && $(i + 1) == "\"") { ++i; continue }
            if ($i == "\"") {
                inputType = ""
                if (was == "#include") {
                    if (!Array_contains(includes, Directory string))
                        StringArray_insertBefore(includes, FILENAME, Directory string)
                    if (!ARGV_contains(Directory string))
                        ARGV[ARGC++] = Directory string
                }
                was = ""
                if (i != NF) Index_append(i, use, use)
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
                if (i != NF) Index_append(i, use, use)
            }
            continue
        }
        if (inputType == "include string") {
            if (i == NF && $i != ">") {
                Index_append(i, ">")
                Index_reset(); ++i
            }
            if ($i == ">") {
                inputType = ""
                if (!Array_contains(includes, "/usr/include/" includeString))
                    StringArray_insertBefore(includes, FILENAME, "/usr/include/" includeString)
                if (!ARGV_contains("/usr/include/" includeString))
                    ARGV[ARGC++] = "/usr/include/" includeString
                was = ""
                if (i != NF) Index_append(i, use, use)
            }
            else includeString = includeString $i
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
            string = ""
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
            ## eliminiere LeerZeichen
            #for (n = i; ++n <= NF; ) {
            #    if ($n ~ /[ \b\f\n\r\t\v]/) { $n = ""; continue }
            #    break
            #} --n
            #Index_reset()
            was = "#"
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
            if (was == "#include") {
                inputType = "include string"
                includeString = ""
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
        if ($i == "," || $i == ";" || $i == "?" || $i == ":" || $i == "~") {
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
                zahl = "0x"
                for (; ++i <= NF; ) {
                    if ($i ~ /[0-9a-fA-F]/) { zahl = zahl $i; continue }
                    break
                } --i
                for (; ++i <= NF; ) {
                    if ($i ~ /[ulUL]/) { zahl = zahl $i; continue }
                    break
                } --i
                if (i != NF) Index_append(i, use, use)
                if (was == "#") was = "#"zahl
                else was = zahl
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
            if (i != NF) Index_append(i, use, use)
            if (was == "#") was = "#"zahl
            else was = zahl
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
            name = $i
            for (; ++i <= NF; ) {
                if ($i ~ /[[:alpha:]_0-9]/) { name = name $i; continue }
                break
            } --i
            if (i != NF) Index_append(i, use, use)
            if (was == "#") was = "#"name
            else was = name
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

    Array_print(includes)

    precompile()

    if (!error) @make()
}

function precompile(    a, b, c, d, e, f, g, h, i, inputType, j, k, l, m, n, o, p, q, r, resultLine, s, t, typeName, u, v, w, x, y, z) {

    for (d = 1; d <= includes["length"]; ++d) {
        for (e = 1; e <= input["length"]; ++e)
            if (input[e]["FILENAME"] == includes[d]) break
        if (e > input["length"]) { print "File \""includes[d]"\" doesn't exist">"/dev/stderr"; continue }

    resultI = ++result["length"]
    result[resultI]["FILENAME"] = input[e]["FILENAME"]

    for (z = 1; z <= input[e]["length"]; ++z) {
        Index_push(input[e][z], useFS, use)

    resultLineI = resultLine["length"] = 0
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
        if ($i == "void") {
            typeName = String_concat(typeName, " ", $i)
            ++i
        }
        else if ($i == "char") {
            typeName = String_concat(typeName, " ", $i)
            ++i
        }
        else if ($i == "long") {
            if ($(i + 1) == "long") {
                typeName = String_concat(typeName, " ", $i)
                ++i
            }
            if ($i == "int") {
                typeName = String_concat(typeName, " ", $i)
                ++i
            }
            typeName = String_concat(typeName, " ", $i)
            ++i
        }
        else if ($i == "int" || $i == "short") {
            typeName = String_concat(typeName, " ", $i)
            ++i
        }
        else if ($i == "struct") {
            typeName = String_concat(typeName, " ", $i)
            ++i
            if ($i ~ /^[[:alpha:]_0-9]+$/) {
                typeName = String_concat(typeName, " ", $i)
                ++i
            }
        }
        if ($i == "*") {
            typeName = String_concat(typeName, " ", $i)
            ++i
        }
        if (typeName) {
            if (storage) { Array_add(resultLine, storage); storage = "" }
            if (qualifier) { Array_add(resultLine, qualifier); qualifier = "" }
            Array_add(resultLine, typeName); typeName = ""
        }

        resultLineI = ++resultLine["length"]
        resultLine[resultLineI] = $i

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

    for (d = 1; d <= includes["length"]; ++d) {
        for (e = 1; e <= input["length"]; ++e)
            if (input[e]["FILENAME"] == includes[d]) break
        if (e > input["length"]) continue

    if (DEBUG) { print ""; print input[e]["FILENAME"] }

    for (z = 1; z <= input[e]["length"]; ++z) {
        Index_push(input[e][z], useFS, use)

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

function make_print(    a, b, c, d, e, f, g, h, i, j, k, l, x, y, z) {

    for (d = 1; d <= includes["length"]; ++d) {
        for (e = 1; e <= result["length"]; ++e)
            if (result[e]["FILENAME"] == includes[d]) break
        if (e > result["length"]) continue

    if (DEBUG) { print ""; print result[e]["FILENAME"] }

    for (z = 1; z <= result[e]["length"]; ++z) {
        Index_push(result[e][z], useFS, use)

        if (DEBUG) {
            for (h = 1; h <= NF; ++h) { if ($h ~ /^[ ]*$/) ; else printf "(%d)%s", h, $h } print ""
        }
        else {
            for (h = 1; h <= NF; ++h) { if ($h ~ /^[ ]*$/) ; else printf "%s ", $h } print ""
        }

        Index_pop()
    } }

}

