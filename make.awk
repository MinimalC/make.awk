#!/usr/bin/awk -f
# Gemeinfrei. Public Domain.
# 2020 Hans Riehm

@include "../make.awk/meta.awk"
@include "../make.awk/make.C.awk"
@include "../make.awk/make.CSharp.awk"

function set_make_project(wert) { Project = wert }

function set_make_debug(wert) { DEBUG = wert }

function set_make_compiler(wert) { Compiler = wert }

BEGIN {
    fixFS = @/\xA0/ #\s*\xA0?/
    fix = "\xA0"

    if (typeof(format) == "untyped") {
        format["h"] = "C"
        format["c"] = "C"
        # format["inc"] = "C"
        format["cs"] = "CSharp"

        format[1] = "CSharp"
        format[2] = "C"
        format[3] = "ASM"
        format["length"] = 3
    }

    Compiler = "gcc"

    USAGE = "make.awk: Use make.awk [parse|preprocess|precompile|compile] project=Program Program.c"

    ACTION = "compile"

    __BEGIN()
}

END {
    if (DEBUG) {
        __debug("CSharp_Types: "); Array_debug(CSharp_Types)
        __debug("Defines: ")
        for (n in C_defines) {
            Index_push(C_defines[n]["body"], fixFS, " "); rendered = Index_pop()
            if (C_defines[n]["isFunction"])
                 __debug("# define "n" ( "C_defines[n]["arguments"]["text"]" ) "rendered)
            else __debug("# define "n"  "rendered)
        }
        __debug("Types: "); Array_debug(C_types)
    }
}

function make_prepare(origin,    a,b,c,d,e,f) {

    for (f = format["length"]; f; --f) {
        if (!((c = format[f]"_""prepare") in FUNCTAB)) continue
        @c(origin)
    }
    # ASM_prepare(origin)
    #C_prepare(origin)
    #CSharp_prepare(origin)

    ++prepared
}

function make_parse(origin,    a,b,c,d,e,f,m,n) {

    if (!origin["files"]["length"]) { __error(USAGE); return }
    if (!Project) Project = get_FileNameNoExt(origin["files"][1])
    if (!prepared) make_prepare(origin)

    for (n = 1; n <= origin["files"]["length"]; ++n) {
        f = get_FileNameExt(origin["files"][n])
        if (!(f in format)) { __error("make.awk: No Format for FileName."f); Array_remove(origin["files"], n--); continue }
        if (!((c = format[f]"_""parse") in FUNCTAB)) { __error("No function "c); continue }

        @c(origin["files"][n])
    }

    for (n in parsed) File_printTo(parsed[n], "."Project"...c")
}

function make_preprocess(origin,    a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,ppreprocessed,q,r,s,t,u,v,w,x,y,z) {

    if (!origin["files"]["length"]) { __error(USAGE); return }
    if (!Project) Project = get_FileNameNoExt(origin["files"][1])
    if (!prepared) make_prepare(origin)

    for (n = 1; n <= origin["files"]["length"]; ++n) {
        f = get_FileNameExt(origin["files"][n])
        if (!(f in format)) { __error("make.awk: No Format for FileName."f); Array_remove(origin["files"], n--); continue }
        if (!((c = format[f]"_""preprocess") in FUNCTAB)) { __error("No function "c); continue }

        preprocessed[format[f]]["length"]
        @c(origin["files"][n], preprocessed[format[f]])
    }

    for (f = 1; f <= format["length"]; ++f) {
        if (!preprocessed[format[f]]["length"]) continue; ++o
if (DEBUG) Index_push("", fixFS, fix, "\0", "\n")
else       Index_push("", fixFS, " ", "\0", "\n")
        Array_clear(ppreprocessed)
        for (z = 1; z <= preprocessed[format[f]]["length"]; ++z)
            ppreprocessed[++ppreprocessed["length"]] = Index_reset(preprocessed[format[f]][z])
        Index_pop()
        File_printTo(ppreprocessed, "."Project (++preprocessed_count == 1 ? "" : preprocessed_count)"...prep."format[f])
    }
    if (!o) { __error("make.awk: Nothing preprocessed"); return }
}

function make_precompile(origin,    a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,pprecompiled,q,r,s,t,u,v,w,x,y,z) {

    if (!Project) { __error("make.awk: Project undefined"); return }

    for (f = 1; f <= format["length"]; ++f) {
        if (!((c = format[f]"_""precompile") in FUNCTAB)) { "make.awk: No function "c; continue }
        precompiled[format[f]]["length"]
        @c(precompiled[format[f]])
        if (!precompiled[format[f]]["length"]) continue; ++o
if (DEBUG) Index_push("", fixFS, fix, "\0", "\n")
else       Index_push("", fixFS, " ", "\0", "\n")
        Array_clear(pprecompiled)
        for (z = 1; z <= precompiled[format[f]]["length"]; ++z)
            pprecompiled[++pprecompiled["length"]] = Index_reset(precompiled[format[f]][z])
        Index_pop()
        File_printTo(pprecompiled, "."Project (++precompiled_count == 1 ? "" : precompiled_count)"...prec."format[f])
    }
    if (!o) { __error("make.awk: Nothing precompiled"); return }
}

function make_compile(origin,    a,b,c,d,e,f,g,h,i,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) {

    if (!Project) { __error("make.awk: Project undefined"); return }

    for (f = 1; f <= format["length"]; ++f) {
        if (!((c = format[f]"_""compile") in FUNCTAB)) { "make.awk: No function "c; continue }
        # Array_clear(compiled[format[f]])
        compiled[format[f]]["length"]
        @c(compiled[format[f]])
        if (!compiled[format[f]]["length"]) continue; ++o
        File_printTo(compiled[format[f]], "."Project (++compiled_count == 1 ? "" : compiled_count)"...o", "\n", "\n", 1)
    }
    if (!o) { __error("make.awk: Nothing compiled"); return }
}

