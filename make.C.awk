#
# Gemeinfrei. Public Domain.
# 2020 Hans Riehm

#include "../make.awk/meta.awk"
@include "../make.awk/make.CExpression_evaluate.awk"

function C_prepare(config,    a,b,c,d,input,m,output)
{
    if (typeof(includeDirs) == "untyped") {
        # includeDirs["length"]
        Array_add(includeDirs, "/usr/include/")
        m = uname_machine()
        if (Compiler == "gcc") {
            Array_add(includeDirs, "/usr/include/"m"-linux-gnu/")
            Array_add(includeDirs, "/usr/lib/gcc/"m"-linux-gnu/"gcc_version()"/include/")
        }
        else if (Compiler == "tcc")
            Array_add(includeDirs, "/usr/lib/"m"-linux-gnu/tcc/include/")
        else __warning("make.awk: Unsupported compiler")
    }

    if (typeof(parsed) == "untyped") {
        input["name"] = Compiler
        input[++input["length"]] = "# define _GNU_SOURCE 1"
        input[++input["length"]] = "# include <stddef.h>"
        input[++input["length"]] = "# include <stdint.h>"
        input[++input["length"]] = "# include <limits.h>"

        output["name"] = Compiler
        CCompiler_coprocess("-xc -dM -E", input, output)
      # List_sort(output)
        CCompiler_coprocess("-xc -E", input, output)

        C_parse(Compiler, output)
    }

    Array_clear(preprocessed)

    Array_clear(defines)
    for (d in config) {
        if (d == "length" || d ~ /^[0-9]+$/) continue
        if (d ~ /^D.*/) {
            c = substr(d, 2)
            defines[c] = config[d]
        }
    }

    Array_clear(precompiled)

    Array_clear(types)
    types["void"]["isLiteral"]
    types["unsigned"]["isLiteral"]
    types["signed"]["isLiteral"]
    types["_Bool"]["isLiteral"]
    types["char"]["isLiteral"]
    types["short"]["isLiteral"]
    types["int"]["isLiteral"]
    types["long"]["isLiteral"]
    types["double"]["isLiteral"]
    types["float"]["isLiteral"]
    types["_Float32"]["isLiteral"]
    types["_Float32x"]["isLiteral"]
    types["_Float64"]["isLiteral"]
    types["_Float64x"]["isLiteral"]
    types["_Float128"]["isLiteral"]
    types["__builtin_va_list"]["isLiteral"]

    if (typeof(C_keywords) == "untyped") {
        C_keywords["struct"]
        C_keywords["union"]
        C_keywords["enum"]

        C_keywords["const"]
        C_keywords["volatile"]

        C_keywords["typedef"]
        C_keywords["static"]
        C_keywords["extern"]
        C_keywords["inline"]
        C_keywords["register"]
        C_keywords["auto"]

        C_keywords["restrict"]

        C_keywords["do"]
        C_keywords["while"]
        C_keywords["for"]
        C_keywords["break"]
        C_keywords["continue"]

        C_keywords["if"]
        C_keywords["else"]
        C_keywords["switch"]
        C_keywords["case"]
        C_keywords["goto"]

        C_keywords["sizeof"]
        C_keywords["return"]

        C_keywords["inline"]
        C_keywords["_Noreturn"]

        C_keywords["_Thread"]
    }
}

