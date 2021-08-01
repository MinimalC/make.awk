#
# Gemeinfrei. Public Domain.
# 2021 Hans Riehm

#include "../make.awk/meta.awk"
#include "../make.awk/meta.CExpression_evaluate.awk"

function CSharp_prepare(config,    a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z)
{

}

function CSharp_parse(fileName, file) {
    return C_parse(fileName, file)
}

function CSharp_preprocess(fileName, output) {
    return C_preprocess(fileName, output)
}

function CSharp_precompile(output,   a,b,c,d,e,expressions,f,g,h,i,I,j,k,l,level,m,n,o,p,pre,q,r,s,t,u,v,w,x,y,z)
{
    for (z = 1; z <= preprocessed["CSharp"]["length"]; ++z)
        pre = pre fix preprocessed["CSharp"][z]

Index_push(pre, fixFS, fix, "\0", "\n")
for (i = I + 1; i <= NF; ++i) {

    if ($i == "using") {

    }

}
Index_pop()
    return 1
}

function CSharp_compile(output,   a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z)
{

}

