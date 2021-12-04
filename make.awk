#!/usr/bin/awk -f
# Gemeinfrei. Public Domain.
# 2020 Hans Riehm

@include "run.awk"
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
    output["0length"]
    __command("uname", "-m", output)
    return output[1]
}

function uname_operatingSystem(    __,output) {
    output["0length"]
    __command("uname", "-o", output)
    return output[1]
}

function reg_query(key,    __,output) {
    output["0length"]
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
    Format["0length"] = 3

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

    createTemp_Directory(".make")

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

    # if (!DEBUG) removeTemp_Directory()
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

    if (!config["files"]["0length"]) { __error(USAGE); return }
    if (!Project) Project = get_FileNameNoExt(config["files"][1])
    #if (!prepared) make_prepare(config)

    for (f = 1; f <= Format["0length"]; ++f) {
        format = Format[f]
        if ((c = format"_""prepare_preprocess") in FUNCTAB) @c(config)
    for (n = 1; n <= config["files"]["0length"]; ++n) {
        name = config["files"][n]
        if (format != Format[get_FileNameExt(name)]) continue

        if (!((C = format"_""parse") in FUNCTAB)) { __error("No function "C); continue }
        parsed[name]["0length"]
        @C(name)
    } }

    pre["0length"]
    for (n in parsed) {
        if (n ~ /^[0-9]/) continue
        if (typeof(parsed[n]) != "array") continue
        if (!parsed[n]["0length"]) continue
        Index_pullArray(pre, parsed[n], REFIX, DEBUG ? DEFIX : " ")
    }
    File_printTo(pre, TEMP_DIRECTORY Project"...C")
}

function make_preprocess(config,    __,a,b,c,C,d,e,f,format,g,h,i,j,k,l,m,n,name,o,p,pre,q,r,s,short,t,u,v,w,x,y,z) {

    config["next"]
    if (!config["files"]["0length"]) { __error(USAGE); return }
    if (!Project) Project = get_FileNameNoExt(config["files"][1])

    for (f = 1; f <= Format["0length"]; ++f) {
        format = Format[f]
    for (n = 1; n <= config["files"]["0length"]; ++n) {
        name = config["files"][n]
        if (format != Format[get_FileNameExt(name)]) continue
        short = get_FileNameNoExt(name)
        if ("auto" == get_FileNameExt(short)) short = get_FileNameNoExt(short)
        if (Project == short) short = ""

        if (!preproc[format][name]["0length"]) {
            if ((c = format"_""prepare_preprocess") in FUNCTAB) @c(config)
            if (!((C = format"_""preprocess") in FUNCTAB)) { __error("make.awk: No function "C); continue }
            preproc[format][name]["0length"]
            if (!@C(name)) { __error("make.awk: No "C" "name); List_remove(config["files"], n--) }
            else {
                pre["0length"]; Array_clear(pre)
                Index_pullArray(pre, preproc[format][name], REFIX, DEBUG ? DEFIX : " ")
                File_printTo(pre, TEMP_DIRECTORY Project (!short?"":"."short)"..."format)
                ++o
            }
        }
    } }
    if (!o) { __error("make.awk: Nothing preprocessed"); return }
}

