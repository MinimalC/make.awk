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
    fixFS = @/\xA0/
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

    USAGE = "make.awk: Use make.awk project=Program [preprocess] Program.c [precompile] [compile]"

    __BEGIN("compile")
}

END {
    if (DEBUG) {
        __debug("CSharp_Types: "); Array_debug(CSharp_Types)
        __debug("C_defines: "); for (n in C_defines) {
            rendered = Index_pull(C_defines[n]["body"], fixFS, " ")
            if (C_defines[n]["isFunction"])
                 __debug("# define "n" ( "C_defines[n]["arguments"]["text"]" ) "rendered)
            else __debug("# define "n"  "rendered)
        }
        __debug("C_types: "); Array_debug(C_types)
    }
}

function make_parse(origin,    a,b,c,d,e,f,m,n) {

    if (!origin["files"]["length"]) { __error(USAGE); return }
    if (!Project) Project = get_FileNameNoExt(origin["files"][1])
    #if (!prepared) make_prepare(origin)

    for (n = 1; n <= origin["files"]["length"]; ++n) {
        f = get_FileNameExt(origin["files"][n])
        if (!(f in format)) { __error("make.awk: No Format for FileName."f); List_remove(origin["files"], n--); continue }
        if (!((c = format[f]"_""parse") in FUNCTAB)) { __error("No function "c); continue }

        @c(origin["files"][n])
    }

    for (n in parsed) File_printTo(parsed[n], "."Project"...c")
}

function make_preprocess(origin,    a,b,c,C,d,e,f,F,g,h,i,j,k,l,m,n,N,o,p,pre,q,r,s,t,u,v,w,x,y,z) {

    if (!origin["files"]["length"]) { __error(USAGE); return }
    origin["next"]
    if (!Project) Project = get_FileNameNoExt(origin["files"][1])
    #if (!prepared) make_prepare(origin)

    for (f = 1; f <= format["length"]; ++f) {
        F = format[f]
    for (n = 1; n <= origin["files"]["length"]; ++n) {
        N = origin["files"][n]
        if (F != format[get_FileNameExt(N)]) continue
        if ((c = F"_""prepare_preprocess") in FUNCTAB) @c(origin)
        if (!((C = F"_""preprocess") in FUNCTAB)) { __error("make.awk: No function "C); continue }

        preproc[F][N]["length"]
        if (!@C(N)) continue
        #if (!preproc[F][N]["length"]) continue
        #preproc[F][ ++preproc[F]["length"] ] = N
        ++o

if (DEBUG) {
        Array_clear(pre)
if (DEBUG) Index_push("", fixFS, fix, "\0", "\n"); else
        Index_push("", fixFS, " ", "\0", "\n")
        for (z = 1; z <= preproc[F][N]["length"]; ++z)
            pre[++pre["length"]] = Index_reset(preproc[F][N][z])
        Index_pop()
        File_printTo(pre, "."Project (++preprocessed_count[F] == 1 ? "" : preprocessed_count[F])"...prep."F)
} # if (DEBUG)
    } }
    if (!o) { __error("make.awk: Nothing preprocessed"); return }
}

function make_precompile(origin,    a,b,c,C,d,e,f,F,g,h,i,j,k,l,m,n,N,o,p,pre,q,r,s,t,u,v,w,x,y,z) {

    if (!Project) { __error("make.awk: Project undefined"); return }

    for (f = format["length"]; f; --f) {
        F = format[f]
        if ((c = F"_""prepare_precompile") in FUNCTAB) @c(origin)
    for (n = 1; n <= origin["files"]["length"]; ++n) {
        N = origin["files"][n]
        if (F != format[get_FileNameExt(N)]) continue
        if (!((C = F"_""precompile") in FUNCTAB)) { __error("make.awk: No function "C); continue }

        precomp[F]["length"]
        if (!@C(N)) continue
        #if (!precomp[F]["length"]) continue
        ++o

        Array_clear(pre)
if (DEBUG) Index_push("", fixFS, fix, "\0", "\n")
else       Index_push("", fixFS, " ", "\0", "\n")
        for (z = 1; z <= precomp[F]["length"]; ++z)
            pre[++pre["length"]] = Index_reset(precomp[F][z])
        Index_pop()
        File_printTo(pre, "."Project (++precompiled_count[F] == 1 ? "" : precompiled_count[F])"..."F)
    } }
    if (!o) { __error("make.awk: Nothing precompiled"); return }
}

function make_compile(origin,    a,b,c,C,d,e,f,F,g,h,i,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) {

    if (!Project) { __error("make.awk: Project undefined"); return }

    for (f = 1; f <= format["length"]; ++f) {
        F = format[f]
        if (!((C = F"_""compile") in FUNCTAB)) { __error("make.awk: No function "C); continue }

        compiled[F]["length"]
        if (!@C()) continue
        #if (!compiled[F]["length"]) continue
        ++o

        File_printTo(compiled[F], "."Project (++compiled_count[F] == 1 ? "" : compiled_count[F])"..."F".o", "\n", "\n", 1)
    }
    if (!o) { __error("make.awk: Nothing compiled"); return }
}

