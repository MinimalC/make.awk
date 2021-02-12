#
# Gemeinfrei. Public Domain.
# 2020 Hans Riehm

#include "../make.awk/meta.awk"
#include "../make.awk/meta.CExpression_evaluate.awk"

function CSharp_parse(fileName, file,    a,b,c,comments,d,directory,e,f,g,h,hash,i,j,k,l,m,
                                         n,name,o,p,q,r,s,S,string,t,u,v,w,was,x,y,z,Z,zahl)
{
    return C_parse(fileName, file)
}

function CSharp_precompile(fileName,   a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) {
    if ( !(fileName in parsed) && !C_parse(fileName) ) return

    Index_push("", fixFS, fix, "\0", "\n")

    for (z = 1; z <= parsed[fileName]["length"]; ++z) {
        Index_reset(parsed[fileName][z])

        # for (i = 1; i <= NF; ++i) if ($i ~ /^[ \f\n\t\v]+$/) Index_remove(i--)

        # if ($1 == "using") precompiled[++precompiled["length"]] = "#"fix"define"fix"using_"$2
        parsed[fileName][z] = $0
    }

    Index_pop()
    return 1
}

