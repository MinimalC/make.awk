#
# Gemeinfrei. Public Domain.
# 2021 Hans Riehm

#include "run.awk"
#include "make.C.awk"
@include "make.CDefine_eval.awk"

function uname_machine(    __,output) {
    output["length"]
    __command("uname", "-m", output)
    return output[1]
}

function gcc_version(    __,output) {
    output["length"]
    __command("gcc", "-dumpversion", output)
    return output[1]
}

function C_prepare_preprocess(config, C,    __,a,assert_h,b,c,d,dir,e,f,file,g,h,i,input,j,k,l,m,n,name,o,output,p,q,r,s,t,u,v,w,x,y,z)
{
    if (!C) C = "C"

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

        C_keywords["_Noreturn"]

        C_keywords["_Thread"]

        C_keywords["__VA_ARGS__"]
    }

    List_create(includeDirs)
    # List_clear(includeDirs)
    if (!includeDirs["length"]) {
        v = uname_machine()
        List_add(includeDirs, "/usr/include/")
        List_add(includeDirs, "/usr/include/"v"-linux-gnu/")

        if (Compiler == "tcc")
            List_add(includeDirs, "/usr/lib/"v"-linux-gnu/tcc/include/")
        else {
            if (Compiler != "gcc") __warning("make.awk: Unsupported compiler")
            List_add(includeDirs, "/usr/lib/gcc/"v"-linux-gnu/"gcc_version()"/include/")
        }

        for (d = 1; d <= config["directories"]["length"]; ++d)
            if (Directory_exists((dir = config["directories"][d])"include/")) {
                List_add(includeDirs, dir)
                List_add(includeDirs, dir"include/")
            } else if (Directory_exists(dir))
                List_add(includeDirs, dir)

        if (d > config["directories"]["length"])
            for (f = 1; f <= config["files"]["length"]; ++f)
                # use the first file's directory, if there is one, add also to config
                if (dir = get_DirectoryName(config["files"][f])) { List_add(includeDirs, dir); List_add(config["directories"], dir); break }
    }

    Array_clear(C_defines)
    config["parameters"]["length"]
    for (d in config["parameters"]) {
        if (d == "length" || d ~ /^[0-9]+$/) continue
        if (d !~ /^D.+/) continue
        C_defines[c = substr(d, 2)]["value"] = config["parameters"][d]
    }

    Array_create(parsed)
    if (!parsed[Compiler]["length"]) {
        Array_clear(input)
        input[++input["length"]] = "# define _GNU_SOURCE 1"
        input[++input["length"]] = "# include <stddef.h>"
        input[++input["length"]] = "# include <stdint.h>"
        input[++input["length"]] = "# include <limits.h>"

        Array_clear(output)
        output["name"] = Compiler
        CCompiler_coprocess("-xc -dM -E", input, output)
        List_sort(output)
        CCompiler_coprocess("-xc -E", input, output)

        C_parse(Compiler, output)
    }
    if (!parsed[Compiler".custom.h"]["length"]) {
        Array_clear(input)
        input[++input["length"]] = "# undef NULL"
        input[++input["length"]] = "# define NULL  0"
        input[++input["length"]] = "# noundef NULL"

        input[++input["length"]] = "# if defined ( NDEBUG )"
        input[++input["length"]] = "# noundefine NDEBUG"
        input[++input["length"]] = "# define assert( e )"
        input[++input["length"]] = "# else"
        input[++input["length"]] = "/* GLIBC 7 assert.h: This prints an \"Assertion failed\" message and aborts. */"\
    " extern void  __assert_fail ( const char  * __assertion, const char  * __file, unsigned int  __line, const char  * __function )"\
    " __attribute__ (( __nothrow__ , __leaf__ )) __attribute__ (( __noreturn__ )) ;"
        input[++input["length"]] = "# define assert( e )  if ( ! ( e ) ) __assert_fail ( # e , __FILE__ , __LINE__ , __FUNCTION__ ) ;"
        input[++input["length"]] = "# endif"
        input[++input["length"]] = "# noundefine assert"

        C_parse(Compiler".custom.h", input)
    }
    if (C == "C" && !parsed["."Project".config.h"]["length"]) {
        name = ""
        for (d = 1; d <= config["directories"]["length"]; ++d) {
            dir = config["directories"][d]
            #output["name"] = "configure"
            name = Project".config.awk"; if (File_exists(dir name)) break
            name = "configure.sh"; if (File_exists(dir name)) break
            name = "configure"; if (File_exists(dir name)) break
            name = ""
        }
        if (name == Project".config.awk") __warning("make.awk: Using "name) # run_awk(Project".config.awk", "configure_"Project, config)
        else if (!name) __warning("make.awk: "Project".config.awk or configure shell script not found")
        #else __warning("make.awk: Using "name)
#if (DEBUG) if (output["length"]) File_printTo(output, "/dev/stderr")

        Array_clear(output)
        if (!output["length"]) { file = "."Project".config.h"; if (File_exists(dir file)) File_read(output, dir file) }
        if (!output["length"]) { file = ".config.h"; if (File_exists(dir file)) File_read(output, dir file) }
        if (!output["length"]) { file = "config.h"; if (File_exists(dir file)) File_read(output, dir file) }
        if (!output["length"]) {
            if (name == Project".config.awk") ; # say nothing
            else if (!name) ; # say nothing
            else __warning("make.awk: Use "name" to create a "file)
        } else {
            C_parse(dir file, output)
            output["name"] = dir file
             __warning("make.awk: Using "file)
        }
    }

    if (C == "CSharp" && !parsed["CLI"]["length"]) {
        parsed["CLI"]["name"] = "CLI"
        ++parsed["CLI"]["length"] # TODO
    }

    preproc["C"]["length"]
    # Array_clear(preproc["C"])
}