function make_precompile(config,    __,a,b,c,C,d,e,f,format,g,h,i,j,k,l,m,n,name,o,p,pre,q,r,s,short,t,u,v,w,x,y,z) {

    config["next"]
    if (!Project) { __error("make.awk: Project undefined"); return }

    for (f = Format["0length"]; f; --f) {
        format = Format[f]
    for (n = 1; n <= config["files"]["0length"]; ++n) {
        name = config["files"][n]
        if (format != Format[get_FileNameExt(name)]) continue
        short = get_FileNameNoExt(name)
        if ("auto" == get_FileNameExt(short)) short = get_FileNameNoExt(short)
        if (Project == short) short = ""

        if (!preproc[format][name]["0length"]) {
            if ((c = format"_""prepare_preprocess") in FUNCTAB) @c(config)
            if (!((C = format"_""preprocess") in FUNCTAB)) { __error("make.awk: No function "C); continue }
            if (!@C(name)) { __error("make.awk: No "C" "name); List_remove(config["files"], n--); continue }
            else {
                pre["0length"]; Array_clear(pre)
                Index_pullArray(pre, preproc[format][name], REFIX, DEBUG ? DEFIX : " ")
                File_printTo(pre, TEMP_DIRECTORY Project (!short?"":"."short)"..."format)
            }
        }

        if (!precomp[format][name]["0length"]) {
            if ((c = format"_""prepare_precompile") in FUNCTAB) @c(config)
            if (!((C = format"_""precompile") in FUNCTAB)) { __error("make.awk: No function "C); continue }
            precomp[format][name]["0length"]
            if (!@C(name)) { __error("make.awk: No "C" "name); continue }
            else {
                pre["0length"]; Array_clear(pre)
                Index_pullArray(pre, precomp[format][name], REFIX, DEBUG ? DEFIX : " ")
                File_printTo(pre, TEMP_DIRECTORY Project (!short?"":"."short)"..."format)
                ++o
            }
        }
    } }
    if (!o) { __error("make.awk: Nothing precompiled"); return }
}

function make_compile(config,    __,a,b,c,C,d,e,f,file,format,g,h,i,k,l,m,n,name,o,p,pre,q,r,s,short,t,u,v,w,x,y,z) {

    config["next"]
    if (!Project) { __error("make.awk: Project undefined"); return }

    for (f = 1; f <= Format["0length"]; ++f) {
        format = Format[f]
    for (n = 1; n <= config["files"]["0length"]; ++n) {
        name = config["files"][n]
        if (format != Format[get_FileNameExt(name)]) continue
        short = get_FileNameNoExt(name)
        if ("auto" == get_FileNameExt(short)) short = get_FileNameNoExt(short)
        if (Project == short) short = ""

        if (!preproc[format][name]["0length"]) {
            if ((c = format"_""prepare_preprocess") in FUNCTAB) @c(config)
            if (!((C = format"_""preprocess") in FUNCTAB)) { __error("make.awk: No function "C); continue }
            if (!@C(name)) { __error("make.awk: No "C" "name); List_remove(config["files"], n--); continue }
            else {
                pre["0length"]; Array_clear(pre)
                Index_pullArray(pre, preproc[format][name], REFIX, DEBUG ? DEFIX : " ")
                File_printTo(pre, TEMP_DIRECTORY Project (!short?"":"."short)"..."format)
            }
        }

        if (!precomp[format][name]["0length"]) {
            if ((c = format"_""prepare_precompile") in FUNCTAB) @c(config)
            if (!((C = format"_""precompile") in FUNCTAB)) { __error("make.awk: No function "C); continue }
            precomp[format][name]["0length"]
            if (!@C(name)) { __error("make.awk: No "C" "name); continue }
            else {
                pre["0length"]; Array_clear(pre)
                Index_pullArray(pre, precomp[format][name], REFIX, DEBUG ? DEFIX : " ")
                File_printTo(pre, TEMP_DIRECTORY Project (!short?"":"."short)"..."format)
            }
        }

        if (!compiled[format][name]["0length"]) {
            if (!((C = format"_""compile") in FUNCTAB)) { __error("make.awk: No function "C); continue }
            compiled[format][name]["0length"]
            if (!@C(name)) { __error("make.awk: No "C" "name); continue }
            else if (compiled[format][name]["0length"]) {
                file = compiled[format][name]["file"] = TEMP_DIRECTORY Project (!short?"":"."short)"..."format".o"
                File_printTo(compiled[format][name], file, "\n", "\n", 1)
                compiled[format][ ++compiled[format]["0length"] ] = name
                ++o
            }
        }
    } }
    if (!o) { __error("make.awk: Nothing compiled"); return }
}

