#
# Gemeinfrei. Public Domain.
# 2021 Hans Riehm

#include "../make.awk/meta.awk"
#include "../make.awk/make.C.awk"

function C_prepare_preprocess(config,    a,b,c,d,input,output,v) {

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

    if (typeof(includeDirs) == "untyped") {
        # includeDirs["length"]
        List_add(includeDirs, "/usr/include/")
        v = uname_machine()
        if (Compiler == "gcc") {
            List_add(includeDirs, "/usr/include/"v"-linux-gnu/")
            List_add(includeDirs, "/usr/lib/gcc/"v"-linux-gnu/"gcc_version()"/include/")
        }
        else if (Compiler == "tcc")
            List_add(includeDirs, "/usr/lib/"v"-linux-gnu/tcc/include/")
        else __warning("make.awk: Unsupported compiler")
        for (d = 1; d <= config["directories"]["length"]; ++d)
            List_add(includeDirs, config["directories"][d])
    }

    Array_clear(C_defines)
    config["parameters"]["length"]
    for (d in config["parameters"]) {
        if (d == "length" || d ~ /^[0-9]+$/) continue
        if (d ~ /^D.*/) {
            c = substr(d, 2)
            C_defines[c] = config["parameters"][d]
        }
    }

    if (!(Compiler in parsed)) {
        input["name"] = Compiler
        input[++input["length"]] = "# define _GNU_SOURCE 1"
        input[++input["length"]] = "# include <stddef.h>"
        input[++input["length"]] = "# include <stdint.h>"
        input[++input["length"]] = "# include <limits.h>"

        output["name"] = Compiler
        CCompiler_coprocess("-xc -dM -E", input, output)
        List_sort(output)
        CCompiler_coprocess("-xc -E", input, output)

        C_parse(Compiler, output)
    }

    preproc["C"]["length"]
    Array_clear(preproc["C"])
    if (!(Compiler in preproc["C"])) C_preprocess(Compiler)
}

