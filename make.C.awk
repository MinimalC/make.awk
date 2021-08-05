#
# Gemeinfrei. Public Domain.
# 2020 - 2021 Hans Riehm

#include "../make.awk/meta.awk"
@include "../make.awk/make.CDefine_eval.awk"
@include "../make.awk/make.C_parse.awk"
@include "../make.awk/make.C_preprocess.awk"

function C_prepare_precompile(config,    a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) {

    Array_clear(C_types)
    C_types["void"]["isLiteral"]
    C_types["unsigned"]["isLiteral"]
    C_types["signed"]["isLiteral"]
    C_types["_Bool"]["isLiteral"]
    C_types["char"]["isLiteral"]
    C_types["short"]["isLiteral"]
    C_types["int"]["isLiteral"]
    C_types["long"]["isLiteral"]
    C_types["double"]["isLiteral"]
    C_types["float"]["isLiteral"]
    C_types["_Float32"]["isLiteral"]
    C_types["_Float32x"]["isLiteral"]
    C_types["_Float64"]["isLiteral"]
    C_types["_Float64x"]["isLiteral"]
    C_types["_Float128"]["isLiteral"]
    C_types["__builtin_va_list"]["isLiteral"]

    precompiled["C"]["length"]
    Array_clear(precompiled["C"])
    C_precompile(Compiler, precompiled["C"])
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
            if ($i == "const" || $i == "volatile" || $i in C_types || $i == "struct" || $i == "union" || $i == "enum")
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
                    if ($n in C_types && "isLiteral" in C_types[$n]) {
                        s = 1; name = String_concat(name, " ", $n)
                        if (n > i) { $i = String_concat($i, " ", $n); Index_remove(n--) }
                        continue
                    }
                    if (name == "" && ($n in C_types)) {
                        if ("isLiteral" in C_types[$n]) s = 1
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
                else if (level == 1 && !(name in C_types) ) {
if (DEBUG == 5) __debug(fileName" Line "z": "name)
                    if (s) C_types[name]["isLiteral"]
                    else C_types[name]["baseType"]
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

                    if (!(var in C_types)) {
                        C_types[var]["baseType"] = String_concat(name, " ", varType)
                        if (name in C_types && "isLiteral" in C_types[name] && !p)
                            C_types[var]["isLiteral"]
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
#    if (!C_preprocess(fileName, input)) return

    # C_precompile is PROTOTYPE

    preprocessed["C"][fileName]["fields"]["length"]
    for (n in preprocessed["C"][fileName]["fields"]) {
        if (typeof(preprocessed["C"][fileName]["fields"][n]) == "array")
            output[++output["length"]] = preprocessed["C"][fileName]["fields"][n]["body"]
    }

    for (z = 1; z <= preprocessed["C"][fileName]["length"]; ++z)
        output[++output["length"]] = preprocessed["C"][fileName][z]

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
