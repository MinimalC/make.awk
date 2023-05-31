#
# Gemeinfrei. Public Domain.

@include "run.awk"


function ASM_precompile(name,    __,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) {

    if (!precomp["ASM"][name]["0length"] && File_exists(name)) {
        File_read(precomp["ASM"][name], name)
        return 1
    }
    if (precomp["ASM"][name]["0length"])
        return 1
}

function ASM_compile(name,   __,a,b,c,d,directory,e,f,g,h,i,j,k,l,m,n,o,options,p,q,r,report,s,t,u,v,w,x,y,z) {
    # input is precomp["ASM"][name]["0length"]
    if (!(name in precomp["ASM"]) || !precomp["ASM"][name]["0length"]) return
    # output is compiled["ASM"][name]["0length"]

    directory = get_DirectoryName(name)
    options = "-I "directory" -o "TEMP_DIR".make.o "name

    report["0length"]
    r = __pipe(ASM_compiler, options, report)
    #File_debug(report)

    compiled["ASM"][name]["0length"]
    if (!r) {
        File_read(compiled["ASM"][name], TEMP_DIR".make.o", "\n", "\n", 1)
        File_remove(TEMP_DIR".make.o", 1)
    }
    return 1
}
