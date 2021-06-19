#!/usr/bin/awk -f
# Gemeinfrei. Public Domain.
# 2020 Hans Riehm

@include "../make.awk/meta.awk"
@include "../make.awk/make.C.awk"
@include "../make.awk/make.CSharp.awk"

function set_make_project(wert) { Project = wert }

function set_make_debug(wert) { DEBUG = wert }

BEGIN {
    fixFS = @/\x01/ #\s*\x01?/
    fix = "\x01"

    if (typeof(format) == "untyped") {
        format["h"] = "C"
        format["c"] = "C"
        # format["inc"] = "C"
        format["cs"] = "CSharp"

        format[1] = "C"
        format[2] = "CSharp"
        format[3] = "ASM"
        format["length"] = 3
    }

    USAGE = "make.awk: Use make.awk [parse|precompile|compile] project=Program Program.c"

    ACTION = "compile"

    __BEGIN()
}

END {
    if (DEBUG) {
        __debug("Defines: ")
        for (n in defines) {
            Index_push(defines[n]["body"], fixFS, " "); rendered = Index_pop()
            if (defines[n]["isFunction"])
                 __debug("# define "n" ( "defines[n]["arguments"]["text"]" ) "rendered)
            else __debug("# define "n"  "rendered)
        }
        __debug("Types: "); Array_debug(types)
    }
}

function make_parse(origin,    a,b,c,d,e,f,m,n) {

    if (!origin["length"]) { __error(USAGE); return }
    if (!Project) Project = get_FileNameNoExt(origin[1])

    for (n = 1; n <= origin["length"]; ++n) {
        e = get_FileNameExt(origin[n])
        if (!(e in format)) { __error("make.awk: No Format for FileName."e); Array_remove(origin, n--); continue }
    }
    for (f = 1; f <= format["length"]; ++f) {
    for (n = 1; n <= origin["length"]; ++n) {
        e = get_FileNameExt(origin[n])
        if (format[e] != format[f]) continue

        C_prepare()
        c = format[e]"_""parse"
        if (c in FUNCTAB) @c(origin[n])
        else { __error("No Format function "c); continue }
    } }

    for (n in parsed) File_printTo(parsed[n], "."Project"...c")
}

function make_precompile(origin,    a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,pprecompiled,q,r,s,t,u,v,w,x,y,z) {

    if (!origin["length"] && !precompiled["length"]) { __error(USAGE); return }
    if (!Project) Project = get_FileNameNoExt(origin[1])

    for (n = 1; n <= origin["length"]; ++n) {
        e = get_FileNameExt(origin[n])
        if (!(e in format)) { __error("make.awk: No Format for FileName."e); Array_remove(origin, n--); continue }
    }
    for (f = 1; f <= format["length"]; ++f) {
    for (n = 1; n <= origin["length"]; ++n) {
        e = get_FileNameExt(origin[n])
        if (format[e] != format[f]) continue

        C_prepare()
        c = format[e]"_""precompile"
        if (c in FUNCTAB) @c(origin[n])
        else { __error("No Format function "c); continue }
    } }
    if (!precompiled["length"]) { __error("make.awk: Nothing precompiled"); return }

    if (DEBUG) Index_push("", fixFS, fix, "\0", "\n")
    else       Index_push("", fixFS, " ", "\0", "\n")
    for (z = 1; z <= precompiled["length"]; ++z)
        pprecompiled[++pprecompiled["length"]] = Index_reset(precompiled[z])
    Index_pop()

    File_printTo(pprecompiled, "."Project (++precompiled_count == 1 ? "" : precompiled_count)"...c")
}

function make_compile(origin,    a,b,c,d,e,f,g,h,i,k,l,m,n) {

    if (!origin["length"] && !precompiled["length"]) { __error(USAGE); return }
    if (!Project) Project = get_FileNameNoExt(origin[1])

    if (!precompiled["length"]) {
    for (n = 1; n <= origin["length"]; ++n) {
        e = get_FileNameExt(origin[n])
        if (!(e in format)) { __error("make.awk: No Format for FileName."e); Array_remove(origin, n--); continue }
    }
    for (f = 1; f <= format["length"]; ++f) {
    for (n = 1; n <= origin["length"]; ++n) {
        e = get_FileNameExt(origin[n])
        if (format[e] != format[f]) continue

        C_prepare()
        c = format[e]"_""precompile"
        if (c in FUNCTAB) @c(origin[n])
        else { __error("make.awk: No Format function "c); continue }
    } } }
    if (!precompiled["length"]) { __error("make.awk: Nothing precompiled"); return }

    Array_clear(compiled); if (!C_compile()) { __error("make.awk: Nothing compiled"); return }

    File_printTo(compiled, "."Project (++compiled_count == 1 ? "" : compiled_count)"...o", "\n", "\n", 1)
}

