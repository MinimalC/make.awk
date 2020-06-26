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

    FS=""
    OFS=""
    RS="\n"
    ORS="\n"
}


BEGINFILE {

    if (FILENAME == "-") { usage(); nextfile }

    FileName = get_FileName(FILENAME)
    Directory = get_DirectoryName(FILENAME)

    Array_create(output)
}

{   # PreProcess: read what you have, in C

    for (s = 1; s <= NF; ++s) {
        if ($s == " " || $s == "\t") { $s = ""; continue }
        break
    }
    Index_reset()

    i = 1
    do {

        if (input == "string") {

            if (i == NF && $i != "\"") {
                Index_append(i++, "\"")
                input = ""
                continue
            }
            if ($i == "\"") {
                input = ""
                continue
            }
            continue
        }

        if (input == "comment") {

            if ($i == "/" && $(i + 1) == "*") {
                $i = "*"
                ++i
                continue
            }

            if ($i == "*" && $(i + 1) == "/") {
                ++i
                input = ""
                continue
            }
            continue
        }


        if ($i == " " || $i == "\t") {
            $i = " "

            for (j = i + 1; j <= NF; ++j) {
                if ($j == " " || $j == "\t") { $j = ""; continue }
                break
            }

            Index_reset()
            continue
        }

        if ($i == "\"") {
            if (i != 1 && $(i - 1) != " ") { Index_prepend(i++, " ") }

            input = "string"
            continue
        }

        if ($i == "#") {
            if ($(i + 1) == "#") {
                if (i != 1 && $(i - 1) != " ") { Index_prepend(i++, " ") }
                ++i
                if (i != NF && $(i + 1) != " ") { Index_append(i++, " ") }
                continue
            }

            if (i != NF && $(i + 1) != " ") { Index_append(i++, " ") }
            Index_reset()
            continue
        }


        if ($i == "*") {
            if (i != 1 && $(i - 1) != " ") { Index_prepend(i++, " ") }
            if ($(i + 1) == "=") ++i
            if ($(i + 1) == "/") $(++i) = "*" # unused end comment
            if (i != NF && $(i + 1) != " ") { Index_append(i++, " ") }
            continue
        }

        if ($i == "/") {
            if (i != 1 && $(i - 1) !~ /[ \t]/) { Index_prepend(i++, " ") }
            if ($(i + 1) == "*") {
                ++i

                input = "comment"
                continue
            }
            if ($(i + 1) == "=") ++i
            if (i != NF && $(i + 1) != " ") { Index_append(i++, " ") }
            continue
        }

        if ($i == "+") {
            if (i != 1 && $(i - 1) != " ") { Index_prepend(i++, " ") }
            if ($(i + 1) == "+") ++i
            if ($(i + 1) == "=") ++i
            if (i != NF && $(i + 1) != " ") { Index_append(i++, " ") }
            continue
        }

        if ($i == "-") {
            if (i != 1 && $(i - 1) != " ") { Index_prepend(i++, " ") }
            if ($(i + 1) == ">") ++i
            else if ($(i + 1) == "-") ++i
            if (i != NF && $(i + 1) != " ") { Index_append(i++, " ") }
            continue
        }

        if ($i == "=") {
            if (i != 1 && $(i - 1) != " ") { Index_prepend(i++, " ") }
            if ($(i + 1) == "=") ++i
            if (i != NF && $(i + 1) != " ") { Index_append(i++, " ") }
            continue
        }

        if ($i == "%" || $i == "^") {
            if (i != 1 && $(i - 1) != " ") { Index_prepend(i++, " ") }
            if ($(i + 1) == "=") ++i
            if (i != NF && $(i + 1) != " ") { Index_append(i++, " ") }
            continue
        }

        if ($i == "&") {
            if (i != 1 && $(i - 1) != " ") { Index_prepend(i++, " ") }
            if ($(i + 1) == "&") ++i
            else if ($(i + 1) == "=") ++i
            if (i != NF && $(i + 1) != " ") { Index_append(i++, " ") }
            continue
        }

        if ($i == "|") {
            if (i != 1 && $(i - 1) != " ") { Index_prepend(i++, " ") }
            if ($(i + 1) == "|") ++i
            else if ($(i + 1) == "=") ++i
            if (i != NF && $(i + 1) != " ") { Index_append(i++, " ") }
            continue
        }


        if ($i == "(" || $i == "{" || $i == "[") {
            if (i != 1 && $(i - 1) != " ") { Index_prepend(i++, " ") }
            if (i != NF && $(i + 1) != " ") { Index_append(i++, " ") }
            continue
        }
        if ($i == ")" || $i == "}" || $i == "]") {
            if (i != 1 && $(i - 1) != " ") { Index_prepend(i++, " ") }
            if (i != NF && $(i + 1) != " ") { Index_append(i++, " ") }
            continue
        }


        if ($i == ">") {
            if (i != 1 && $(i - 1) != " ") { Index_prepend(i++, " ") }
            if ($(i + 1) == ">") ++i
            if ($(i + 1) == "=") ++i
            if (i != NF && $(i + 1) != " ") { Index_append(i++, " ") }
            continue
        }
        if ($i == "<") {
            if (i != 1 && $(i - 1) != " ") { Index_prepend(i++, " ") }
            if ($(i + 1) == "<") ++i
            if ($(i + 1) == "=") ++i
            if (i != NF && $(i + 1) != " ") { Index_append(i++, " ") }
            continue
        }

        if ( $i == "." ) {
            if (i != 1 && $(i - 1) != " ") { Index_prepend(i++, " ") }
            if ( $(i + 1) == "." ) ++i
            if ( $(i + 1) == "." ) ++i
            if (i != NF && $(i + 1) != " ") { Index_append(i++, " ") }
        }
        if ($i == "!" || $i == "." || $i == "," || $i == ";") {
            if (i != 1 && $(i - 1) != " ") { Index_prepend(i++, " ") }
            if (i != NF && $(i + 1) != " ") { Index_append(i++, " ") }
            continue
        }

        if ($i == "?" || $i == ":") {
            if (i != 1 && $(i - 1) != " ") { Index_prepend(i++, " ") }
            if (i != NF && $(i + 1) != " ") { Index_append(i++, " ") }
            continue
        }

    } while (++i <= NF)

# DEBUG
    print ($0 = $0)"\n"
    Array_add(output, $0)
}

ENDFILE {

    if (!error) @make()
}

function make_print(    h, i, j, k, l) {


    for (i = 1; i <= output["length"]; ++i) {
        Index_push(output[i], " ", " ", "\n", "\n")

        # for (j = 1; j <= NF; ++j) printf " (%d)%s", j, $j; print ""
# Release
#        print

        Index_pop()
    }

}

