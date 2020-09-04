#!/usr/bin/awk -f
# Gemeinfrei.
# 2020 Hans Riehm

@include "../make.awk/meta.awk"

function usage() {
    __error("Usage: make.ISO_C.awk ./include Program.c")
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
    if (ERRNO) { __error("(BEGINFILE) File doesn't exist: "FILENAME); nextfile }

    FileName = get_FileName(FILENAME)
    Directory = get_DirectoryName(FILENAME)

    inputI = ++input["length"]
    input[inputI]["FILENAME"] = FILENAME
    #input[inputI]["FileName"] = FileName
    #input[inputI]["Directory"] = Directory

    if (!Array_contains(includes, FILENAME)) Array_add(includes, FILENAME)

    inputType = ""

    FS=""
    OFS=""
    RS="\n"
}

{   # Read what you have: this is C

    inputZ = ++input[inputI]["length"]

    hash = ""
    continuation = 0

    for (i = 1; i <= NF; ++i) {
        if (i == 1 && continuation) {
            if (Index_prepend(i, fix, fix)) ++i
            continuation = 0
        }
        if (inputType == "comment") {
            if ($i == "/" && $(i + 1) == "*") {
                $(i++) = "*"
                ++comments
                __error(FILENAME" Line "FNR": Comment in Comment /* /*")
                continue
            }
            if ($i == "*" && $(i + 1) == "/") {
                if (comments) {
                    --comments
                    $(++i) = "*"
                    continue
                } ++i
                inputType = ""
                if (i != NF) if (Index_append(i, fix, fix)) ++i
                continue
            }
            if (i == NF && $i != "\\" && hash ~ /^#/)
            {
                if (i != 1) if (Index_prepend(i, fix, fix)) ++i
                Index_append(i, "\\"); ++i
                __error(FILENAME" Line "FNR": Line Continuation \\ in Comment")
if (DEBUG == 4) { for (h = 1; h <= NF; ++h) { if ($h == fix) printf "|"; else printf "%s ", $h } printf "" }
                input[inputI][inputZ] = input[inputI][inputZ] $0
                continuation = 1; getline; i = 0; continue
            }
            continue
        }
        if (inputType == "string") {
            if (i == NF && $i == "\\") {
                if (i != 1) if (Index_prepend(i, fix, fix)) ++i
                __error(FILENAME" Line "FNR": Line Continuation \\ in String")
if (DEBUG == 4) { for (h = 1; h <= NF; ++h) { if ($h == fix) printf "|"; else printf "%s ", $h } printf "" }
                input[inputI][inputZ] = input[inputI][inputZ] $0
                continuation = 1; getline; i = 0; continue
            }
            if ($i == "\\") {
                # if ($(i + 1) == "\"")
                ++i; continue
            }
            if ($i == "\"") {
                inputType = ""
                if (hash == "# include") {
                    n = Path_join(Directory, string)
                    if (File_exists(n)) {
                        List_insertBefore(includes, FILENAME, n)
                        ARGV_add(n)
                    }
                  # else __error("(preprocess) File doesn't exist: \""n"\"")
                }
                if (i != NF) if (Index_append(i, fix, fix)) ++i
                continue
            }
            string = string $i
            continue
        }
        if (inputType == "include string") {
            if (i == NF && $i == "\\") {
                if (i != 1) if (Index_prepend(i, fix, fix)) ++i
                __error(FILENAME" Line "FNR": Line Continuation \\ in #include <String>")
if (DEBUG == 4) { for (h = 1; h <= NF; ++h) { if ($h == fix) printf "|"; else printf "%s ", $h } printf "" }
                input[inputI][inputZ] = input[inputI][inputZ] $0
                continuation = 1; getline; i = 0; continue
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
              # if (d > includeDirs["length"]) __error("(preprocess) File doesn't exist: <"includeString">")
                if (i != NF) if (Index_append(i, fix, fix)) ++i
                continue
            }
            includeString = includeString $i
            continue
        }
        if (inputType == "character") {
            if (i == NF && $i != "'") {
                Index_append(i, "'"); ++i
            }
            if ($i == "\\") {
                # if ($(i + 1) == "'")
                # if ($(i + 1) == "\\")
                ++i; continue
            }
            if ($i == "'") {
                inputType = ""
                if (i != NF) if (Index_append(i, fix, fix)) ++i
            }
            continue
        }
        # if ($i == fix) continue
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
                Index_remove(i--)
            }
            continue
        }
        if ($i == "\\") {
            if (i != NF) { Index_remove(i--); continue }
            if (i != 1) if (Index_prepend(i, fix, fix)) ++i
          # print FILENAME" Line "FNR": Line Continuation \\">"/dev/stderr"
if (DEBUG == 4) { for (h = 1; h <= NF; ++h) { if ($h == fix) printf "|"; else printf "%s ", $h } printf "" }
            input[inputI][inputZ] = input[inputI][inputZ] $0
            continuation = 1; getline; i = 0; continue
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
        if ( $i == "L" && $(i + 1) == "\"" ) {
            if (i != 1) if (Index_prepend(i, fix, fix)) ++i
            continue
        }
        if ( $i == "\"" ) {
            if (i != 1 && $(i - 1) != "L") if (Index_prepend(i, fix, fix)) ++i
            inputType = "string"
            string = ""
            continue
        }
        if ( $i == "L" && $(i + 1) == "'" ) {
            if (i != 1) if (Index_prepend(i, fix, fix)) ++i
            continue
        }
        if ( $i == "'" ) {
            if (i != 1 && $(i - 1) != "L") if (Index_prepend(i, fix, fix)) ++i
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

__error("Unknown character "$i)
        Index_remove(i--)
    }

    input[inputI][inputZ] = input[inputI][inputZ] $0

if (DEBUG == 4) { for (h = 1; h <= NF; ++h) { if ($h == fix) printf "|"; else printf "%s ", $h } print "" }
}

# ENDFILE { }

END {

if (DEBUG == 4) {
__error( "includeDirs:")
 Array_error(includeDirs)
__error( "includes:")
 Array_error(includes)
}
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

    Array_add(types, "void")
    Array_add(types, "unsigned")
    Array_add(types, "signed")
    Array_add(types, "char")
    Array_add(types, "short")
    Array_add(types, "int")
    Array_add(types, "long")
    Array_add(types, "float")
    Array_add(types, "double")

    precompile(targetDefines)

    for (argI = 1; argI <= origin["length"]; ++argI)
        if (origin[argI])
            precompile(origin[argI])

if (DEBUG == 3) {
for (o = 1; o <= defines["length"]; ++o) { name = defines[o]
Index_push(defines[name]["body"], "", ""); for (m = 1; m <= NF; ++m) if ($m == fix) $m = " "; rendered_defineBody = Index_pop()
if (defines[name]["isFunctional"])
__debug("# define "name" ("defines[name]["arguments"]["text"]")  "rendered_defineBody)
else
__debug("# define "name"  "rendered_defineBody)
}
__error("Types:")
Array_error(types)
}

#    if (!error) @make()
}

function gcc_preprocess(    fileIn, fileOut) {

    fileIn = ".preprocess.C.gcc.c"
    print "/* Gemeinfrei */" > fileIn
    close(fileIn)

    fileOut = ".preprocess.C.gcc...pre.c"
    system("gcc -std=c11 -E "fileIn"  > "fileOut)
    system("gcc -std=c11 -dM -E "fileIn" | sort > "fileOut)

    return fileOut
}

function precompile(fileName,    a, argumentI, b, c, d, defineBody, defineBody1, expressionI, expressions, f, g, h,
                    i, ifExpressions, inputType, inputType1, j, k, l, leereZeilen, m, n, name, noredefines,
                    o, p, q, r, rendered_defineBody, resultI, resultZ, s, t, u, v, w, x, y) # e, z
{
    ifExpressions["length"] = 0

    for (e = 1; e <= input["length"]; ++e)
        if (input[e]["FILENAME"] == fileName ) break
    if (e > input["length"]) { __error("(precompile) File doesn't exist: "fileName); return }

    resultI = ++result["length"]
#    result[resultI]["FILENAME"] = input[e]["FILENAME"]

    if (!Array_contains(defines, "__FILE__")) Array_add(defines, "__FILE__")
    if (!Array_contains(defines, "__LINE__")) Array_add(defines, "__LINE__")
    defines["__FILE__"]["body"] = "\""input[e]["FILENAME"]"\""

    #resultZ = ++result[resultI]["length"]
    #result[resultI][resultZ] = "\n# 1 \""input[e]["FILENAME"]"\""
    print "\n# 1 \""input[e]["FILENAME"]"\""

    inputType = ""

    for (z = 1; z <= input[e]["length"]; ++z) {
        Index_push(input[e][z], fixFS, fix)

        defines["__LINE__"]["body"] = z

        if ($1 == "#") {
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
__debug(input[e]["FILENAME"]" Line "z": (Level "f") if "m"  == "x)
            ifExpressions[f]["if"] = m
            if (x) ifExpressions[f]["do"] = 1
            NF = 0
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
__debug(input[e]["FILENAME"]" Line "z": (Level "f") else if "m"  == "x)
                ifExpressions[f]["do"] = 1
            }
            NF = 0
        }
        if ($2 == "else") {
            f = ifExpressions["length"]
            ifExpressions[f]["else"] = 1
            if (ifExpressions[f]["do"] == 1) ifExpressions[f]["do"] = 2
            if (!ifExpressions[f]["do"]) {
__debug(input[e]["FILENAME"]" Line "z": (Level "f") else")
                ifExpressions[f]["do"] = 1
            }
            NF = 0
        }
        if ($2 == "endif") {
            f = ifExpressions["length"]
__debug(input[e]["FILENAME"]" Line "z": (Level "f") endif")
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
                    name = Path_join(includeDirs[n], m)
                    if (File_exists(name)) {
__debug(input[e]["FILENAME"]" Line "z": including "name)
                        f = e; y = z
                        precompile(name, defines)
                        e = f; z = y
                        defines["__FILE__"]["body"] = "\""input[e]["FILENAME"]"\""
                        defines["__LINE__"]["body"] = z

                        print "# "z + 1" \""input[e]["FILENAME"]"\""
                        break
                    }
                }
                if (n > includeDirs["length"]) __error("File doesn't exist: <"m">")
            }
            else {
                m = get_DirectoryName(input[e]["FILENAME"])
                m = Path_join(m, substr($3, 2, length($3) - 2))
                if (File_exists(m)) {
__debug(input[e]["FILENAME"]" Line "z": including "m)
                    f = e; y = z
                    precompile(m, defines)
                    e = f; z = y
                    defines["__FILE__"]["body"] = "\""input[e]["FILENAME"]"\""
                    defines["__LINE__"]["body"] = z
                }
                else __error("File doesn't exist: \""m"\"")

                print "# "z + 1" \""input[e]["FILENAME"]"\""
            }
            NF = 0
        }
        if ($2 == "define") {
            name = $3
            if (Array_contains(defines, name)) {
                __error(input[e]["FILENAME"]" Line "z": define "name" exists already")
            }
            else {
                Array_add(defines, name)
                Index_remove(1, 2, 3)
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
                            m = String_concat(m, " ", $o)
                            if ($o == ",") continue
                            argumentI = ++defines[name]["arguments"]["length"]
                            defines[name]["arguments"][argumentI] = $o
                        }
                        defines[name]["arguments"]["text"] = m
                        defines[name]["isFunctional"] = 1
                        Index_removeRange(1, n)
                    }
                }

                m = ""; for (n = 1; n <= NF; ++n) {
                    if ($n == "\\") continue
                    if (inputType1 == "comment") {
                        if ($n ~ /\*\/$/) inputType1 = ""
                        continue
                    }
                    if ($n ~ /^\/\*/) {
                        inputType1 = "comment"
                        if ($n ~ /\*\/$/) inputType1 = ""
                        continue
                    }
                    if ($i ~ /^\/\//) break
                    m = String_concat(m, fix, $n)
                }
                defines[name]["body"] = m

Index_push(defines[name]["body"], "", ""); for (m = 1; m <= NF; ++m) if ($m == fix) $m = " "; rendered_defineBody = Index_pop()
if (defines[name]["isFunctional"])
__debug(input[e]["FILENAME"]" Line "z": define "name" ("defines[name]["arguments"]["text"]")  "rendered_defineBody)
else
__debug(input[e]["FILENAME"]" Line "z": define "name"  "rendered_defineBody)

            }
            NF = 0
        }
        if ($2 == "undef") {
            if (!(f = Array_contains(defines, $3))) __error(input[e]["FILENAME"]" Line "z": undef doesn't exist: "$3)
            else {
                Array_remove(defines, f)
                delete defines[$3]
__debug(input[e]["FILENAME"]" Line "z": undef "$3)
            }
            NF = 0
        }
        if (NF > 0) {
            $1 = "/*"$1; $NF = $NF"*/"; Index_reset()
        } }

        for (i = 1; i <= NF; ++i) {

          # if ($i ~ /^[ ]*$/) continue

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

            if (Array_contains(defines, $i)) {
                name = $i

                I = Index["length"]
if (DEBUG == 3) __debug(input[e]["FILENAME"]" Line "z": applying "name)
                n = Define_apply(i, noredefines)
                i += n - 1
            }
        }

        for (i = 1; i <= NF; ++i) {

            if ($i == "typedef") {
                if (expressionI > 0) {
                    # do you need semikolon?
                }
                expressionI = ++expressions["length"]
                expressions[expressionI]["Type"] = "TypeDefine"
            }
            if ($i == "void" ||
                $i == "unsigned" || $i == "signed" ||
                $i == "char" || $i == "short" || $i == "int" || $i == "long" ||
                $i == "float" || $i == "double")
            {
                if (expressions["length"] == 1 && expressions[1]["Type"] == "TypeDefine") { }
                else if (expressions["length"] > 0) {
                    # do you need semikolon?
                }
                expressionI = ++expressions["length"]
                expressions[expressionI]["Type"] = "Type"
                for (n = i + 1; n <= NF; ++n) {
                    if ($n == "void" ||
                        $n == "unsigned" || $n == "signed" ||
                        $n == "char" || $n == "short" || $n == "int" || $n == "long" ||
                        $n == "float" || $n == "double")
                    {
                        $i = String_concat($i, " ", $n); $n = ""; continue
                    }
                    break
                }
                Index_reset()
                if (!Array_contains(types, $i)) Array_add(types, $i)
                continue
            }
            if ($i == "struct") {
                if (expressions["length"] == 1 && expressions[1]["Type"] == "TypeDefine") { }
                else if (expressions["length"] > 0) {
                    # do you need semikolon?
                }
                expressionI = ++expressions["length"]
                expressions[expressionI]["Type"] = "Type"
                if ($(i + 1) ~ /^[[:alpha:]_][[:alpha:]_0-9]*$/) {
                    $i = String_concat($i, " ", $(i + 1)); $(i + 1) = ""; Index_reset()
                    if (!Array_contains(types, $i)) Array_add(types, $i)
                }
                continue
            }

            if ($i == ";") {
                if (!expressionI) {
                    # you don't need semikolon
                }
                Array_clear(expressions)
                continue
            }

        }
        if (NF == 0) ++leereZeilen
        else {
            if (leereZeilen <= 3) for (h = 1; h <= leereZeilen; ++h) print ""
            else { print ""; print ""; print "# "z" \""input[e]["FILENAME"]"\"" }
            leereZeilen = 0

            if (DEBUG == 3) {
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

function Define_apply(i, noredefines,    a, arguments, b, c, d, defineBody, defineBody1, f, g, h, inputType, j, k, l, m,
                                         n, name, notapplied, o, p, q, r, rendered_defineBody, s, t, u, v, w, x, y) # e, z
{
    # Evaluate AWA
    if (Array_contains(defines, $i)) {
        name = $i
        # define AWA AWA
        if (noredefines[name]) {
            __error(input[e]["FILENAME"]" Line "z": self-referencing define "name" "name)
            return 1
        }
        delete noredefines[name]
        # define name ( arg1 , arg2 ) body
        defineBody = defines[name]["body"]
        Array_clear(arguments)
        if (defines[name]["isFunctional"]) {
            l = defines[name]["arguments"]["length"]
            o = i; m = ""; p = 0
            while (++o) {
                if (o > NF) {
                    if (Index["length"] == I && ++z <= input[e]["length"]) {
                        $0 = $0 fix input[e][z]
                        defines["__LINE__"]["body"] = z
                        --o; continue
                    }
                    break
                }
                if (o == i + 1) {
                    if ($o != "(") break
                    continue
                }
                if (!p && $o == ",") {
                    Array_add(arguments, m)
                    m = ""
                    continue
                }
                if ($o == "(" || $o == "{") ++p
                if ($o == ")" || $o == "}") {
                    if (p) --p
                    else { if (l) Array_add(arguments, m); break }
                }
                m = String_concat(m, fix, $o)
            }
            if ($(i + 1) != "(") {
if (DEBUG == 3) __debug(input[e]["FILENAME"]" Line "z": not using "name)
                return 1
            }
            Index_removeRange(i + 1, o)
            if (arguments["length"] < l) __error(input[e]["FILENAME"]" Line "z": using "name": Not enough arguments used")
            else if (arguments["length"] > l && defines[name]["arguments"][l] != "...")
                __error(input[e]["FILENAME"]" Line "z": using "name": Too many arguments used")
#Array_debug(arguments)
            for (n = 1; n <= arguments["length"]; ++n) {
                Index_push(arguments[n], fixFS, fix)
                for (j = 1; j <= NF; ++j) {
                    if (Array_contains(defines, $j)) {
                        if (defines[$j]["isFunctional"] && $(j + 1) != "(") {
if (DEBUG == 3) __debug(input[e]["FILENAME"]" Line "z": 2 not applying "$j)
                            continue
                        }
if (DEBUG == 3) __debug(input[e]["FILENAME"]" Line "z": 2 applying "$j)
                        m = Define_apply(j, noredefines)
                        j += m - 1
                    }
                }
                arguments[n] = Index_pop()
            }
            Index_push(defineBody, fixFS, fix)
            for (n = 1; n <= l; ++n) {
                if (n == l && defines[name]["arguments"][l] == "...") break
                for (o = 1; o <= NF; ++o) {
                    if ($o == defines[name]["arguments"][n]) $o = arguments[n]
                    if (o > 1 && $(o - 1) == "#") { $o = "\""$o"\""; $(o - 1) = "" }
                }
            }
            if (defines[name]["arguments"][l] == "...") {
                for (o = 1; o <= NF; ++o) {
                    if ($o == "__VA_ARGS__") {
                        $o = ""
                        for (n = l; n <= arguments["length"]; ++n)
                            $o = String_concat($o, fix","fix, arguments[n])
                        if (o > 1 && $(o - 1) == "#") { $o = "\""$o"\""; $(o - 1) = "" }
                    }
                }
                Index_reset()
            }
            defineBody = Index_pop()
        }
        Index_push(defineBody, fixFS, fix)
        for (o = 1; o <= NF; ++o) {
            if (inputType == "comment") {
                if ($o ~ /\*\/$/) inputType = ""
                Index_remove(o--)
                continue
            }
            if ($o ~ /^\/\*/) {
                inputType = "comment"
                if ($o ~ /\*\/$/) inputType = ""
                Index_remove(o--)
                continue
            }
            if ($o ~ /^\/\//) {
                NF = o - 1; break
            }
            if ($o == "\\") { Index_remove(o--); continue }
            if ($o == "##") {
                $o = $(o - 1) $(o + 1)
                Index_remove(o - 1, o + 1)
                --o; continue
            }
            if ($o == "#") {
                if ($(o + 1) !~ /^[[:alpha:]_][[:alpha:]_0-9]*$/) {
                    $o = "\"\""
                }
                else {
                    $(o + 1) = "\""$(o + 1)"\""
                    Index_remove(o)
                }
                continue
            }
        }
        defineBody = Index_pop()
        if (defineBody == "") {
            # define unsafe  /* unsafe */
if (DEBUG == 3) __debug(input[e]["FILENAME"]" Line "z": using "name" without body")
            Index_remove(i)
            return 0
        }
        Index_push(defineBody, fixFS, fix)
        ++noredefines[name]
        notapplied = 0
        for (j = 1; j <= NF; ++j) {
            if (Array_contains(defines, $j)) {
                if (defines[$j]["isFunctional"] && $(j + 1) != "(") {
if (DEBUG == 3) __debug(input[e]["FILENAME"]" Line "z": 1 not applying "$j)
                    ++notapplied
                    continue
                }
if (DEBUG == 3) __debug(input[e]["FILENAME"]" Line "z": 1 applying "$j)
                n = Define_apply(j, noredefines)
                j += n-1
            }
        }
        --noredefines[name]
        Index_reset()
        n = NF
        $i = defineBody = Index_pop()
        Index_reset()

if (DEBUG == 3) {
Index_push(defineBody, "", ""); for (m = 1; m <= NF; ++m) if ($m == fix) $m = " "; rendered_defineBody = Index_pop()
if (defines[name]["isFunctional"]) {
__debug(input[e]["FILENAME"]" Line "z": using "name" ("defines[name]["arguments"]["text"]")  "rendered_defineBody)
# Array_debug(arguments)
} else __debug(input[e]["FILENAME"]" Line "z": using "name"  "rendered_defineBody)
}
        return n - notapplied
    }
    return 1
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

