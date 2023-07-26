#!/usr/bin/awk -f
# Gemeinfrei. Public Domain.

@include "run.awk"
@include "make.C.awk"
@include "make.ASM.awk"

# HINTS:
# la *.c .*.c 2>/dev/null | ./.awk '{ if ($1 !~ /\.auto/) print "# include \""$1"\"" }'

function set_make_project(wert) { Project = wert }
function set_make_debug(wert) { DEBUG = wert }
function set_make_cc(wert) { C_compiler = wert }
function set_make_asm(wert) { ASM_compiler = wert }
function set_make_ld(wert) { C_linker = wert }
function set_make_shared(wert) { C_link_shared = wert }
function set_make_enableComments(wert) { enable_Comments = wert }

function set_make_std(wert) {
    if (typeof(wert) == "untyped" || typeof(wert) == "number" && !wert) STANDARD = "MINIMAL"
    else STANDARD = wert
}

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

END { END_make() }

function BEGIN_make() {

    __error("make.awk " get_DateTime())

    REFIX = @/\x01/
      FIX = "\x01"
    DEFIX = "`"

    Format["h"] = "C"
    Format["c"] = "C"
    Format["S"] = "ASM"
    Format["ASM"] = "ASM"

    Format[1] = "C"
    Format[2] = "ASM"
    Format["0length"] = 2

    STANDARD = "ISO"

    if ("PROCESSOR_ARCHITECTURE" in ENVIRON) {
        PLATFORM = "Windows"
        ARCHITECTURE = ENVIRON["PROCESSOR_ARCHITECTURE"]
        C_compiler = "cl"
        ASM_compiler = "nasm"
        C_linker = "link"
    }
    else {
        PLATFORM = uname_operatingSystem()
        ARCHITECTURE = uname_machine() # "GNU/Linux"
        C_compiler = "gcc"
        ASM_compiler = "as"
        C_linker = "gcc"
    }

    createTemp_Directory(".make")

    USAGE =\
    "make.awk project=Program [options] [preprocess] [precompile] Program.c [compile]\n"\
    "\n"\
    "Options:\n"\
    "    project=Name for a custom Project\n"\
    "    cc=customcc for a custom C_compiler\n"\
    "    -std for MINIMAL STANDARD, default is ISO\n"\
    "\n"\
    "C_preprocess'ing:\n"\
    "    +enableComments for not removing comments\n"\
    "    -DDEBUG or +DDEBUG for boolean true 1 or false 0, or DDEBUG=3 for the value 3"

    __BEGIN("compile")
}

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
    File_printTo(pre, TEMP_DIR Project"...C")
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
        if (!short) continue # warning

        preproc[format][name]["0length"]
        if ((c = format"_""prepare_preprocess") in FUNCTAB) @c(config)
        if (!((C = format"_""preprocess") in FUNCTAB)) { __error("make.awk: No function "C); continue }
        if (!@C(name)) { __error("make.awk: No "C" "name); List_remove(config["files"], n--) }
        if (!preproc[format][name]["0length"]) continue
        pre["0length"]; Array_clear(pre)
        Index_pullArray(pre, preproc[format][name], REFIX, DEBUG ? DEFIX : " ")
        File_printTo(pre, TEMP_DIR Project short"..."format)
        ++o
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
        if (!short) continue # warning

        if ((C = format"_""preprocess") in FUNCTAB) {
            preproc[format][name]["0length"]
            if ((c = format"_""prepare_preprocess") in FUNCTAB) @c(config)
            if (!@C(name)) { __error("make.awk: No "C" "name); List_remove(config["files"], n--); continue }
            if (!preproc[format][name]["0length"]) continue
            pre["0length"]; Array_clear(pre)
            Index_pullArray(pre, preproc[format][name], REFIX, DEBUG ? DEFIX : " ")
            File_printTo(pre, TEMP_DIR short"..."format)
        }

        precomp[format][name]["0length"]
        if ((c = format"_""prepare_precompile") in FUNCTAB) @c(config)
        if (!((C = format"_""precompile") in FUNCTAB)) { __error("make.awk: No function "C); continue }
        if (!@C(name)) { __error("make.awk: No "C" "name); continue }
        if (!precomp[format][name]["0length"]) continue
        pre["0length"]; Array_clear(pre)
        Index_pullArray(pre, precomp[format][name], REFIX, DEBUG ? DEFIX : " ")
        File_printTo(pre, TEMP_DIR short"..."format)
        ++o
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
        if (!short) continue # warning

        if ((C = format"_""preprocess") in FUNCTAB && !preproc[format][name]["0length"]) {
            if ((c = format"_""prepare_preprocess") in FUNCTAB) @c(config)
            if (!@C(name)) { __error("make.awk: No "C" "name); List_remove(config["files"], n--); continue }
            if (!preproc[format][name]["0length"]) continue
            pre["0length"]; Array_clear(pre)
            Index_pullArray(pre, preproc[format][name], REFIX, DEBUG ? DEFIX : " ")
            File_printTo(pre, TEMP_DIR short"..."format)
        }

        if ((C = format"_""precompile") in FUNCTAB && !precomp[format][name]["0length"]) {
            if ((c = format"_""prepare_precompile") in FUNCTAB) @c(config)
            if (!@C(name)) { __error("make.awk: No "C" "name); continue }
            if (!precomp[format][name]["0length"]) continue
            pre["0length"]; Array_clear(pre)
            Index_pullArray(pre, precomp[format][name], REFIX, DEBUG ? DEFIX : " ")
            File_printTo(pre, TEMP_DIR short"..."format)
        }

        compiled[format][name]["0length"]
        if (!((C = format"_""compile") in FUNCTAB)) { __error("make.awk: No function "C); continue }
        if (!@C(name)) { __error("make.awk: No "C" "name); continue }
        if (format == "C" && precomp["ASM"][name]["0length"]) {
            file = precomp["ASM"][name]["file"] = TEMP_DIR short"...ASM"
            File_printTo(precomp["ASM"][name], file, "\n", "\n")
            precomp["ASM"][file]["length"]
            List_copy(precomp["ASM"][name], precomp["ASM"][file])
            Array_clear(precomp["ASM"][name])
            config["files"][ n ] = file
__debug("C_compile: "C_compiler" "name)
            continue
        }
        if (compiled[format][name]["0length"]) {
            file = compiled[format][name]["file"] = TEMP_DIR short"...o"
            File_printTo(compiled[format][name], file, "\n", "\n", 1)
            compiled[format][ ++compiled[format]["0length"] ] = name
            ++o
__debug("C_compile: "C_compiler" "name)
            continue
        }
    } }
    if (!o) { __error("make.awk: Nothing compiled"); return }
}

