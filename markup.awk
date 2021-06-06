#!/usr/bin/awk -f

@include "../make.awk/meta.awk"

BEGIN {
    USAGE = "markup.awk"

    __BEGIN()
}

function markup_BEGIN(    a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) {
    __print("run markup_BEGIN "project)
}

function markup_encode(    a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) {
    __print("run markup_encode "project)
}

function markup_decode(    a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) {
    __print("run markup_decode "project)
}
