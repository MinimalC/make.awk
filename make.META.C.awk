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
    use = "\a"

    for (argI = 1; argI < ARGC; ++argI) {
        # argL = length(ARGV[argI])

        if (argI == 1 && "make_"ARGV[argI] in FUNCTAB) {
            make = "make_"ARGV[argI]
            delete ARGV[argI]; continue
        }

        paramName = ""
        if (ARGV[argI] ~ /^--.*=.*$/) {
            paramI = index(ARGV[argI], "=")
            paramName = substr(ARGV[argI], 3, paramI - 1)
            paramWert = substr(ARGV[argI], paramI + 1)
        } else
        if (ARGV[argI] ~ /^--.*$/) {
            paramI = index(ARGV[argI], "=")
            paramName = substr(ARGV[argI], 3)
            paramWert = 1
        }
        if (paramName) {
            # if (paramName == "Namespace") Namespace = paramWert; else
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
                error = "Unknown input format: "fileName
                delete ARGV[argI]; continue
            }

        }
    }

}

BEGINFILE {

    if (FILENAME == "-") { usage(); nextfile }

    FileName = get_FileName(FILENAME)
    Directory = get_DirectoryName(FILENAME)

    Array_create(output)
    leereZeilen = 0
    z = 0
    input = ""

    FS=""
    OFS=""
    RS="\n"
    ORS="\n"
}

NF == 0 { if (leereZeilen++ < 2) { ++z; Array_add(output, "") } }

NF > 0 {  # PreProcess: read what you have, in C

    ++z
    leereZeilen = 0

    i = 1
    do {

        if (input == "string") {

            if (i == NF && $i != "\"") {
                if (Index_append(i, "\"")) ++i
                input = ""
                break
            }
            if ($i == "\"") {
                if (i != NF) Index_append(i, use, use)
                input = ""
            }
            continue
        }

        if (input == "include string") {

            if (i == NF && $i != ">") {
                if (Index_append(i, ">")) ++i
                input = ""
                break
            }
            if ($i == ">") input = ""
            continue
        }

        if (input == "comment") {

            if ($i == "/" && $(i + 1) == "*") {
                $(i++) = "*"
            }
            else if ($i == "*" && $(i + 1) == "/") {
                ++i; input = ""
            }
            continue
        }

        if ($i == use) continue

        if ($i ~ /[ \t]/) {
#            if (i != 1) if (Index_prepend(i, use, use)) ++i

            # lies LeerZeichen
            for (j = i; ++j <= NF; ) {
                if ($j ~ /[ \t]/) continue
                break
            }
            if (--j > i) i = j

#            if (i != NF) Index_append(i, use, use)
            continue
        }

        if ($i == "\"") {
            if (i != 1) if (Index_prepend(i, use, use)) ++i

            input = "string"
            continue
        }

        if ($i == "#") {
            if ($(i + 1) == "#") {
                if (i != 1) if (Index_prepend(i, use, use)) ++i
                ++i
                if (i != NF) Index_append(i, use, use)
                continue
            }
            if (i != 1) { Index_remove(i--); continue }

            for (j = i; ++j <= NF; ) {
                if ($j ~ /[ \t]/) { $j = ""; continue }
                break
            }
            for (--j; ++j <= NF; ) {
                if ($j ~ /[[:alpha:]_0-9]/) continue # read a Name
                break
            }
            if (--j > i) i = j
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
            if ($(i + 1) == "*") { ++i; input = "comment"; continue }
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
            if ($1 == "#" && $2 == "i") {
                input = "include string"
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

        if ( $i == "." ) {
            if (i != 1) if (Index_prepend(i, use, use)) ++i
            if ( $(i + 1) == "." ) ++i
            if ( $(i + 1) == "." ) ++i
            if (i != NF) Index_append(i, use, use)

            continue
        }
        if ($i == "!" || $i == "." || $i == "," || $i == ";" || $i == "?" || $i == ":") {
            if (i != 1) if (Index_prepend(i, use, use)) ++i
            if (i != NF) Index_append(i, use, use)

            continue
        }

        if ($i == "\\") {
            if (i != 1) if (Index_prepend(i, use, use)) ++i
            if (i != NF) $i = ""

            for (j = i; ++j <= NF; ) {
                if ($j ~ /[ \t]/) { $j = ""; continue }
                break
            }
            Index_reset()
            continue
        }

        if ($i ~ /[0-9]/) {
            if (i != 1) if (Index_prepend(i, use, use)) ++i

            if ($(i + 1) == "x") {
                i += 2
                # lies eine HexadezimalZahl
                for (j = i; ++j <= NF; ) {
                    if ($j ~ /[0-9a-fA-F]/) continue
                    break
                }
                if (--j > i) i = j
            }
            else {
                # lies eine Zahl
                for (j = i; ++j <= NF; ) {
                    if ($j ~ /[0-9]/) continue
                    break
                }
                if (--j > i) i = j
            }
            for (j = i; ++j <= NF; ) {
                if ($j ~ /[ulUL]/) continue
                break
            }
            if (--j > i) i = j

            if (i != NF) Index_append(i, use, use)
            continue
        }

        if ($i ~ /[[:alpha:]_]/) {
            if (i != 1) if (Index_prepend(i, use, use)) ++i

            # lies einen Namen
            for (j = i; ++j <= NF; ) {
                if ($j ~ /[[:alpha:]_0-9]/) continue
                break
            }
            if (--j > i) i = j

            if (i != NF) Index_append(i, use, use)
            continue
        }


        Index_remove(i--)

    } while (++i <= NF)

    Array_add(output, $0)

    if (DEBUG) {
    for (x = 1; x <= NF; ++x) { if ($x == use) printf "|"; else printf "%s ", $x } print ""
    }

}

ENDFILE {

    if (!error) if (make != "make_propose") make_propose()
    if (!error) @make()
}

function make_propose(    h, i, j, k, l) {

    for (i = 1; i <= output["length"]; ++i) {
        Index_push(output[i], use, " ", "\n", "\n")


        Index_pop()
    }
}

function make_print(    h, i, j, k, l) {

    if (DEBUG) print ""

    for (i = 1; i <= output["length"]; ++i) {
        Index_push(output[i], use, " ", "\n", "\n")

# DEBUG
    if (DEBUG) {
        for (j = 1; j <= NF; ++j) { printf "(%d)%s"OFS, j, $j } print ""
    } else
# RELEASE
    {
        for (j = 1; j <= NF; ++j) { if ($j ~ /^[ \t]+$/) ; else printf "%s"OFS, $j } print ""
#        for (j = 1; j <= NF; ++j) { if ($j == "\a") ; else printf "%s", $j } print ""
    }

        Index_pop()
    }

}