function make_library(config,    __,a,b,c,C,d,e,f,format,g,h,i,j,k,l,m,n,name,names,o,options,p,q,r,s,short,t,u,unseen,v,w,x,y,z) {
Array_debug(config)

    for (f = 1; f <= Format["0length"]; ++f) {
        format = Format[f]
    for (s = 1; s <= compiled[format]["0length"]; ++s) {
        name = compiled[format][s]
        names = String_concat(names, " ", compiled[format][name]["file"])
    } }
    if (!names) return

    if (C_link_shared) {
        for (n = 1; n <= config["files"]["0length"]; ++n) {
            name = config["files"][n]
            if (get_FileNameExt(name) == "so") names = String_concat("-l:"name, " ", names)
        }

        options = "-shared"

        if (STANDARD == "MINIMAL")
# ACHTUNG
            options = options" -nostdlib -nostartfiles -nodefaultlibs -ffreestanding"
        else # if (STANDARD == "ISO")
            options = options" -lm -ldl -pthread"

        options = options" -Wl,-soname=\""(STANDARD == "ISO"?"lib":"") Project".so\""

        options = options" -o "TEMP_DIR (STANDARD == "ISO"?"lib":"") Project".so"" "names

__debug("C_link_library: "C_linker" "options)
        unseen["0length"]
        __pipe(C_linker, options, unseen)
if (unseen["0length"]) File_debug(unseen)
        ++o
    }
    else {
        for (n = 1; n <= config["files"]["0length"]; ++n) {
            name = config["files"][n]
            if (get_FileNameExt(name) == "a") names = String_concat("-l:"name, " ", names)
        }

        options = "rcs "TEMP_DIR (STANDARD == "ISO"?"lib":"") Project".a"
        options = options" "names

__debug("C_static_library: ar "options)
        unseen["0length"]
        __pipe("ar", options, unseen)
if (unseen["0length"]) File_debug(unseen)
        ++o
    }

    if (!o) { __error("make.awk: No Library built"); return }
}

