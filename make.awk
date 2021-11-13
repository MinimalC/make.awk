#!/usr/bin/awk -f
# Gemeinfrei. Public Domain.
# 2020 Hans Riehm

@include "meta.awk"
@include "make.C.awk"
@include "make.CSharp.awk"

# HINTS:
# la *.c .*.c 2>/dev/null | ./.awk '{ if ($1 !~ /\.auto/) print "# include \""$1"\"" }'

function set_make_project(wert) { Project = wert }

function set_make_debug(wert) { DEBUG = wert }

function set_make_cc(wert) { C_compiler = wert }

function set_make_ld(wert) { C_linker = wert }

function set_make_shared(wert) { C_link_shared = wert }

function set_make_nostd(wert) {
    if (typeof(wert) == "untyped" || typeof(wert) == "number" && wert) STD = "META"
    else STD = wert
}

function set_make_enableComments(wert) { enable_Comments = wert }

function uname_machine(    __,output) {
    output["length"]
    __command("uname", "-m", output)
    return output[1]
}

function uname_operatingSystem(    __,output) {
    output["length"]
    __command("uname", "-o", output)
    return output[1]
}

function reg_query(key,    __,output) {
    output["length"]
    __command("reg", "query "key, output)
    return output[1]
}

BEGIN { BEGIN_make() }

function BEGIN_make() {

    REFIX = @/\x01/
      FIX = "\x01"
    DEFIX = "`"

    Format["h"] = "C"
    Format["c"] = "C"
    Format["cs"] = "CSharp"

    Format[1] = "CSharp"
    Format[2] = "C"
    Format[3] = "ASM"
    Format["length"] = 3

    STD = "ISO"

    if ("PROCESSOR_ARCHITECTURE" in ENVIRON) {
        PLATFORM = "Windows"
        ARCHITECTURE = ENVIRON["PROCESSOR_ARCHITECTURE"]
        C_compiler = "cl"
        C_linker = "link"
    }
    else {
        PLATFORM = uname_operatingSystem() # "GNU/Linux"
        ARCHITECTURE = uname_machine()
        C_compiler = "gcc"
        C_linker = "gcc"
    }

    USAGE =\
    "Usage:\n"\
"    make.awk project=Program [options] [preprocess] [precompile] Program.c [compile]\n"\
    "\n"\
    "Options:\n"\
    "    project=Name for a custom Project\n"\
    "    cc=customcc for a custom C_compiler\n"\
    "    +nostd for a custom standard, default is ISO\n"\
    "\n"\
    "C_preprocess'ing:\n"\
    "    +enableComments for not removing comments\n"\
    "    -DNDEBUG or +DDEBUG for boolean true or false or DDEBUG=3 for the value 3"

    __BEGIN("compile")
}

END { END_make() }

function END_make(    __,name,rendered) {

    if (DEBUG) {
        if (Dictionary_count(CSharp_Types)) { __debug("CSharp_Types: "); Array_debug(CSharp_Types) }
        if (Dictionary_count(C_types)) { __debug("C_types: "); Array_debug(C_types) }
        if (Dictionary_count(C_defines)) { __debug("C_defines: "); for (name in C_defines) {
            rendered = Index_pull(C_defines[name]["value"], REFIX, " ")
            if ("arguments" in C_defines[name])
                 __debug("# define "name" ( "C_defines[name]["arguments"]["text"]" )  "rendered)
            else __debug("# define "name"  "rendered)
        } }
    }
    if (RUN_ARGC_ARGV) {
        delete parsed
        delete preproc
        delete precomp
        delete compiled
        delete CSharp_Types
        delete C_types
        delete C_defines
        ARGC_ARGV_debug()
    }
}

function make_ARGC_ARGV(config) { RUN_ARGC_ARGV = 1 }
function make_ARGV_ARGC(config) { RUN_ARGC_ARGV = 1 }

function make_parse(config,    __,a,b,c,C,d,e,f,format,m,n,name,o,p,pre,z) {

    if (!config["files"]["length"]) { __error(USAGE); return }
    if (!Project) Project = get_FileNameNoExt(config["files"][1])
    #if (!prepared) make_prepare(config)

    for (f = 1; f <= Format["length"]; ++f) {
        format = Format[f]
        if ((c = format"_""prepare_preprocess") in FUNCTAB) @c(config)
    for (n = 1; n <= config["files"]["length"]; ++n) {
        name = config["files"][n]
        if (format != Format[get_FileNameExt(name)]) continue

        if (!((C = format"_""parse") in FUNCTAB)) { __error("No function "C); continue }
        parsed[name]["length"]
        @C(name)
    } }

    pre["length"]
    for (n in parsed) {
        if (n == "length" || n ~ /^[0-9]/) continue
        if (typeof(parsed[n]) != "array") continue
        if (!parsed[n]["length"]) continue
        Index_pullArray(pre, parsed[n], REFIX, DEBUG ? DEFIX : " ")
    }
    File_printTo(pre, "."Project"...C")
}

