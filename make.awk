#!/usr/bin/awk -f
# Gemeinfrei. Public Domain.
# 2020 Hans Riehm

@include "../make.awk/meta.awk"
@include "../make.awk/make.C.awk"
@include "../make.awk/make.CSharp.awk"

function set_make_project(wert) { Project = wert }

function set_make_debug(wert) { DEBUG = wert }

function set_make_compiler(wert) { Compiler = wert }

BEGIN { BEGIN_make() }

function BEGIN_make() {

    REFIX = @/\xA0/
    FIX = "\xA0"

    Format["h"] = "C"
    Format["c"] = "C"
    Format["cs"] = "CSharp"

    Format[1] = "CSharp"
    Format[2] = "C"
    Format[3] = "ASM"
    Format["length"] = 3

    Compiler = "gcc"

    USAGE = "make.awk: Use make.awk project=Program [preprocess] Program.c [precompile] [compile]"

    __BEGIN("compile")
}

END { END_make() }

function END_make(    n,rendered) {

    if (DEBUG) {
        __debug("CSharp_Types: "); Array_debug(CSharp_Types)
        __debug("C_types: "); Array_debug(C_types)
        __debug("C_defines: "); for (n in C_defines) {
            rendered = Index_pull(C_defines[n]["body"], REFIX, " ")
            if (C_defines[n]["isFunction"])
                 __debug("# define "n" ( "C_defines[n]["arguments"]["text"]" ) "rendered)
            else __debug("# define "n"  "rendered)
        }
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

function make_ARGC_ARGV(config) {

    RUN_ARGC_ARGV = 1
}

function make_parse(config,    a,b,c,C,d,e,f,format,m,n,name,o,p,pre,z) {

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

    for (n in parsed) if (typeof(parsed[n]) == "array") for (z = 1; z <= parsed[n]["length"]; ++z) pre[++pre["length"]] = parsed[n][z]
    File_printTo(pre, "."Project"...parsed.C")
}

function make_preprocess(config,    a,b,c,C,d,e,f,format,g,h,i,j,k,l,m,n,name,o,p,pre,q,r,s,t,u,v,w,x,y,z) {

    config["next"]
    if (!config["files"]["length"]) { __error(USAGE); return }
    if (!Project) Project = get_FileNameNoExt(config["files"][1])

    for (f = 1; f <= Format["length"]; ++f) {
        format = Format[f]
    for (n = 1; n <= config["files"]["length"]; ++n) {
        name = config["files"][n]
        if (format != Format[get_FileNameExt(name)]) continue
        if ((c = format"_""prepare_preprocess") in FUNCTAB) @c(config)
        if (!((C = format"_""preprocess") in FUNCTAB)) { __error("make.awk: No function "C); continue }

        preproc[format][name]["length"]
        if (!@C(name)) continue
        #if (!preproc[format][name]["length"]) continue
        #preproc[format][ ++preproc[format]["length"] ] = name
        ++o

        Array_clear(pre)
if (DEBUG) Index_pullArray(pre, preproc[format][name], REFIX, FIX); else
        Index_pullArray(pre, preproc[format][name], REFIX, " ")
        File_printTo(pre, "."Project (++preprocessed_count[format] == 1 ? "" : preprocessed_count[format])"..."format)
    } }
    if (!o) { __error("make.awk: Nothing preprocessed"); return }
}

function make_precompile(config,    a,b,c,C,d,e,f,format,g,h,i,j,k,l,m,n,name,o,p,pre,q,r,s,t,u,v,w,x,y,z) {

    if (!Project) { __error("make.awk: Project undefined"); return }

    for (f = Format["length"]; f; --f) {
        format = Format[f]
        if ((c = format"_""prepare_precompile") in FUNCTAB) @c(config)
    for (n = 1; n <= config["files"]["length"]; ++n) {
        name = config["files"][n]
        if (format != Format[get_FileNameExt(name)]) continue
        if (!((C = format"_""precompile") in FUNCTAB)) { __error("make.awk: No function "C); continue }

        precomp[format]["length"]
        if (!@C(name)) continue
        #if (!precomp[format]["length"]) continue
        ++o

        Array_clear(pre)
if (DEBUG) Index_pullArray(pre, precomp[format], REFIX, FIX); else
        Index_pullArray(pre, precomp[format], REFIX, " ")
        File_printTo(pre, "."Project (++precompiled_count[format] == 1 ? "" : precompiled_count[format])"..."format)
    } }
    if (!o) { __error("make.awk: Nothing precompiled"); return }
}

function make_compile(config,    a,b,c,C,d,e,f,format,g,h,i,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) {

    if (!Project) { __error("make.awk: Project undefined"); return }

    for (f = 1; f <= Format["length"]; ++f) {
        format = Format[f]
        if (!((C = format"_""compile") in FUNCTAB)) { __error("make.awk: No function "C); continue }

        compiled[format]["length"]
        if (!@C()) continue
        #if (!compiled[format]["length"]) continue
        ++o

        File_printTo(compiled[format], "."Project (++compiled_count[format] == 1 ? "" : compiled_count[format])"..."format".o", "\n", "\n", 1)
    }
    if (!o) { __error("make.awk: Nothing compiled"); return }
}