function make_executable(config,    __,a,b,c,C,C_target,d,e,empty,f,f0,file,final_options,format,g,h,i,j,k,l,m,n,n0,name,names,o,options,p,pre,q,r,s,short,t,u,unseen,v,w,x,y,z) {
Array_debug(config)

    for (f = 1; f <= Format["0length"]; ++f) {
        format = Format[f]
    for (n = 1; n <= config["files"]["0length"]; ++n) {
        name = config["files"][n]
        if (format != Format[get_FileNameExt(name)]) continue
        short = get_FileNameNoExt(name)
        if (!short) continue # warning

        if ((C = format"_""preprocess") in FUNCTAB && !preproc[format][name]["0length"]) {
            if ((c = format"_""prepare_preprocess") in FUNCTAB) @c(config)
            if (!@C(name)) { __error("make.awk: No "C" "name); List_remove(config["files"], n--); continue }
            if (!preproc[format][name]["0length"]) continue
            pre["0length"]; Array_clear(pre)
            Index_pullArray(pre, preproc[format][name], REFIX, DEBUG ? DEFIX : " ")
            File_printTo(pre, TEMP_DIR short"..."format)
        }

        if ((C = format"_""precompile") in FUNCTAB && !precomp[format][name]["0length"]) {
            if ((c = format"_""prepare_precompile") in FUNCTAB) @c(config)
            if (!@C(name)) { __error("make.awk: No "C" "name); continue }
            if (!precomp[format][name]["0length"]) continue
            pre["0length"]; Array_clear(pre)
            Index_pullArray(pre, precomp[format][name], REFIX, DEBUG ? DEFIX : " ")
            File_printTo(pre, TEMP_DIR short"..."format)
        }

        if (!((C = format"_""compile") in FUNCTAB)) { __error("make.awk: No function "C); continue }
        if (!@C(name)) { __error("make.awk: No "C" "name); continue }
        if (format == "C" && precomp["ASM"][name]["0length"]) {
            file = precomp["ASM"][name]["file"] = TEMP_DIR short"...ASM"
            File_printTo(precomp["ASM"][name], file, "\n", "\n")
            precomp["ASM"][file]["length"]
            List_copy(precomp["ASM"][name], precomp["ASM"][file])
            Array_clear(precomp["ASM"][name])
            config["files"][ n ] = file
__debug("C_compile: "C_compiler" "name)
            continue
        }
        if (compiled[format][name]["0length"]) {
            file = compiled[format][name]["file"] = TEMP_DIR short"...o"
            File_printTo(compiled[format][name], file, "\n", "\n", 1)
            # do not compiled[format][ ++compiled[format]["0length"] ] = name
__debug("C_compile: "C_compiler" "name)
            continue
        }
    } }

    if (STANDARD == "MINIMAL")
        options = options" -nostdlib -nostartfiles -nodefaultlibs -ffreestanding"
    else # if (STANDARD == "ISO")
        options = options" -lm -ldl -pthread"

    options = options" -L"TEMP_DIR

    if (C_link_shared) {
        options = options" -shared -pie"
        for (n = 1; n <= config["names"]["0length"]; ++n) {
            name = config["names"][n]
            if (get_FileNameExt(name) == "so") final_libraries = String_concat(" -l:"name, " ", final_libraries)
        }
    }
    else {
        options = options" -static"
        for (n = 1; n <= config["names"]["0length"]; ++n) {
            name = config["names"][n]
            if (get_FileNameExt(name) == "a") final_libraries = String_concat(" -l:"name, " ", final_libraries)
        }
    }

    for (f = 1; f <= Format["0length"]; ++f) {
        format = Format[f]
    for (n = 1; n <= config["files"]["0length"]; ++n) {
        name = config["files"][n]
        file = compiled[format][name]["file"]
        short = get_FileNameNoExt(file)
        if (!short) continue # warning

        if (STANDARD == "MINIMAL") {
            final_options = options" -o "TEMP_DIR short
            if (short == "System.Interpreter") {
                final_options = final_options" -Wl,--no-dynamic-linker"
                for (f0 = 1; f0 <= Format["0length"]; ++f0) {
                for (n0 = 1; n0 <= compiled[format]["0length"]; ++n0) {
                    final_options = String_concat(final_options, " ", compiled[ Format[f0] ][  compiled[ Format[f0] ][n0]  ]["file"])
                } }
                final_options = final_options" "TEMP_DIR"System.Runtime."(!C_link_shared?"static":"shared")"...o"
                final_options = final_options" "file
                final_options = final_options" -Wl,-soname=\""short"\""
            }
            else {
                final_options = final_options" -Wl,--dynamic-linker=System.Interpreter"
                if (short != "System.Runtime.static" && short != "System.Runtime.shared")
                    final_options = final_options" "TEMP_DIR"System.Runtime."(!C_link_shared?"static":"shared")"...o"
                final_options = final_options" "file
                final_options = final_options final_libraries" -l:"Project"."(!C_link_shared?"a":"so")
                final_options = final_options" -Wl,-soname=\""short"\""
            }
        }
        else { # if STANDARD == "ISO"
            final_options = options" -o "TEMP_DIR short
            final_options = final_options" "file
            final_options = final_options final_libraries" -l:" (STANDARD == "ISO"?"lib":"") Project"."(!C_link_shared?"a":"so")
            final_options = final_options" -Wl,-soname=\""short"\""
        }

__debug("C_link_executable: "C_linker" "final_options)
        unseen["0length"]
        __pipe(C_linker, final_options, unseen)
if (unseen["0length"]) File_debug(unseen)
    } }

    # ++o if (!o) { __error("make.awk: No executable linked"); return }
}