function make_preprocess(config,    __,a,b,c,C,d,e,f,format,g,h,i,j,k,l,m,n,name,o,p,pre,q,r,s,short,t,u,v,w,x,y,z) {

    config["next"]
    if (!config["files"]["length"]) { __error(USAGE); return }
    if (!Project) Project = get_FileNameNoExt(config["files"][1])

    for (f = 1; f <= Format["length"]; ++f) {
        format = Format[f]
    for (n = 1; n <= config["files"]["length"]; ++n) {
        name = config["files"][n]
        if (format != Format[get_FileNameExt(name)]) continue
        short = get_FileNameNoExt(name)
        if ("auto" == get_FileNameExt(short)) short = get_FileNameNoExt(short)
        if (Project == short) short = ""

        if (!preproc[format][name]["length"]) {
            if ((c = format"_""prepare_preprocess") in FUNCTAB) @c(config)
            if (!((C = format"_""preprocess") in FUNCTAB)) { __error("make.awk: No function "C); continue }
            preproc[format][name]["length"]
            if (!@C(name)) { __error("make.awk: No "C" "name); List_remove(config["files"], n--) }
            else {
                pre["length"]; Array_clear(pre)
                Index_pullArray(pre, preproc[format][name], REFIX, DEBUG ? DEFIX : " ")
                File_printTo(pre, "."Project (!short?"":"."short)"..."format)
                ++o
            }
        }
    } }
    if (!o) { __error("make.awk: Nothing preprocessed"); return }
}

function make_precompile(config,    __,a,b,c,C,d,e,f,format,g,h,i,j,k,l,m,n,name,o,p,pre,q,r,s,short,t,u,v,w,x,y,z) {

    config["next"]
    if (!Project) { __error("make.awk: Project undefined"); return }

    for (f = Format["length"]; f; --f) {
        format = Format[f]
    for (n = 1; n <= config["files"]["length"]; ++n) {
        name = config["files"][n]
        if (format != Format[get_FileNameExt(name)]) continue
        short = get_FileNameNoExt(name)
        if ("auto" == get_FileNameExt(short)) short = get_FileNameNoExt(short)
        if (Project == short) short = ""

        if (!preproc[format][name]["length"]) {
            if ((c = format"_""prepare_preprocess") in FUNCTAB) @c(config)
            if (!((C = format"_""preprocess") in FUNCTAB)) { __error("make.awk: No function "C); continue }
            if (!@C(name)) { __error("make.awk: No "C" "name); List_remove(config["files"], n--); continue }
            else {
                pre["length"]; Array_clear(pre)
                Index_pullArray(pre, preproc[format][name], REFIX, DEBUG ? DEFIX : " ")
                File_printTo(pre, "."Project (!short?"":"."short)"..."format)
            }
        }

        if (!precomp[format][name]["length"]) {
            if ((c = format"_""prepare_precompile") in FUNCTAB) @c(config)
            if (!((C = format"_""precompile") in FUNCTAB)) { __error("make.awk: No function "C); continue }
            precomp[format][name]["length"]
            if (!@C(name)) { __error("make.awk: No "C" "name); continue }
            else {
                pre["length"]; Array_clear(pre)
                Index_pullArray(pre, precomp[format][name], REFIX, DEBUG ? DEFIX : " ")
                File_printTo(pre, "."Project (!short?"":"."short)"..."format)
                ++o
            }
        }
    } }
    if (!o) { __error("make.awk: Nothing precompiled"); return }
}

function make_compile(config,    __,a,b,c,C,d,e,f,fileName,format,g,h,i,k,l,m,n,name,o,p,pre,q,r,s,short,t,u,v,w,x,y,z) {

    config["next"]
    if (!Project) { __error("make.awk: Project undefined"); return }

    for (f = 1; f <= Format["length"]; ++f) {
        format = Format[f]
    for (n = 1; n <= config["files"]["length"]; ++n) {
        name = config["files"][n]
        if (format != Format[get_FileNameExt(name)]) continue
        short = get_FileNameNoExt(name)
        if ("auto" == get_FileNameExt(short)) short = get_FileNameNoExt(short)
        if (Project == short) short = ""

        if (!preproc[format][name]["length"]) {
            if ((c = format"_""prepare_preprocess") in FUNCTAB) @c(config)
            if (!((C = format"_""preprocess") in FUNCTAB)) { __error("make.awk: No function "C); continue }
            if (!@C(name)) { __error("make.awk: No "C" "name); List_remove(config["files"], n--); continue }
            else {
                pre["length"]; Array_clear(pre)
                Index_pullArray(pre, preproc[format][name], REFIX, DEBUG ? DEFIX : " ")
                File_printTo(pre, "."Project (!short?"":"."short)"..."format)
            }
        }

        if (!precomp[format][name]["length"]) {
            if ((c = format"_""prepare_precompile") in FUNCTAB) @c(config)
            if (!((C = format"_""precompile") in FUNCTAB)) { __error("make.awk: No function "C); continue }
            precomp[format][name]["length"]
            if (!@C(name)) { __error("make.awk: No "C" "name); continue }
            else {
                pre["length"]; Array_clear(pre)
                Index_pullArray(pre, precomp[format][name], REFIX, DEBUG ? DEFIX : " ")
                File_printTo(pre, "."Project (!short?"":"."short)"..."format)
            }
        }

        if (!compiled[format][name]["length"]) {
            if (!((C = format"_""compile") in FUNCTAB)) { __error("make.awk: No function "C); continue }
            compiled[format][name]["length"]
            if (!@C(name)) { __error("make.awk: No "C" "name); continue }
            else if (compiled[format][name]["length"]) {
                compiled[format][name]["shortName"] = "."Project (!short?"":"."short)"..."format".o"
                File_printTo(compiled[format][name], compiled[format][name]["shortName"], "\n", "\n", 1)
                compiled[format][ ++compiled[format]["length"] ] = name
                ++o
            }
        }
    } }
    if (!o) { __error("make.awk: Nothing compiled"); return }
}