function make_library(config,    __,a,b,c,C,d,e,f,fileName,format,g,h,i,j,k,l,m,n,name,names,o,options,p,q,r,s,short,t,u,unseen,v,w,x,y,z) {
Array_debug(config)

    format = "C"
    names = ""
    for (s = 1; s <= compiled[format]["0length"]; ++s) {
        name = compiled[format][s]
        names = String_concat(names, " ", compiled[format][name]["file"])
    }
    if (names) {
        if (C_link_shared) {
            options = options" -shared"
            options = options" "names

            if (STD == "ISO")
                options = options" -lm -ldl -pthread"

            options = options" -o "TEMP_DIRECTORY"lib"Project".so"

__debug("C_link_library: "C_linker" "options)
            unseen["0length"]
            __pipe(C_linker, options, unseen)
File_debug(unseen)
            ++o
        }
        else {
            options = options" rcs "TEMP_DIRECTORY"lib"Project".a"
            options = options" "names

__debug("C_static_library: ar "options)
            unseen["0length"]
            __pipe("ar", options, unseen)
File_debug(unseen)
            ++o
        }
    }
    if (!o) { __error("make.awk: No Library built"); return }
}

function make_executable(config,    __,a,b,c,C,d,e,empty,f,fileName,format,g,h,i,j,k,l,m,n,name,names,o,options,p,pre,q,r,s,short,t,u,unseen,v,w,x,y,z) {
Array_debug(config)

    for (f = 1; f <= Format["0length"]; ++f) {
        format = Format[f]
        # if (!((C = format"_linkExecutable") in FUNCTAB)) continue
    for (n = 1; n <= config["files"]["0length"]; ++n) {
        name = config["files"][n]
        if (format != Format[get_FileNameExt(name)]) continue
        short = get_FileNameNoExt(name)
        if ("auto" == get_FileNameExt(short)) short = get_FileNameNoExt(short)
        if (Project == short) short = ""

        if (!preproc[format][name]["0length"]) {
            if ((c = format"_""prepare_preprocess") in FUNCTAB) @c(config)
            if (!((C = format"_""preprocess") in FUNCTAB)) { __error("make.awk: No function "C); continue }
            if (!@C(name)) { __error("make.awk: No "C" "name); List_remove(config["files"], n--); continue }
            else {
                pre["0length"]; Array_clear(pre)
                Index_pullArray(pre, preproc[format][name], REFIX, DEBUG ? DEFIX : " ")
                File_printTo(pre, TEMP_DIRECTORY Project (!short?"":"."short)"..."format)
            }
        }

        if (!precomp[format][name]["0length"]) {
            if ((c = format"_""prepare_precompile") in FUNCTAB) @c(config)
            if (!((C = format"_""precompile") in FUNCTAB)) { __error("make.awk: No function "C); continue }
            precomp[format][name]["0length"]
            if (!@C(name)) { __error("make.awk: No "C" "name); continue }
            else {
                pre["0length"]; Array_clear(pre)
                Index_pullArray(pre, precomp[format][name], REFIX, DEBUG ? DEFIX : " ")
                File_printTo(pre, TEMP_DIRECTORY Project (!short?"":"."short)"..."format)
            }
        }

        if (!compiled[format][name]["0length"]) {
            if (!((C = format"_""compile") in FUNCTAB)) { __error("make.awk: No function "C); continue }
            compiled[format][name]["0length"]
            if (!@C(name)) { __error("make.awk: No "C" "name); continue }
            else {
                fileName = compiled[format][name]["file"] = TEMP_DIRECTORY Project (!short?"":"."short)"..."format".o"
                File_printTo(compiled[format][name], fileName, "\n", "\n", 1)
            }
        }
    } }


    if (C_link_shared)
         options = options" -shared -pie"
    else options = options" -static"

    format = "C"
    for (n = 1; n <= config["files"]["0length"]; ++n) {
        name = config["files"][n]
        fileName = compiled[format][name]["file"]
        options = options" "fileName
    }

    options = options" -L"TEMP_DIRECTORY" -l:lib"Project"."(!C_link_shared?"a":"so")

    if (STD == "ISO")
        options = options" -lm -ldl -pthread"

    options = options" -o "TEMP_DIRECTORY Project

__debug("C_link_executable: "C_linker" "options)
    unseen["0length"]
    __pipe(C_linker, options, unseen)
File_debug(unseen)

    # ++o if (!o) { __error("make.awk: No Executable linked"); return }
}
