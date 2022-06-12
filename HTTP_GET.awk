#!/usr/bin/awk -f
# Public Domain
# 2022 Hans Riehm

@include "run.awk"

function set_HTTP_GET_name(value) {
    Name = value
}

function set_HTTP_GET_h(value) {
    hours = value
}

function set_HTTP_GET_m(value) {
    minutes = value
}

function set_HTTP_GET_s(value) {
    seconds = value
}

BEGIN { BEGIN_HTTP_GET() } END { END_HTTP_GET() }

function BEGIN_HTTP_GET( __,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) {

    DEBUG = 0
    hours = minutes = seconds = 0
    orderby = ""

    __BEGIN("download")
}

function END_HTTP_GET( __,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,storage,t,u,v,w,x,y,z) { }

function HTTP_GET_ARGC_ARGV(config) { RUN_ARGC_ARGV = 1 }

function HTTP_GET_ARGV_ARGC(config) { RUN_ARGC_ARGV = 1 }

function HTTP_GET_download(config,    __,a,b,c,d,date,e,ext,empty,f,file,g,h,i,j,k,l,m,n,o,p,q,r,response,s,t,t00,t01,t02,t10,t11,u,uri,v,w,x,y,z) {

    if (!("addresses" in config) || !config["addresses"]["0length"]) { __error("usage"); return }

    s = (hours * 3600) + (minutes * 60) + seconds
    do {
        c = t01 = 0
        t00 = systime()
        for (a = 1; a <= config["addresses"]["0length"]; ++a) {
            t10 = systime()
            t11 = 0
            uri["host"]
            if (!__URI(uri, config["addresses"][a])) {
                __error("HTTP GET: no URI: " config["addresses"][a])
                continue
            }
            __info("HTTP GET //"uri["host"]uri["path"](uri["query"]?"?"uri["query"]:""))
            Array_clear(response)
            Array_clear(headers)
            if (!HTTP_GET(config["addresses"][a], response, headers)) {
                __error("HTTP GET //"uri["host"]uri["path"]" "headers["Status"])
Array_debug(headers, 1)
                continue
            }
            t11 = systime()
Array_debug(headers, 1)
            ext = get_FileNameExt(uri["path"])
            file = get_FileNameNoExt(uri["path"])
            if (Name) file = Name"."file
            file = file"."strftime("%Y-%m-%d.%H-%M-%S", t11)"."ext
            if (orderby == "day") {
                date = strftime("%Y-%m-%d", t11)
                if (!Directory_exists(date)) create_Directory(date)
                file = date"/"file
            }
            File_printTo(response, file, "\n", "\n", 1)
__debug("\t"(t11 - t10)"s => "file)
            ++c
        }
        if (c && s) {
            t01 = systime()
            t = s - (t01 - t00); if (t < 0) t = 0
            if (t && !System_sleep(t)) break

            t02 = systime()
            #t01 = t01 - (t01 % 3)
            #t02 = t02 - (t02 % 3)
            #t = (s-t) - ((s-t) % 3)
if ((t02 - t01) > (t + 1)) __debug("HTTP_GET_download: is this hibernate ? s="s" t="t" s-t="(s-t)" t00="t00" t01="t01" t02="t02"; t02-t01="(t02-t01))
        }
    } while (s)
}