function C_preprocess(fileName,    original, C,  # parsed, preproc, C_defines, C_keywords
    a,b,c,d,e,f,__FILE__Name,g,h,i,ifExpressions,j,k,
    l,lz,m,n,name,o,p,q,r,rendered,s,t,u,v,w,x,y,z,zZ)
{
    if (!C) C = "C"
    if (!original) original = fileName
    if (!(fileName in parsed)) if (!C_parse(fileName)) return

    Index_push("", fixFS, fix, "\0", "\n")

    __FILE__Name = "__FILE__"Index_pull(get_FileName(fileName), @/[ *|+-:$%!?\^\.]+/, "_", "\0", "\0")

    # if (!input["length"]) ++input["length"]

    preproc[C][original]["fields"]["length"]
    if (!(__FILE__Name in preproc[C][original]["fields"]))
        preproc[C][original]["fields"][__FILE__Name]["body"] = "static"fix"char"fix __FILE__Name fix"["fix"]"fix"="fix"\""fileName"\""fix";"

    preproc[C][original][ ++preproc[C][original]["length"] ] = "#"fix 1 fix"\""fileName"\""
    # preproc[C][original][ preproc[C][original]["length"] ] = "#"fix"1"fix"\""fileName"\""" /* Zeile "++preproc[C][original]["length"]" */"

    C_defines["__FILE__"]["body"] = __FILE__Name

    for (z = 1; z <= parsed[fileName]["length"]; ++z) {
        Index_reset(parsed[fileName][z])

        C_defines["__LINE__"]["body"] = z

    if ($1 == "#") {
        #if ($2 ~ /^\s*$/) Index_remove(2)
        if ($2 == "ifdef") {
            $2 = "if"
            for (n = 3; n <= NF; ++n)
                if ($n ~ /^[a-zA-Z_][a-zA-Z_0-9]*$/) {
                    $n = "defined"fix"("fix $n fix")"; Index_reset(); n += 3
                }
        }
        else if ($2 == "ifndef") {
            $2 = "if"
            for (n = 3; n <= NF; ++n)
                if ($n ~ /^[a-zA-Z_][a-zA-Z_0-9]*$/) {
                    $n = "!"fix"defined"fix"("fix $n fix")"; Index_reset(); n += 4
                }
        }
        if ($2 == "if") {
            Index_remove(1, 2)
            for (i = 1; i <= NF; ++i) if ($i ~ /^\s*$/) Index_remove(i--) # clean

            f = List_add(ifExpressions)
            ifExpressions[f]["if"] = $0

            w = CDefine_eval($0)
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

            w = CDefine_eval($0)
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
            List_remove(ifExpressions, f)

            NF = 0
        }
        if (!NF) { ++lz; continue }
    }

        for (e = 1; e <= ifExpressions["length"]; ++e) {
            if (ifExpressions[e]["do"] == 1) continue
            NF = 0; break
        }
        if (!NF) { ++lz; continue }

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
                        zZ = preproc[C][original]["length"]
                        C_preprocess(o, original, C)
                        C_defines["__FILE__"]["body"] = __FILE__Name
                        C_defines["__LINE__"]["body"] = z
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
                    zZ = preproc[C][original]["length"]
                    C_preprocess(m, original, C)
                    C_defines["__FILE__"]["body"] = __FILE__Name
                    C_defines["__LINE__"]["body"] = z
                }
                else __warning(fileName" Line "z": File not found: \""m"\"")
            }
            if (zZ && zZ < preproc[C][original]["length"]) {
                preproc[C][original][ ++preproc[C][original]["length"] ] = "#"fix (z + 1) fix"\""fileName"\""
                # preproc[C][original][ preproc[C][original]["length"] ] = "#"fix (z + 1) fix"\""fileName"\""" /* Zeile "++preproc[C][original]["length"]" */"
                zZ = 0; lz = 0
                continue
            }
            NF = 0
        }
        else if ($2 == "define") {
            if ($3 ~ /^\s*$/) Index_remove(3)
            name = $3
            if (name in C_defines) {
                __warning(fileName" Line "z": define "name" exists already")
            }
            else if (name !~ /^[a-zA-Z_][a-zA-Z_0-9]*$/) {
                __error(fileName" Line "z": define "name" isn't a name")
            }
            else {
                Index_remove(1, 2, 3)
                # define name (void) # constant
                # define name(void)  # expression
                if ($1 == "(") {
                    for (i = 1; i <= NF; ++i) if ($i ~ /^\s*$/) Index_remove(i--) # clean
                    for (n = 2; n <= NF; ++n) {
                        if ($n ~ /^[a-zA-Z_][a-zA-Z_0-9]*$/) {
                            # if ($n in C_defines) __warning(fileName" Line "z": Ambiguous define "name" argument "$n" (define)")
                            # else if ($n in C_types) __warning(fileName" Line "z": Ambiguous define "name" argument "$n" (typedef)")
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
                            # if ($o in C_defines) __warning(fileName" Line "z": Ambiguous define "name" argument "$o" (define)")
                            # if ($o in C_types) __warning(fileName" Line "z": Ambiguous define "name" argument "$o" (typedef)"); else
                            if ($o in C_keywords) __warning(fileName" Line "z": Ambiguous define "name" argument "$o" (keyword)")
                            m = String_concat(m, " ", $o)
                            if ($o == ",") continue
                            g = ++C_defines[name]["arguments"]["length"]
                            C_defines[name]["arguments"][g] = $o
                        }
                        C_defines[name]["arguments"]["text"] = m
                        C_defines[name]["isFunction"] = 1
                        Index_removeRange(1, n)
                    }
                }
                else { for (i = 1; i <= NF; ++i) if ($i ~ /^\s*$/) Index_remove(i--) } # clean

                C_defines[name]["body"] = $0

if (DEBUG == 3 || DEBUG == 4) {
rendered = Index_pull(C_defines[name]["body"], fixFS, " ")
if (C_defines[name]["isFunction"])
__debug(fileName" Line "z": define "name" ("C_defines[name]["arguments"]["text"]")  "rendered)
else
__debug(fileName" Line "z": define "name"  "rendered)
}
            }
            NF = 0
        }
        else if ($2 == "undef" || $2 == "undefine") {
            for (i = 1; i <= NF; ++i) if ($i ~ /^\s*$/) Index_remove(i--) # clean
            name = $3
            if (!(name in C_defines)) __warning(fileName" Line "z": undefine doesn't exist: "name)
            else {
if (DEBUG == 3 || DEBUG == 4) {
rendered = Index_pull(C_defines[name]["body"], fixFS, " ")
if (C_defines[name]["isFunction"])
__debug(fileName" Line "z": undefine "name" ("C_defines[name]["arguments"]["text"]")  "rendered)
else
__debug(fileName" Line "z": undefine "name"  "rendered)
}
                delete C_defines[name]
            }
            NF = 0
        }
        else if ($2 == "warning") {
            for (i = 1; i <= NF; ++i) if ($i ~ /^\s*$/) Index_remove(i--) # clean
            Index_push($0, fixFS, " ")
            __warning(fileName" Line "z": "$0)
            Index_pop()
            NF = 0
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
        if (!NF) { ++lz; continue }
        preproc[C][original][ ++preproc[C][original]["length"] ] = $0; continue
    }

        # for (i = 1; i <= NF; ++i) if ($i ~ /^\s*$/) Index_remove(i--) # clean

        parsed[fileName]["I"] = Index["length"]
        for (i = 1; i <= NF; ++i) {
            if ($i ~ /^\s*$/) continue # no clean, no use
            if ($i in C_defines) {
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
            if ($i ~ /^\/\* ?[^#][a-zA-Z_][a-zA-Z_0-9]* ?\*\/$/) continue # short comments
            if ($i ~ /^\/\*/ || $i ~ /\*\/$/) { Index_remove(i--); continue } # comments
            # if ($i == "\\") { Index_remove(i--); continue }
        }

        if (!NF) { ++lz; continue }

        if (lz <= 3) preproc[C][original]["length"] += lz
        else {
            preproc[C][original]["length"] += 2
            preproc[C][original][ ++preproc[C][original]["length"] ] = "#"fix z fix"\""fileName"\""
            # preproc[C][original][ preproc[C][original]["length"] ] = "#"fix z fix"\""fileName"\""" /* Zeile "++preproc[C][original]["length"]" */"
        }
        lz = 0

        preproc[C][original][ ++preproc[C][original]["length"] ] = $0
    }
    Index_pop()
    return 1
}