function make_library(config,    __,a,b,c,C,d,e,f,fileName,format,g,h,i,j,k,l,m,n,name,names,o,options,p,q,r,s,short,t,u,unseen,v,w,x,y,z) {
Array_debug(config)

    for (n = 1; n <= compiled["C"]["length"]; ++n) {
        name = compiled["C"][n]
        names = String_concat(names, " ", compiled["C"][name]["shortName"])
    }
    if (names) {

        if (C_link_shared) options = options" -shared"
        if (C_linker == "gcc") options = options" -fPIC"
        else if (C_linker == "ld") options = options" -pie"

        options = options" "names" -o ."Project"..."(!C_link_shared?"a":"so")

        unseen["length"]
        __pipe(C_linker, options, unseen)
File_debug(unseen)
    }
}

function make_executable(config,    __,a,b,c,C,d,e,f,fileName,format,g,h,i,j,k,l,m,n,name,names,o,options,p,pre,q,r,s,short,t,u,unseen,v,w,x,y,z) {
Array_debug(config)

    for (f = 1; f <= Format["length"]; ++f) {
        format = Format[f]
        if (!((C = format"_linkExecutable") in FUNCTAB)) continue
    for (n = 1; n <= config["files"]["length"]; ++n) {
        name = config["files"][n]
        if (format != Format[get_FileNameExt(name)]) continue
        short = get_FileNameNoExt(name)
        if ("auto" == get_FileNameExt(short)) short = get_FileNameNoExt(short)
        if (Project == short) short = ""

        if (!preproc[format][name]["length"]) {
            if ((c = format"_""prepare_preprocess") in FUNCTAB) @c(config)
            if (!((C = format"_""preprocess") in FUNCTAB)) { __error("make.awk: No function "C); continue }
            if (!@C(name)) { __error("make.awk: No "C" "name); List_remove(config["files"], n--); continue }
            else {
                pre["length"]; Array_clear(pre)
                Index_pullArray(pre, preproc[format][name], REFIX, DEBUG ? DEFIX : " ")
                File_printTo(pre, "."Project (!short?"":"."short)"..."format)
            }
        }

        if (!precomp[format][name]["length"]) {
            if ((c = format"_""prepare_precompile") in FUNCTAB) @c(config)
            if (!((C = format"_""precompile") in FUNCTAB)) { __error("make.awk: No function "C); continue }
            precomp[format][name]["length"]
            if (!@C(name)) { __error("make.awk: No "C" "name); continue }
            else {
                pre["length"]; Array_clear(pre)
                Index_pullArray(pre, precomp[format][name], REFIX, DEBUG ? DEFIX : " ")
                File_printTo(pre, "."Project (!short?"":"."short)"..."format)
            }
        }

        if (!compiled[format][name]["length"]) {
            if (!((C = format"_""compile") in FUNCTAB)) { __error("make.awk: No function "C); continue }
            compiled[format][name]["length"]
            if (!@C(name)) { __error("make.awk: No "C" "name); continue }
            else {
                fileName = "."Project (!short?"":"."short)"..."format".o"
                File_printTo(compiled[format][name], fileName, "\n", "\n", 1)
                ++o
            }
        }

        if (compiled[format][name]["length"]) {
            fileName = "."Project (!short?"":"."short)"..."format".o"
            # File_printTo(compiled[format][name], fileName, "\n", "\n", 1)

            if (C_linker == "gcc") options = options" -fPIE"
            else if (C_linker == "ld") options = options" -pie"

            names = ""
            if (!C_link_shared) {
                for (s = 1; s <= compiled[format]["length"]; ++s) {
                    name = compiled[format][s]
                    names = String_concat(names, " ", compiled[format][name]["shortName"])
                }
            }

            options = options" "names" "fileName" -o ."Project

            unseen["length"]
            __pipe(C_linker, options, unseen)
File_debug(unseen)
            ++o
        }
    } }
}
