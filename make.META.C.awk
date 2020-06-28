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
    use = " "

    for (argI = 1; argI < ARGC; ++argI) {
        # argL = length(ARGV[argI])

        if (argI == 1 && "make_"ARGV[argI] in FUNCTAB) {
            make = "make_"ARGV[argI]
            delete ARGV[argI]; continue
        }

        paramI = index(ARGV[argI], "=")
        if (paramI > 0) {
            paramName = substr(ARGV[argI], 1, paramI - 1)
            paramWert = substr(ARGV[argI], paramI + 1)

            # if (paramName == "Namespace") Namespace = paramWert; else
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

NF == 0 { if (leereZeilen++ < 2) Array_add(output, "") }

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
                if (i != NF) Index_append(i, "\t", "\t")
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

        if ($i ~ /[ \t]/) {
            if (i == 1 || i == NF) {
                Index_remove(i--)
                continue
            }
            $i = "\t"

            for (j = i; ++j <= NF; ) {
                if ($j ~ /[ \t]/) { $j = ""; continue }
                break
            }
            Index_reset()
            continue
        }

        if ($i == "\"") {
            if (i != 1) if (Index_prepend(i, "\t", "\t")) ++i

            input = "string"
            continue
        }

        if ($i == "#") {
            if ($(i + 1) == "#") {
                if (i != 1) if (Index_prepend(i, "\t", "\t")) ++i
                ++i
                if (i != NF) Index_append(i, "\t", "\t")
                continue
            }
            if (i != 1) { Index_remove(i--); continue }

            j = i
            if (i != NF) if (Index_append(i, "\t", "\t")) ++j
            for (; ++j <= NF; ) {
                if ($j ~ /[ \t]/) { $j = ""; continue }
                break
            }
            Index_reset()
            continue
        }


        if ($i == "*") {
            if ($(i + 1) == "/") { $i = ""; $(i + 1) = ""; Index_reset(); i -= 2; continue }

            if (i != 1) if (Index_prepend(i, "\t", "\t")) ++i
            if ($(i + 1) == "=") ++i
            if (i != NF) Index_append(i, "\t", "\t")

            continue
        }

        if ($i == "/") {
            if (i != 1) if (Index_prepend(i, "\t", "\t")) ++i
            if ($(i + 1) == "*") { ++i; input = "comment"; continue }
            if ($(i + 1) == "=") ++i
            if (i != NF) Index_append(i, "\t", "\t")

            continue
        }

        if ($i == "+") {
            if (i != 1) if (Index_prepend(i, "\t", "\t")) ++i
            if ($(i + 1) == "+") ++i
            else if ($(i + 1) == "=") ++i
            if (i != NF) Index_append(i, "\t", "\t")

            continue
        }

        if ($i == "-") {
            if (i != 1) if (Index_prepend(i, "\t", "\t")) ++i
            if ($(i + 1) == ">") ++i
            else if ($(i + 1) == "-") ++i
            if (i != NF) Index_append(i, "\t", "\t")

            continue
        }

        if ($i == "=") {
            if (i != 1) if (Index_prepend(i, "\t", "\t")) ++i
            if ($(i + 1) == "=") ++i
            if (i != NF) Index_append(i, "\t", "\t")

            continue
        }

        if ($i == "%" || $i == "^") {
            if (i != 1) if (Index_prepend(i, "\t", "\t")) ++i
            if ($(i + 1) == "=") ++i
            if (i != NF) Index_append(i, "\t", "\t")

            continue
        }

        if ($i == "&") {
            if (i != 1) if (Index_prepend(i, "\t", "\t")) ++i
            if ($(i + 1) == "&") ++i
            else if ($(i + 1) == "=") ++i
            if (i != NF) Index_append(i, "\t", "\t")

            continue
        }

        if ($i == "|") {
            if (i != 1) if (Index_prepend(i, "\t", "\t")) ++i
            if ($(i + 1) == "|") ++i
            else if ($(i + 1) == "=") ++i
            if (i != NF) Index_append(i, "\t", "\t")

            continue
        }


        if ($i == "(" || $i == "{" || $i == "[") {
            if (i != 1) if (Index_prepend(i, "\t", "\t")) ++i
            if (i != NF) Index_append(i, "\t", "\t")

            continue
        }
        if ($i == ")" || $i == "}" || $i == "]") {
            if (i != 1) if (Index_prepend(i, "\t", "\t")) ++i
            if (i != NF) Index_append(i, "\t", "\t")

            continue
        }


        if ($i == "<") {
            if (i != 1) if (Index_prepend(i, "\t", "\t")) ++i
            if ($1 == "#" && $3 == "i") {
                input = "include string"
                continue
            }
            if ($(i + 1) == "<") ++i
            if ($(i + 1) == "=") ++i
            if (i != NF) Index_append(i, "\t", "\t")

            continue
        }
        if ($i == ">") {
            if (i != 1) if (Index_prepend(i, "\t", "\t")) ++i
            if ($(i + 1) == ">") ++i
            if ($(i + 1) == "=") ++i
            if (i != NF) Index_append(i, "\t", "\t")

            continue
        }

        if ( $i == "." ) {
            if (i != 1) if (Index_prepend(i, "\t", "\t")) ++i
            if ( $(i + 1) == "." ) ++i
            if ( $(i + 1) == "." ) ++i
            if (i != NF) Index_append(i, "\t", "\t")

            continue
        }
        if ($i == "!" || $i == "." || $i == "," || $i == ";" || $i == "?" || $i == ":") {
            if (i != 1) if (Index_prepend(i, "\t", "\t")) ++i
            if (i != NF) Index_append(i, "\t", "\t")

            continue
        }

        if ($i == "\\") {
            if (i != 1) if (Index_prepend(i, "\t", "\t")) ++i
            if (i != NF) $i = ""

            for (j = i; ++j <= NF; ) {
                if ($j ~ /[ \t]/) { $j = ""; continue }
                break
            }
            Index_reset()
            continue
        }

        if ($i == "0") {
            if ($(i + 1) == "x") {
                # lies eine Hexadezimalzahl
            }
            # lies eine Oktalzahl
            # oder 0
            continue
        }

        if ($i ~ /[1-9][0-9]*/) {
            #lies eine Dezimalzahl
            continue
        }

        if ($i ~ /[[:alpha:]_]/) continue

        Index_remove(i--)

    } while (++i <= NF)

# RELEASE
    Array_add(output, $0)
# DEBUG
    for (x = 1; x <= NF; ++x) { printf "(%d)%s ", x, $x } print ""

}

ENDFILE {

    if (!error) @make()
}

function make_print(    h, i, j, k, l) {

    print ""

    for (i = 1; i <= output["length"]; ++i) {
        Index_push(output[i], "\t", " ", "\n", "\n")

# RELEASE
#        print
# DEBUG
        for (j = 1; j <= NF; ++j) { printf "(%d)%s ", j, $j } print ""

        Index_pop()
    }

}