function C_parse(fileName, input,
    a,b,c,comments,d,directory,e,f,g,h,hash,i,j,k,l,m,n,name,o,p,q,r,s,string,t,u,v,w,was,x,y,z,zahl)
{
if (DEBUG == 2) __debug("Q: C_parse0 File "fileName)
    if ( !input["length"] ) if (!fileName || !File_read(input, fileName)) return
    input["name"] = fileName

    Index_push("", "", "", "\0", "\n")
while (++z <= input["length"]) {
    Index_reset(input[z])

    was = "newline"
    hash = ""

    for (i = 1; i <= NF; ++i) {
        if ($i == "/") {
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            if ($(i + 1) == "*") {
                was = "comment"; comments = 0; ++i
                for (n = i; n <= NF; ++n) {
                    if (n == NF) { Index_append(NF, "\n"); if (++z <= input["length"]) Index_append(NF, input[z]) }
                    if (n != i && $n == "*" && $(n + 1) == "/") {
                        if (comments > 1) {
                            --comments
                             ++n; $n = "*"
                            continue
                        }
                        comments = 0; ++n
                        break
                    }
                    if (n + 1 == NF) { Index_append(NF, "\n"); if (++z <= input["length"]) Index_append(NF, input[z]) }
                    if ($n == "/" && $(n + 1) == "*") {
                        ++comments
                        if (comments > 1) { $n = "*"; __warning(fileName" Line "z": "comments". Comment in Comment /* /*") }
                        continue
                    }
                }
if (DEBUG == 2) __debug(fileName": Line "z":"i".."n": "was)
                i = n
                if (i < NF) if (Index_append(i, fix, fix)) ++i
                continue
            }
            if ($(i + 1) == "/") {
                was = "comment"
                $(++i) = "*"
                while ($NF == "\\") { Index_remove(NF); if (++z <= input["length"]) Index_append(NF, input[z]) }
                Index_append(NF, "*/")
if (DEBUG == 2) __debug(fileName": Line "z":"i": // "was)
                i = NF
                continue
            }
            was = "/"
            if ($(i + 1) == "=") { ++i; was = was"=" }
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "\\") {
            if (i == NF) { Index_remove(i--); if (++z <= input["length"]) Index_append(NF, input[z]); continue }
            if ($(i + 1) == "n") {
                __warning(fileName": Line "z": Stray \\n")
                Index_remove(i, i + 1); --i
                continue
            }
            __error(fileName": Line "z": Stray \\ or \\"$(i + 1))
            Index_remove(i); --i
            continue
        }
        if ($i == "#") {
            if ($(i + 1) == "#") {
                if (i > 1) if (Index_prepend(i, fix, fix)) ++i
                ++i; was = "##"
if (DEBUG == 2) __debug(fileName": Line "z":"i": "was)
                if (i < NF) if (Index_append(i, fix, fix)) ++i
                continue
            }
            if (was == "newline") {
                was = "#"; hash = "#"
                if (i > 1) { Index_removeRange(1, i - 1); i = 1 }
                n = 1; while (++n <= NF) {
                    if ($n ~ /\s/) continue
                    --n; break
                }
                if (n > i) Index_removeRange(i + 1, n)
# if (DEBUG == 2) __debug(fileName": Line "z":"i": "was)
                if (i < NF) if (Index_append(i, fix, fix)) ++i
                continue
            }
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            was = "#"
if (DEBUG == 2) __debug(fileName": Line "z":"i": "was)
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i ~ /\s/) {
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            n = i; while (++n <= NF) {
                if ($n ~ /\s/) continue
                --n; break
            }
if (DEBUG == 2) __debug(fileName": Line "z":"i".."n":")
            i = n
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "L" && $(i + 1) == "\"") {
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            ++i
        }
        if ($i == "\"") {
            if ($(i - 1) != "L") if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            was = "\""
            string = ""
            n = i; while (++n <= NF) {
                if ($n == "\\") {
                    if (n == NF) { Index_remove(n--); if (++z <= input["length"]) Index_append(NF, input[z]); continue }
                    string = string"\\"$(n + 1)
                    ++n; continue
                }
                if ($n == "\"") break
                string = string $n
                if (n == NF) {
                    # $(++NF) = "\\"; $(++NF) = "n"; n += 2
                    # if (++z <= input["length"]) Index_append(NF, input[z])
                    # continue
                    $(++NF) = "\""
                    __warning(fileName": Line "z": String \" without ending \"")
                    break
                }
            }
if (DEBUG == 2) __debug(fileName": Line "z":"i".."n": \""string"\"")
            i = n
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "<") {
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            was = "<"
            if (hash == "# include") {
                string = ""
                n = i; while (++n <= NF) {
                    if ($n == "\\") {
                        if (n == NF) { Index_remove(n--); if (++z <= input["length"]) Index_append(NF, input[z]); continue }
                        string = string"\\"$(n++)
                        continue
                    }
                    if ($n == ">") break
                    string = string $n
                }
if (DEBUG == 2) __debug(fileName": Line "z":"i".."n": # include <"string">")
                i = n
                if (Index_append(i, fix, fix)) ++i
                continue
            }
            if (Compiler == "tcc" && $(i + 1) == "c" && $(i + 2) == "d" && $(i + 3) == ">") {
                was = "##"
if (DEBUG == 2) __debug(fileName": Line "z":"i": "was)
                Index_remove(i + 2, i + 3)
                $i = "#"; $(++i) = "#"
                if (i < NF) if (Index_append(i, fix, fix)) ++i
                continue
            }
            if ($(i + 1) == "<") { ++i; was = was"<" }
            if ($(i + 1) == "=") { ++i; was = was"=" }
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "L" && $(i + 1) == "'") {
            if (Index_prepend(i, fix, fix)) ++i
            ++i
        }
        if ($i == "'") {
            if ($(i - 1) != "L") if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            was = "'"
            string = ""
            n = i; while (++n <= NF) {
                if ($n == "\\") {
                    if (n == NF) { Index_remove(n--); if (++z <= input["length"]) Index_append(NF, input[z]); continue }
                    string = string"\\"$(n++)
                    continue
                }
                if ($n == "'") break
                string = string $n
            }
            i = n
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "*") {
            if ($(i + 1) == "/") {
                __warning(fileName": Line "z": Comment Ending */")
                Index_remove(i, i + 1); --i
                continue
            }
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            was = "*"
            if ($(i + 1) == "=") { ++i; was = was"=" }
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
            else if ($(i + 1) == "=") { ++i; was = was"=" }
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
            # if ( $(i + 1) == "." ) { ++i; was = ".." }
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "(" || $i == "[") {
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            was = $i
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == ")" || $i == "]") {
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            was = $i
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "," || $i == "?" || $i == "~") {
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            was = $i
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == ":") {
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            if ($(i + 1) == ":") { ++i; was = was":" }
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == ";" || $i == "{" || $i == "}") {
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            was = $i
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "+") {
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            if ($(i + 1) ~ /[0-9]/ && was !~ /[0-9]/) continue
            was = "+"
            if ($(i + 1) == "+") { ++i; was = was"+" }
            else if ($(i + 1) == "=") { ++i; was = was"=" }
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i == "-") {
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            if ($(i + 1) ~ /[0-9]/ && was !~ /[0-9]/) continue
            was = "-"
            if ($(i + 1) == ">") { ++i; was = was">" }
            else if ($(i + 1) == "-") { ++i; was = was"-" }
            else if ($(i + 1) == "=") { ++i; was = was"=" }
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        if ($i ~ /[0-9]/) {
            if ($i == "0" && $(i + 1) == "x") {
                i += 2
                zahl = "0x"
                while (++i <= NF) {
                    if ($i == "\\" && i == NF) { Index_remove(i--); if (++z <= input["length"]) Index_append(NF, input[z]); continue }
                    if ($i ~ /[0-9a-fA-F]/) { zahl = zahl $i; continue }
                    --i; break
                }
                while (++i <= NF) {
                    if ($i == "\\" && i == NF) { Index_remove(i--); if (++z <= input["length"]) Index_append(NF, input[z]); continue }
                    if ($i ~ /[ulUL]/) { zahl = zahl $i; continue }
                    --i; break
                }
                if (i < NF) if (Index_append(i, fix, fix)) ++i
                if (hash == "#") hash = "# "zahl
                was = zahl
if (DEBUG == 2) __debug(fileName": Line "z":"i": "was)
                continue
            }
            if ($(i - 1) !~ /[+-]/) if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            zahl = $i
            while (++i <= NF) {
                if ($i == "\\" && i == NF) { Index_remove(i--); if (++z <= input["length"]) Index_append(NF, input[z]); continue }
                if ($i ~ /[0-9]/) { zahl = zahl $i; continue }
                --i; break
            }
            if ($(i + 1) ~ /[uUlL]/) {
                while (++i <= NF) {
                    if ($i == "\\" && i == NF) { Index_remove(i--); if (++z <= input["length"]) Index_append(NF, input[z]); continue }
                    if ($i ~ /[uUlL]/) { zahl = zahl $i; continue }
                    --i; break
                }
                if (i < NF) if (Index_append(i, fix, fix)) ++i
                if (hash == "#") hash = "# "zahl
                was = zahl
if (DEBUG == 2) __debug(fileName": Line "z":"i": "was)
                continue
            }
            if ($(i + 1) == ".") {
                ++i; zahl = zahl $i
                # lies das Fragment
                while (++i <= NF) {
                    if ($i == "\\" && i == NF) { Index_remove(i--); if (++z <= input["length"]) Index_append(NF, input[z]); continue }
                    if ($i ~ /[0-9]/) { zahl = zahl $i; continue }
                    --i; break
                }
            }
            if ($(i + 1) ~ /[eE]/) {
                ++i; zahl = zahl $i
                if ($(i + 1) ~ /[+-]/) { ++i; zahl = zahl $i }
                # lies den Exponent
                while (++i <= NF) {
                    if ($i == "\\" && i == NF) { Index_remove(i--); if (++z <= input["length"]) Index_append(NF, input[z]); continue }
                    if ($i ~ /[0-9]/) { zahl = zahl $i; continue }
                    --i; break
                }
            }
            if ($(i + 1) ~ /[fFlLdD]/) {
                while (++i <= NF) {
                    if ($i == "\\" && i == NF) { Index_remove(i--); if (++z <= input["length"]) Index_append(NF, input[z]); continue }
                    if ($i ~ /[fFlLdD]/) { zahl = zahl $i; continue }
                    if ($i ~ /[0-9]/) { zahl = zahl $i; continue }
                    --i; break
                }
                if ($(i + 1) ~ /[xX]/) { ++i; zahl = zahl $i }
            }
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            was = zahl
            if (hash == "#") hash = "# "zahl
if (DEBUG == 2) __debug(fileName": Line "z":"i": "was)
            continue
        }
        if ($i ~ /[[:alpha:]_]/) {
            if (i > 1) if (Index_prepend(i, fix, fix)) ++i
            name = $i
            n = i; while (++n <= NF) {
                if ($n == "\\" && n == NF) { Index_remove(n--); if (++z <= input["length"]) Index_append(NF, input[z]); continue }
                if ($n ~ /[[:alpha:]_0-9]/) { name = name $n; continue }
                --n; break
            }
            was = name
            if (hash == "#") hash = "# "name
if (DEBUG == 2) __debug(fileName": Line "z":"i".."n": "was)
            i = n
            if (i < NF) if (Index_append(i, fix, fix)) ++i
            continue
        }
        __warning(fileName": Line "z": Unknown Character "$i); Index_remove(i--)
    }

    parsed[fileName][++parsed[fileName]["length"]] = $0
}
    Index_pop()
if (DEBUG == 2) __debug("A: C_parse File "fileName)
    return 1
}

function C_preprocess(fileName, output, # public parsed
    a,b,c,comments,d,e,expression,f,__FILE__Name,g,h,i,I,ifExpressions,j,k,
    l,leereZeilen,level,m,moved,n,name,o,p,q,r,rendered,s,t,u,v,var,varType,w,x,y,z,zZ)
{
    if (!(fileName in parsed)) if (!C_parse(fileName)) return

    Index_push("", fixFS, fix, "\0", "\n")

    Index_push(get_FileName(fileName), @/[ *|+-:$%!?\^\.]+/, "_", "\0", "\0")
    __FILE__Name = "__FILE__"Index_pop()

    # if (!input["length"]) ++input["length"]

    output["fields"]["length"]
    if (!(__FILE__Name in output["fields"]))
        output["fields"][__FILE__Name]["body"] = "static"fix"char"fix __FILE__Name fix"["fix"]"fix"="fix"\""fileName"\""fix";"

    output[++output["length"]] = "#"fix 1 fix"\""fileName"\""
    # output[output["length"]] = "#"fix"1"fix"\""fileName"\""" /* Zeile "++output["length"]" */"

    defines["__FILE__"]["body"] = __FILE__Name

    for (z = 1; z <= parsed[fileName]["length"]; ++z) {
        Index_reset(parsed[fileName][z])

        defines["__LINE__"]["body"] = z

    if ($1 == "#") {
        #if ($2 ~ /^\s*$/) Index_remove(2)
        if ($2 == "ifdef") {
            $2 = "if"
            for (n = 3; n <= NF; ++n)
                if ($n ~ /^[[:alpha:]_][[:alpha:]_0-9]*$/) {
                    $n = "defined"fix"("fix $n fix")"; Index_reset(); n += 3
                }
        }
        else if ($2 == "ifndef") {
            $2 = "if"
            for (n = 3; n <= NF; ++n)
                if ($n ~ /^[[:alpha:]_][[:alpha:]_0-9]*$/) {
                    $n = "!"fix"defined"fix"("fix $n fix")"; Index_reset(); n += 4
                }
        }
        if ($2 == "if") {
            Index_remove(1, 2)
            for (i = 1; i <= NF; ++i) if ($i ~ /^\s*$/) Index_remove(i--) # clean

            f = Array_add(ifExpressions)
            ifExpressions[f]["if"] = $0

            w = CExpression_evaluate($0)
            if (w !~ /^[0-9]+$/) x = 0; else x = w + 0
            if (x) ifExpressions[f]["do"] = 1

if (DEBUG == 3 || DEBUG == 4) {
for (e = 1; e <= ifExpressions["length"]; ++e) { if (ifExpressions[e]["do"] == 1) continue; break }
if (e > f) __debug(fileName" Line "z": (Level "f") if "$0"  == "w" "(ifExpressions[f]["do"] == 1 ? "okay" : "not okay"))
}
            NF = 0
        }
        else if ($2 == "elif" || $2 == "elseif") {
            Index_remove(1, 2)
            for (i = 1; i <= NF; ++i) if ($i ~ /^\s*$/) Index_remove(i--) # clean

            f = ifExpressions["length"]
            ifExpressions[f]["else if"] = $0

            w = CExpression_evaluate($0)
            if (w !~ /^[0-9]+$/) x = 0; else x = w + 0
            if (ifExpressions[f]["do"] == 1) ifExpressions[f]["do"] = 2
            else if (!ifExpressions[f]["do"] && x) ifExpressions[f]["do"] = 1

if (DEBUG == 3 || DEBUG == 4) {
for (e = 1; e <= ifExpressions["length"]; ++e) { if (ifExpressions[e]["do"] == 1) continue; break }
if (e > f) __debug(fileName" Line "z": (Level "f") else if "$0"  == "w" "(ifExpressions[f]["do"] == 1 ? "okay" : "not okay"))
}
            NF = 0
        }
        else if ($2 == "else") {
            f = ifExpressions["length"]
            ifExpressions[f]["else"] = 1

            if (ifExpressions[f]["do"] == 1) ifExpressions[f]["do"] = 2
            else if (!ifExpressions[f]["do"]) ifExpressions[f]["do"] = 1

if (DEBUG == 3 || DEBUG == 4) {
for (e = 1; e <= ifExpressions["length"]; ++e) { if (ifExpressions[e]["do"] == 1) continue; break }
if (e > f) __debug(fileName" Line "z": (Level "f") else "(ifExpressions[f]["do"] == 1 ? "okay" : "not okay"))
}
            NF = 0
        }
        else if ($2 == "endif") {
            f = ifExpressions["length"]
            Array_remove(ifExpressions, f)

            NF = 0
        }
        if (!NF) { ++leereZeilen; continue }
    }

        for (e = 1; e <= ifExpressions["length"]; ++e) {
            if (ifExpressions[e]["do"] == 1) continue
            NF = 0; break
        }
        if (!NF) { ++leereZeilen; continue }

    if ($1 == "#") {
        # if ($2 == "using")
        if ($2 == "include") {
            for (i = 1; i <= NF; ++i) if ($i ~ /^\s*$/) Index_remove(i--) # clean
            if ($3 ~ /^</) {
                m = substr($3, 2, length($3) - 2)
                for (n = 1; n <= includeDirs["length"]; ++n) {
                    o = Path_join(includeDirs[n], m)
                    if (File_exists(o)) {
if (DEBUG == 3 || DEBUG == 4) __debug(fileName" Line "z": including "o)
                        zZ = output["length"]
                        C_preprocess(o, output)
                        defines["__FILE__"]["body"] = __FILE__Name
                        defines["__LINE__"]["body"] = z
                        break
                    }
                }
                if (n > includeDirs["length"]) __warning(fileName" Line "z": File not found: <"m">")
            }
            else {
                m = get_DirectoryName(fileName)
                m = Path_join(m, substr($3, 2, length($3) - 2))
                if (File_exists(m)) {
if (DEBUG == 3 || DEBUG == 4) __debug(fileName" Line "z": including "m)
                    zZ = output["length"]
                    C_preprocess(m, output)
                    defines["__FILE__"]["body"] = __FILE__Name
                    defines["__LINE__"]["body"] = z
                }
                else __warning(fileName" Line "z": File not found: \""m"\"")
            }
            if (zZ && zZ < output["length"]) {
                output[++output["length"]] = "#"fix (z + 1) fix"\""fileName"\""
                # output[output["length"]] = "#"fix (z + 1) fix"\""fileName"\""" /* Zeile "++output["length"]" */"
                zZ = 0; leereZeilen = 0
                continue
            }
            NF = 0
        }
        else if ($2 == "define") {
            if ($3 ~ /^\s*$/) Index_remove(3)
            name = $3
            if (name in defines) {
                __warning(fileName" Line "z": define "name" exists already")
            }
            else if (name !~ /^[[:alpha:]_][[:alpha:]_0-9]*$/) {
                __error(fileName" Line "z": define "name" isn't a name")
            }
            else {
                Index_remove(1, 2, 3)
                # define name (void) # constant
                # define name(void)  # expression
                if ($1 == "(") {
                    for (i = 1; i <= NF; ++i) if ($i ~ /^\s*$/) Index_remove(i--) # clean
                    for (n = 2; n <= NF; ++n) {
                        if ($n ~ /^[[:alpha:]_][[:alpha:]_0-9]*$/) {
                            # if ($n in defines) __warning(fileName" Line "z": Ambiguous define "name" argument "$n" (define)")
                            # else if ($n in types) __warning(fileName" Line "z": Ambiguous define "name" argument "$n" (typedef)")
                            # else if ($n in C_keywords) __warning(fileName" Line "z": Ambiguous define "name" argument "$n" (keyword)")
                            continue
                        }
                        if ($n == ",") continue
                        if ($n == "...") continue
                        if ($n == ")") break
                        break
                    }
                    if ($n != ")") {
                        __warning(fileName" Line "z": define "name" without )")
                    } else {
                        m = ""; for (o = 2; o < n; ++o) {
                            # if ($o in defines) __warning(fileName" Line "z": Ambiguous define "name" argument "$o" (define)")
                            if ($o in types) __warning(fileName" Line "z": Ambiguous define "name" argument "$o" (typedef)")
                            else if ($o in C_keywords) __warning(fileName" Line "z": Ambiguous define "name" argument "$o" (keyword)")
                            m = String_concat(m, " ", $o)
                            if ($o == ",") continue
                            g = ++defines[name]["arguments"]["length"]
                            defines[name]["arguments"][g] = $o
                        }
                        defines[name]["arguments"]["text"] = m
                        defines[name]["isFunction"] = 1
                        Index_removeRange(1, n)
                    }
                }
                else { for (i = 1; i <= NF; ++i) if ($i ~ /^\s*$/) Index_remove(i--) } # clean

                defines[name]["body"] = $0

if (DEBUG == 3 || DEBUG == 4) {
Index_push(defines[name]["body"], fixFS, " "); rendered = Index_pop()
if (defines[name]["isFunction"])
__debug(fileName" Line "z": define "name" ("defines[name]["arguments"]["text"]")  "rendered)
else
__debug(fileName" Line "z": define "name"  "rendered)
}
            }
            NF = 0
        }
        else if ($2 == "undef" || $2 == "undefine") {
            for (i = 1; i <= NF; ++i) if ($i ~ /^\s*$/) Index_remove(i--) # clean
            name = $3
            if (!(name in defines)) __warning(fileName" Line "z": undefine doesn't exist: "name)
            else {
if (DEBUG == 3 || DEBUG == 4) {
Index_push(defines[name]["body"], fixFS, " "); rendered = Index_pop()
if (defines[name]["isFunction"])
__debug(fileName" Line "z": undefine "name" ("defines[name]["arguments"]["text"]")  "rendered)
else
__debug(fileName" Line "z": undefine "name"  "rendered)
}
                delete defines[name]
            }
            NF = 0
        }
        else if ($2 == "warning") {
            for (i = 1; i <= NF; ++i) if ($i ~ /^\s*$/) Index_remove(i--) # clean
            Index_push($0, fixFS, " ")
            __warning(fileName" Line "z": "$0)
            Index_pop()
        #    NF = 0
        }
        else if ($2 == "error") {
            for (i = 1; i <= NF; ++i) if ($i ~ /^\s*$/) Index_remove(i--) # clean
            Index_push($0, fixFS, " ")
            __error(fileName" Line "z": "$0)
            Index_pop()
        #    NF = 0
        }
        else if ($2 == "pragma") {
            for (i = 1; i <= NF; ++i) if ($i ~ /^\s*$/) Index_remove(i--) # clean
            Index_push($0, fixFS, " ")
            __warning(fileName" Line "z": "$0)
            Index_pop()
            NF = 0
        }
        else if ($2 == "line" || $2 ~ /^[+-]?[0-9]+$/) {
            # if ($2 == "line") Index_remove(2)
            NF = 0 # Line Numbers
        }
        else {
            for (i = 1; i <= NF; ++i) if ($i ~ /^\s*$/) Index_remove(i--) # clean
            Index_push($0, fixFS, " ")
            __error(fileName" Line "z": Unknown "$0)
            Index_pop()
            NF = 0
        }
        if (!NF) { ++leereZeilen; continue }
        output[++output["length"]] = $0; continue
    }

        # for (i = 1; i <= NF; ++i) if ($i ~ /^\s*$/) Index_remove(i--) # clean

        parsed[fileName]["I"] = INDEX["length"]
        for (i = 1; i <= NF; ++i) {
            if ($i ~ /^\s*$/) continue # no clean, no use
            if ($i in defines) {
                parsed[fileName]["z"] = z
                n = CDefine_apply(i, parsed[fileName])
                z = parsed[fileName]["z"]
                i += n - 1
            }
        }
        delete parsed[fileName]["I"]

        for (i = 1; i <= NF; ++i) {
            # if ($i ~ /^\s*$/) if (i == 1 || NF != 1) continue # except SPACES
            if ($i ~ /^\s*$/) { Index_remove(i--); continue } # clean
            if ($i ~ /^\/\* ?\w[^#]\w* ?\*\/$/) continue # short comments
            if ($i ~ /^\/\*/) { Index_remove(i--); continue } # comments
            # if ($i == "\\") { Index_remove(i--); continue }
        }

        if (!NF) { ++leereZeilen; continue }

        if (leereZeilen <= 3) output["length"] += leereZeilen
        else {
            output["length"] += 2
            output[++output["length"]] = "#"fix z fix"\""fileName"\""
            # output[output["length"]] = "#"fix z fix"\""fileName"\""" /* Zeile "++output["length"]" */"
        }
        leereZeilen = 0

        output[++output["length"]] = $0
    }
    return 1
}

function __unused0() {

        level = expression["length"]
        if (!level) level = ++expression["length"]
        expression[level]["length"]
        for (i = 1; i <= NF; ++i) {

            # Get typedef struct SomeThing { ... }  * SomeThing ,  * * Array ,  SomeThing ( * function_Delegate ) ( void ) ;

            # and for ISO C also typedef struct SomeThing { ... } SomeThing_t ,  SomeThing_t ( * fun_Action ) ( void ) ;

            # or just struct SomeThing { ... }, even struct { }

            name = ""; s = 0

            if ($i == "__attribute__") {
                if ($(i + 1) == "(")
                    while (++i <= NF) {
                        if ($i == "(") ++k
                        if ($i == ")" && --k == 0) break
                    }
                continue # Ignore
            }
            if ($i == "(") {
                level = ++expression["length"]
                expression[level]["length"]
if (DEBUG == 5) __debug(fileName" Line "z": ++Level == "level" ( "("function" in expression[level - 1] ? "function" : "" ))
                continue
            }
            if ($i == ")") {
                delete expression[level]
                level = --expression["length"]
                expression[level]["length"]
if (DEBUG == 5) __debug(fileName" Line "z": --Level == "level" )")
                continue
            }
            if ($i == "{") {
                level = ++expression["length"]
                expression[level]["length"]
                file[++file["length"]] = Index_removeRange(1, i)
                i = 0
                if (level > 1 && "function" in expression[level - 1]) {
                    expression[level - 1]["expression"]
                }
if (DEBUG == 5) __debug(fileName" Line "z": ++Level == "level" { "("expression" in expression[level - 1] ? "expression" :
    ("struct" in expression[level - 1] ? "struct" : "" )))
                continue
            }
            if ($i == "," && level > 1 && ("function" in expression[level - 1] ||
                ("struct" in expression[level - 1] && expression[level - 1]["Type"] ~ /^enum/)))
            {
                Array_clear(expression[level])
                expression[level]["length"]
                continue
            }
            if ($i == ";") {
                # if (!e) ; # you don't need semikolon
                Array_clear(expression[level])
                expression[level]["length"]
                file[++file["length"]] = Index_removeRange(1, i)
                i = 0
                continue
            }
            if ($i == "typedef") {
                # if (level > 1) __error()
                # if (e > 0) ; # do you need semikolon?
                if ("isTypedef" in expression[level]) {
if (DEBUG == 5) __debug(fileName" Line "z": isTypedef is already "expression[level]["isTypedef"]". Missing Semikolon?")
                    Index_append(--i, ";")
                    continue
                }
                expression[level]["isTypedef"]
                continue
            }
            if ($i == "}") {
                delete expression[level]
                level = --expression["length"]
                expression[level]["length"]
                if (i > 1) {
                    file[++file["length"]] = Index_removeRange(1, i - 1)
                    i = 1
                }
if (DEBUG == 5) __debug(fileName" Line "z": --Level == "level" }")
                if ("expression" in expression[level]) {
                    Array_clear(expression[level])
                    expression[level]["length"]
                    file[++file["length"]] = Index_removeRange(1, i)
                    i = 0
                    continue
                }
                if (!("struct" in expression[level])) continue
            }
            if ($i == "const" || $i == "volatile" || $i in types || $i == "struct" || $i == "union" || $i == "enum")
            {
                if ("Type" in expression[level] && expression[level]["Type"]) {
if (DEBUG == 5) __debug(fileName" Line "z": name "name" is already "expression[level]["Type"]". Missing semikolon?")
                    Index_append(--i, ";")
                    continue
                }
                for (n = i; n <= NF; ++n) {
                    #$n == "extern" || $n == "static" || $n ~ /^_?_?[iI]nline$/
                    if ($n == "const" || $n == "volatile") {
                        if (n > i) { $i = String_concat($i, " ", $n); Index_remove(n--) }
                        continue
                    }
                    --n; break
                }
                if (n >= i) ++i
                for (n = i; n <= NF; ++n) {
                    if ($n in types && "isLiteral" in types[$n]) {
                        s = 1; name = String_concat(name, " ", $n)
                        if (n > i) { $i = String_concat($i, " ", $n); Index_remove(n--) }
                        continue
                    }
                    if (name == "" && ($n in types)) {
                        if ("isLiteral" in types[$n]) s = 1
                        name = $n
                        if (n > i) { $i = String_concat($i, " ", $n); Index_remove(n--) }
                        break
                    }
                    if (name == "" && ($n == "struct" || $n == "union" || $n == "enum")) {
                        s = 1; name = $n
                        if (n > i) { $i = String_concat($i, " ", $n); Index_remove(n--) }
                        if ($(n + 1) in C_keywords) break
                        if ($(n + 1) !~ /^[[:alpha:]_][[:alpha:]_0-9]*$/) break
                        name = String_concat(name, " ", $(++n))
                        if (n > i) { $i = String_concat($i, " ", $n); Index_remove(n--) }
                        break
                    }
                    --n; break
                }
                if (name == "" || name == "struct" || name == "union" || name == "enum") {
                    if (n < i) --i
                    # if (n >= i) Index_remove(i--)
                    __warning(fileName" Line "z": "$i" without name")
                }
                else if (level == 1 && !(name in types) ) {
if (DEBUG == 5) __debug(fileName" Line "z": "name)
                    if (s) types[name]["isLiteral"]
                    else types[name]["baseType"]
                }

                expression[level]["Type"] = name

                if ("isTypedef" in expression[level]) {
if (expression[level]["isTypedef"])
if (DEBUG == 5) __debug(fileName" Line "z": isTypedef is already "expression[level]["isTypedef"])
                    expression[level]["isTypedef"] = $i
                }

                # if ($(n + 1) == ";" || $(n + 1) in C_keywords) continue
                if ($(n + 1) == "{") {
                    expression[level]["struct"]
if (DEBUG == 5) __debug(fileName" Line "z": delay "name" "$(n + 1))
                    continue
                }
            }
            if (name || ("struct" in expression[level] && $i == "}") || ("isTypedef" in expression[level] && $i == ",")) {
                if ($i == "}" || $i == ",") {
                    name = expression[level]["Type"]
if (DEBUG == 5) __debug(fileName" Line "z": continue "$i" "name)
                    # if ($(i + 1) == ";" || $(i + 1) in C_keywords) continue
                }

                var = varType = ""; k = o = p = 0

                for (n = ++i; n <= NF; ++n) {
                    if (var == "" && !o && $n == "(") {
                        ++k; varType = String_concat(varType, " ", $n)
                        if (n > i) { $i = String_concat($i, " ", $n); Index_remove(n--) }
                        continue
                    }
                    if (var == "" && !o && $n == "*") {
                        ++p; varType = String_concat(varType, " ", $n)
                        if (n > i) { $i = String_concat($i, " ", $n); Index_remove(n--) }
                        if ($(n + 1) == "const")
                            if (n + 1 > i) { $i = String_concat($i, " ", $(n + 1)); Index_remove(n + 1) }
                        if ($(n + 1) == "__restrict")
                            if (n + 1 > i) { $i = String_concat($i, " ", $(n + 1)); Index_remove(n + 1) }
                        continue
                    }
                    if (var == "" && !o && $n ~ /^[[:alpha:]_][[:alpha:]_0-9]*$/) {
                        var = $n
                        if (n > i) { $i = String_concat($i, " ", $n); Index_remove(n--) }
                        if (!k) break
                        continue
                    }
                    if (k && $n == ")") {
                        --k; ++o; varType = String_concat(varType, " ", $n)
                        if (n > i) { $i = String_concat($i, " ", $n); Index_remove(n--) }
                        if (!k) break
                        continue
                    }
                    --n; break
                }
                if (var == "") {
                    if (n < i) --i
                    if (level == 1 && "isTypedef" in expression[level]) {
if (DEBUG == 5) __debug(fileName" Line "z": typedef "name"  without var")
                    }
else if (DEBUG == 5) __debug(fileName" Line "z": "name"  without var")
                    continue
                }

                if (level == 1 && "isTypedef" in expression[level]) {
                    name = expression[level]["isTypedef"]

                    if (!(var in types)) {
                        types[var]["baseType"] = String_concat(name, " ", varType)
                        if (name in types && "isLiteral" in types[name] && !p)
                            types[var]["isLiteral"]
if (DEBUG == 5) __debug(fileName" Line "z": typedef "var": "name"  "varType)
                    }
else if (DEBUG == 5) __debug(fileName" Line "z": typedef "var": "name" override, with  "varType)
                }
                # else expression[level]["var"] = var

                if ($(n + 1) == "(") {
if (DEBUG == 5) if ("function" in expression[level]) __debug(fileName" Line "z": function "var" is already "expression[level]["function"])
                    expression[level]["function"]
if (DEBUG == 5) __debug(fileName" Line "z": function: "name"  "$i)
                }
else if (!("isTypedef" in expression[level])) if (DEBUG == 5) __debug(fileName" Line "z": var: "name (varType ? "  "varType : "") (var ? "  "var : "  without var"))
                continue
            }

if (DEBUG == 5) __debug(fileName" Line "z": unknown i("i"): "$i ($i == "" ? " (empty)" : ""))
        }

}

function C_precompile(fileName, output,   h,i,input,m,n,z)
{
    input["length"]
    if (!(Compiler in input))
         C_preprocess(Compiler, input)
    if (!C_preprocess(fileName, input)) return

    # C_precompile is PROTOTYPE

    # input["fields"]["length"]
    for (n in input["fields"]) {
        if (n == "length" || n ~ /^[0-9]+$/) continue
        if (typeof(input["fields"][n]) == "array")
            output[++output["length"]] = input["fields"][n]["body"]
    }

    for (z = 1; z <= input["length"]; ++z)
        output[++output["length"]] = input[z]

    return 1
}

function C_compile(output,    a,b,c,n,o,options,p,pprecompiled,x,y,z)
{
    Index_push("", fixFS, " ", "\0", "\n")
    for (z = 1; z <= precompiled["C"]["length"]; ++z)
        pprecompiled[++pprecompiled["length"]] = Index_reset(precompiled["C"][z])
    Index_pop()

    options = ""
    options = options" -c -fPIC"
    if (Compiler == "gcc") options = options" -xc -fpreprocessed"

    if (CCompiler_coprocess(options, pprecompiled, ".make.o")) return

    File_read(output, ".make.o", "\n", "\n")
    File_remove(".make.o", 1)
    return 1
}

function gcc_version(    m,n,o,output) {
    output["length"]
    __pipe("gcc", "-dumpversion", output)
    return output[1]
}

function uname_machine(    m,n,o,output) {
    output["length"]
    __pipe("uname", "-m", output)
    return output[1]
}

function configure_sh(    m,n,o,output) {
    output["length"]
    __pipe("./configure", "", output)
    return output[1]
}

function CCompiler_coprocess(options, input, output,    a,b,c,command,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) {
    if (typeof(input) == "string" && input) options = options" "input
    else options = options" -"
    if (typeof(output) == "string" && output) options = options" -o "output
    return __coprocess(Compiler, options, input, output)
}

function __gcc_sort_coprocess(options, input, output,    a,b,c,command,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) {
    if (typeof(input) == "string" && input) options = options" "input
    else options = options" -"
    if (typeof(output) == "string" && output) options = options" -o "output
    command = "gcc -xc "options" | sort"
    if (typeof(input) == "array")
        for (i = 1; i <= input["length"]; ++i)
            print input[i] |& command
    else print "" |& command
    close(command, "to")
    Index_push("", "", "", "\n", "\n")
    while (0 < y = ( command |& getline ))
        if (typeof(output) == "array")
            output[++output["length"]] = $0
    Index_pop()
    if (y == -1) { __error("Command doesn't exist: "command); return }
    return close(command)
}
