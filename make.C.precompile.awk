#
# Gemeinfrei. Public Domain.
# 2021 Hans Riehm

#include "run.awk"
#include "make.C.awk"

function C_precompile(    __,a,b,c,d,e,f,g,h,i,j,k,l,m,n,name,o,p,q,r,s,t,u,v,w,x,y,z)
{
    if (!preproc["C"]["length"]) return



    # C_precompile is PROTOTYPE

    # precomp["C"][ precomp["C"]["length"] ] = "#"FIX (++precomp["C"]["length"]) FIX"\"make.awk\""

    for (n = 1; n <= preproc["C"]["length"]; ++n) {
        name = preproc["C"][n]
    for (z = 1; z <= preproc["C"][name]["length"]; ++z)
        precomp["C"][ ++precomp["C"]["length"] ] = preproc["C"][name][z]
    }

    return 1
}
