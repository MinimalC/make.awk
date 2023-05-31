#
# Gemeinfrei. Public Domain.

#include "run.awk"
#include "make.C.awk"

function C_prepare_precompile(config,    a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) {

    if (typeof(C_types) == "untyped") {
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
    }

    precomp["C"]["0length"]
}

function C_precompile(name,    __,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z)
{
    if (!(name in preproc["C"]) || !preproc["C"][name]["0length"]) return

    # C_precompile is PROTOTYPE


    for (z = 1; z <= preproc["C"][name]["0length"]; ++z)
        precomp["C"][name][ ++precomp["C"][name]["0length"] ] = preproc["C"][name][z]

    return 1
}