function C_preprocess(fileName,    original, C,  # parsed, preproc, C_defines, C_keywords
    __,a,b,c,d,e,f,__FILE__Name,g,h,i,ifExpressions,j,k,l,lz,m,n,name,o,O,OLD_defines,p,q,r,rendered,s,t,u,v,w,x,y,z,zZ)
{
    if (!C) C = "C"
    if (typeof(fileName) != "string" || !fileName) { __error("make.awk: C_preprocess without fileName"); return }
    if (original) O = original
    else {
        O = fileName
        if (C == "C") {
            C_preprocess(Compiler, O, C)
            C_preprocess(Compiler".custom.h", O, C)
            C_preprocess("."Project".config.h", O, C)
        }
        else if (C == "CSharp") { # TODO
            C_preprocess("CLI", O, C)
        }
        else __error("make.awk: C_preprocess: Unknown "C)
    }

    if (!(fileName in parsed)) if (!C_parse(fileName)) return
    if (!parsed[fileName]["length"]) return

    Index_push("", REFIX, FIX, "\0", "\n")

    preproc[C][O]["length"]
    if (!original) if (!List_contains(preproc[C], O)) preproc[C][ ++preproc[C]["length"] ] = O

    __FILE__Name = "__FILE__"Index_pull(get_FileName(fileName), @/[ *|+:$%!?\^\.\-]/, "_")
    if (!(__FILE__Name in preproc[C]) || preproc[C][__FILE__Name] != fileName) {
        for (f = 1; f < MAX_INTEGER; ++f) {
            n = __FILE__Name (f == 1 ? "" : f)
            if (n in preproc[C] && preproc[C][n] !~ "\""fileName"\"") continue
            break
        }
        if (f == MAX_INTEGER) { __error("C_preprocess: Too many files named \""__FILE__Name"\""); return }
        preproc[C][__FILE__Name] = "static"FIX"const"FIX"char"FIX (__FILE__Name = n) FIX"["FIX"]"FIX"="FIX"\""fileName"\""FIX";"
    }

    preproc[C][O][ ++preproc[C][O]["length"] ] = "#"FIX 1 FIX"\""fileName"\""
    # preproc[C][O][ preproc[C][O]["length"] ] = "#"FIX"1"FIX"\""fileName"\""" /* Zeile "++preproc[C][O]["length"]" */"

    C_defines["__FILE__"]["value"] = __FILE__Name

    for (z = 1; z <= parsed[fileName]["length"]; ++z) {
        Index_reset(parsed[fileName][z])

        C_defines["__LINE__"]["value"] = z

    if ($1 == "#") {
        if ($2 == "ifdef") {
            $2 = "if"
            for (n = 3; n <= NF; ++n) {
                if ($n ~ /^\s*$/) { Index_remove(n--); continue } # clean
                if ($n ~ /^\/\*/ || $n ~ /\*\/$/) { Index_remove(n--); continue } # comments
                if (is_CName($n)) {
                    $n = "defined"FIX"("FIX $n FIX")"; Index_reset(); n += 3
                }
            }
        }
        else if ($2 == "ifndef") {
            $2 = "if"
            for (n = 3; n <= NF; ++n) {
                if ($n ~ /^\s*$/) { Index_remove(n--); continue } # clean
                if ($n ~ /^\/\*/ || $n ~ /\*\/$/) { Index_remove(n--); continue } # comments
                if (is_CName($n)) {
                    $n = "!"FIX"defined"FIX"("FIX $n FIX")"; Index_reset(); n += 4
                }
            }
        }
        if ($2 == "if") {
            Index_remove(1, 2)
            for (n = 1; n <= NF; ++n) {
                if ($n ~ /^\s*$/) { Index_remove(n--); continue } # clean
                if ($n ~ /^\/\*/ || $n ~ /\*\/$/) { Index_remove(n--); continue } # comments
            }

            f = ++ifExpressions["length"]
            ifExpressions[f]["if"] = Index_pull($0, REFIX, " ")

            w = CDefine_eval($0)
            if (w !~ /^[0-9]+$/) x = 0; else x = w + 0
            if (x) ifExpressions[f]["do"] = 1

if (DEBUG == 3 || DEBUG == 4) {
for (e = 1; e <= ifExpressions["length"]; ++e) { if (ifExpressions[e]["do"] == 1) continue; break }
if (e > f) __debug(fileName" Line "z": (Level "f") if " ifExpressions[f]["if"] "  == "w" "(ifExpressions[f]["do"] == 1 ? "okay" : "not okay"))
}
            NF = 0
        }
        else if ($2 == "elif" || $2 == "elseif" || ($2 == "else" && $3 == "if")) {
            if ($3 == "if") Index_remove(1, 2, 3); else Index_remove(1, 2)
            for (n = 1; n <= NF; ++n) {
                if ($n ~ /^\s*$/) { Index_remove(n--); continue } # clean
                if ($n ~ /^\/\*/ || $n ~ /\*\/$/) { Index_remove(n--); continue } # comments
            }

            f = ifExpressions["length"]
            ifExpressions[f]["else if"] = Index_pull($0, REFIX, " ")

            w = CDefine_eval($0)
            if (w !~ /^[0-9]+$/) x = 0; else x = w + 0
            if (ifExpressions[f]["do"] == 1) ifExpressions[f]["do"] = 2
            else if (!ifExpressions[f]["do"] && x) ifExpressions[f]["do"] = 1

if (DEBUG == 3 || DEBUG == 4) {
for (e = 1; e <= ifExpressions["length"]; ++e) { if (ifExpressions[e]["do"] == 1) continue; break }
if (e > f) __debug(fileName" Line "z": (Level "f") else if " ifExpressions[f]["else if"] "  == "w" "(ifExpressions[f]["do"] == 1 ? "okay" : "not okay"))
}
            NF = 0
        }
        else if ($2 == "else") {
            Index_remove(1)

            f = ifExpressions["length"]
            ifExpressions[f]["else"] = Index_pull($0, REFIX, " ")

            if (ifExpressions[f]["do"] == 1) ifExpressions[f]["do"] = 2
            else if (!ifExpressions[f]["do"]) ifExpressions[f]["do"] = 1

if (DEBUG == 3 || DEBUG == 4) {
for (e = 1; e <= ifExpressions["length"]; ++e) { if (ifExpressions[e]["do"] == 1) continue; break }
if (e > f) __debug(fileName" Line "z": (Level "f") else "(ifExpressions[f]["else"]?ifExpressions[f]["else"]" ":(ifExpressions[f]["if"]?ifExpressions[f]["if"]" ":""))\
(ifExpressions[f]["do"] == 1 ? "okay" : "not okay"))
}
            NF = 0
        }
        else if ($2 == "endif" || $2 == "end") {
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
        if ($2 == "include" || $2 == "using") {
            for (i = 1; i <= NF; ++i) if ($i ~ /^\s*$/) Index_remove(i--) # clean
            if ($3 ~ /^</) {
                m = substr($3, 2, length($3) - 2)
                for (n = 1; n <= includeDirs["length"]; ++n) {
                    f = Path_join(includeDirs[n], m)
                    if (File_exists(f)) {
                        if ($2 == "using") {
                            d = Index_pull(get_FileNameNoExt(m), @/[ *|+:$%!?\^\.\-]/, "_")
if (DEBUG == 3 || DEBUG == 4) __debug(fileName" Line "z": using "d)
                            C_defines["using_"d]["value"]
                        }
if (DEBUG == 3 || DEBUG == 4) __debug(fileName" Line "z": including "f)
                        zZ = preproc[C][O]["length"]
                        C_preprocess(f, O, C)
                        C_defines["__FILE__"]["value"] = __FILE__Name
                        C_defines["__LINE__"]["value"] = z
                        break
                    }
                }
                if (n > includeDirs["length"]) __warning(fileName" Line "z": File not found: <"m">")
            }
            else {
                m = get_DirectoryName(fileName)
                f = Path_join(m, substr($3, 2, length($3) - 2))
                if (File_exists(f)) {
                    if ($2 == "using") {
                        d = Index_pull(get_FileNameNoExt(f), @/[ *|+:$%!?\^\.\-]/, "_")
if (DEBUG == 3 || DEBUG == 4) __debug(fileName" Line "z": using "d)
                        C_defines["using_"d]["value"]
                    }
if (DEBUG == 3 || DEBUG == 4) __debug(fileName" Line "z": including "f)
                    zZ = preproc[C][O]["length"]
                    C_preprocess(f, O, C)
                    C_defines["__FILE__"]["value"] = __FILE__Name
                    C_defines["__LINE__"]["value"] = z
                }
                else __warning(fileName" Line "z": File not found: \""f"\"")
            }
            if (zZ && zZ < preproc[C][O]["length"]) {
                preproc[C][O][ ++preproc[C][O]["length"] ] = "#"FIX (z + 1) FIX"\""fileName"\""
                # preproc[C][O][ preproc[C][O]["length"] ] = "#"FIX (z + 1) FIX"\""fileName"\""" /* Zeile "++preproc[C][O]["length"]" */"
                zZ = 0; lz = 0
                continue
            }
            NF = 0
        }
        else if ($2 == "define") {
            for (n = 3; n <= NF; ++n) {
                if ($n ~ /^\s*$/) { Index_remove(n--); continue } # clean
                if ($n ~ /^\/\*/ || $n ~ /\*\/$/) { Index_remove(n--); continue } # comments
                break # define just before name
            }
            name = $3
            if (!is_CName(name))
                __error(fileName" Line "z": define "name" isn't a name")
            else if (name in C_defines)
                __warning(fileName" Line "z": noredefine "name)
            else {
                #if (name in C_defines) {
                #    __warning(fileName" Line "z": redefining "name)
                #    OLD_defines[name]["value"]
                #    Dictionary_copy(C_defines[name], OLD_defines[name])
                #    delete C_defines[name]
                #}
                Index_remove(1, 2, 3)
                zZ = 0
                # define name (void) # constant
                # define name(void)  # expression
                if ($1 == "(") {
                    for (a = 2; a <= NF; ++a) {
                        if ($a ~ /^\s*$/) continue
                        if (is_CName($a)) continue
                        if ($a == ",") continue
                        if ($a == "...") continue
                        if ($a == ")") break
                        break
                    }
                    if ($a != ")") {
                        __warning(fileName" Line "z": define "name" without )")
                        Index_insert(a, ")")
                    }
                    m = ""; for (n = 2; n < a; ++n) {
                        if ($n ~ /^\s*$/) { Index_remove(n--); a--; continue } # clean
                        if ($n in C_defines) __warning(fileName" Line "z": Ambiguous define "name" argument \""$n"\" (is a define)"); else
                        if ($n in C_keywords) __warning(fileName" Line "z": Ambiguous define "name" argument \""$n"\" (is a keyword)")
                        m = String_concat(m, " ", $n)
                        if ($n == ",") continue
                        C_defines[name]["arguments"][ ++C_defines[name]["arguments"]["length"] ] = $n
                    }
                    C_defines[name]["arguments"]["text"] = m
                    Index_removeRange(1, a)
                    if ($1 == ":") {
                        Index_remove(1)
                        zZ = z; m = $0; while (++zZ <= parsed[fileName]["length"]) {
                            if (parsed[fileName][zZ] ~ /^#/) break
                            m = String_concat(m, FIX"\n"FIX, parsed[fileName][zZ])
                        }
                        if (parsed[fileName][zZ] !~ "^#"FIX"end" && parsed[fileName][zZ] != "#") {
                            __warning(fileName" Line "z": # define "name"( "C_defines[name]["arguments"]["text"]" ): doesn't # end")
                        }
                        if (zZ > parsed[fileName]["length"]) {
                            __warning(fileName" Line "z": # define "name"( "C_defines[name]["arguments"]["text"]" ): without # end")
                            zZ = 0
                        }
                        else Index_reset(m)
                    }
                }

                for (i = 1; i <= NF; ++i) if ($i ~ /^\s*$/) Index_remove(i--) # clean

                C_defines[name]["value"] = $0

if (DEBUG == 3 || DEBUG == 4) {
rendered = Index_pull(C_defines[name]["value"], REFIX, " ")
if ("arguments" in C_defines[name])
__debug(fileName" Line "z": define "name" ("C_defines[name]["arguments"]["text"]")  "rendered)
else
__debug(fileName" Line "z": define "name"  "rendered)
}
                if (zZ) z = zZ
            }
            NF = 0
        }
        else if ($2 == "noundef" || $2 == "noundefine") {
            for (i = 1; i <= NF; ++i) if ($i ~ /^\s*$/) Index_remove(i--) # clean
            name = $3
            if (!(name in C_defines)) __warning(fileName" Line "z": noundefine doesn't exist: "name)
            else C_defines[name]["noundefine"]
            NF = 0
        }
        else if ($2 == "undef" || $2 == "undefine") {
            for (i = 1; i <= NF; ++i) if ($i ~ /^\s*$/) Index_remove(i--) # clean
            name = $3
            if (!(name in C_defines)) __warning(fileName" Line "z": undefine doesn't exist: "name)
            else if ("noundefine" in C_defines[name]) __warning(fileName" Line "z": noundefine "name)
            else {
if (DEBUG == 3 || DEBUG == 4) {
rendered = Index_pull(C_defines[name]["value"], REFIX, " ")
if ("arguments" in C_defines[name])
__debug(fileName" Line "z": undefine "name" ("C_defines[name]["arguments"]["text"]")  "rendered)
else
__debug(fileName" Line "z": undefine "name"  "rendered)
}
                delete C_defines[name]
            }
            NF = 0
        }
        else if ($2 == "warning" || $2 == "info") {
            rendered = Index_pull($0, REFIX, "")
            __warning(fileName" Line "z": "rendered)
            NF = 0
        }
        else if ($2 == "error") {
            rendered = Index_pull($0, REFIX, "")
            __error(fileName" Line "z": "rendered)
            # NF = 0
        }
        else if ($2 == "pragma") {
            rendered = Index_pull($0, REFIX, "")
            __warning(fileName" Line "z": Unknown "rendered)
            NF = 0
        }
        else if ($2 == "line" || $2 ~ /^[+-]?[0-9]+$/) {
            # if ($2 == "line") Index_remove(2)
            NF = 0 # Line Numbers
        }
        else {
            for (i = 1; i <= NF; ++i) if ($i ~ /^\s*$/) Index_remove(i--) # clean
            rendered = Index_pull($0, REFIX, " ")
            __error(fileName" Line "z": Unknown "rendered)
            NF = 0
        }
        if (!NF) { ++lz; continue }
        preproc[C][O][ ++preproc[C][O]["length"] ] = $0; continue
    }

        #for (i = 1; i <= NF; ++i) if ($i ~ /^\s*$/) Index_remove(i--) # clean

        parsed[fileName]["I"] = Index["length"]
        for (i = 1; i <= NF; ++i) {
            if ($i ~ /^\s*$/) continue # no clean, no use
            if ($i in C_defines) {
                if (typeof(C_defines[$i]) != "array") continue
                parsed[fileName]["z"] = z
                n = CDefine_apply(i, parsed[fileName])
                z = parsed[fileName]["z"]
                i += n - 1
            }
        }
        delete parsed[fileName]["I"]

        for (i = 1; i <= NF; ++i) {
            #if ($i ~ /^\s*$/) if (i == 1 || NF != 1) continue # except SPACES
            if ($i ~ /^\s*$/) { Index_remove(i--); continue } # clean
            if (!enable_Comments) {
                if ($i ~ /^\/\* ?[^#][a-zA-Z_][a-zA-Z_0-9]* ?\*\/$/) continue # allow short comments
                if ($i ~ /^\/\*/ || $i ~ /\*\/$/) { Index_remove(i--); continue }   # clean comments
            }
        }

        if (!NF) { ++lz; continue }

        if (lz <= 3) preproc[C][O]["length"] += lz
        else {
            preproc[C][O]["length"] += 2
            preproc[C][O][ ++preproc[C][O]["length"] ] = "#"FIX z FIX"\""fileName"\""
            # preproc[C][O][ preproc[C][O]["length"] ] = "#"FIX z FIX"\""fileName"\""" /* Zeile "++preproc[C][O]["length"]" */"
        }
        lz = 0

        preproc[C][O][ ++preproc[C][O]["length"] ] = $0
    }
    Index_pop()
    if ("length" in ifExpressions && ifExpressions["length"]) {
        m = ""; for (n = 1; n <= ifExpressions["length"]; ++n) m = String_concat(m, " ", "# endif "ifExpressions[n]["if"])
        __warning(fileName" Line "z": Missing "m)
    }
    for (name in OLD_defines) {
        delete C_defines[name]
        C_defines[name]["value"]
        Dictionary_copy(OLD_defines[name], C_defines[name])
        delete OLD_defines[name]
    }
    return 1
}
