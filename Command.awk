#!/usr/bin/gawk -f
# Public Domain. Gemeinfrei

@include "run.awk"

function set_Command_name(value) {
    Name = value
}

function set_Command_h(value) {
    hours = value
}

function set_Command_m(value) {
    minutes = value
}

function set_Command_s(value) {
    seconds = value
}

BEGIN { BEGIN_Command() } END { END_Command() }

function BEGIN_Command( __,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) {

    DEBUG = 0
    hours = minutes = seconds = 0
    orderby = ""

    __BEGIN("run")
}

function END_Command( __,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,storage,t,u,v,w,x,y,z) { }

function Command_ARGC_ARGV(config) { RUN_ARGC_ARGV = 1 }

function Command_ARGV_ARGC(config) { RUN_ARGC_ARGV = 1 }

function Command_run(config,    __,a,b,c,d,date,e,ext,empty,f,file,g,h,i,j,k,l,m,n,o,p,q,r,response,s,t,t00,t01,t02,t10,t11,u,uri,v,w,x,y,z) {

    if (!("addresses" in config) || !config["addresses"]["0length"]) { __error("usage"); return }
    if (!("names" in config) || !config["names"]["0length"]) {
        config["names"][1] = "curl "(!DEBUG?"":"-s")
        ++config["names"]["0length"]
    }

    s = (hours * 3600) + (minutes * 60) + seconds
    while (1) {
        t00 = systime()
        t01 = 0
        for (a = 1; a <= config["addresses"]["0length"]; ++a) {
            t10 = systime()
            t11 = 0
            uri["host"]
            if (!__URI(uri, config["addresses"][a])) {
                __error("ERROR: Command GET: no URI: " config["addresses"][a])
                continue
            }
            __info("Command GET "uri[0])
            Array_clear(output)
            if (__pipe(config["names"][1], uri[0], output)) {
                __error("ERROR: Command GET "uri[0])
Array_debug(output, 1)
                continue
            }
            t11 = systime()
            ext = get_FileNameExt(uri["path"])
            file = get_FileNameNoExt(uri["path"])
            if (Name) file = Name"."file
            file = file"."get_DateTime(t11)"."ext
            if (orderby == "day") {
                date = get_Date(t11)
                if (!Directory_exists(date)) create_Directory(date)
                file = date"/"file
            }
            File_printTo(output, file, "\n", "\n", 1)
__debug("\t"(t11 - t10)"s => "file)
        }
        if (!s) break

        t01 = systime()
        t = s - (t01 - t00); if (t < 0) t = 0
        if (t && !System_sleep(t)) break

        t02 = systime()
        #t01 = t01 - (t01 % 3)
        #t02 = t02 - (t02 % 3)
        #t = (s-t) - ((s-t) % 3)
if ((t02 - t01) > (t + 1)) __debug("Command: is this hibernate ? s="s" t="t" s-t="(s-t)" t00="t00" t01="t01" t02="t02"; t02-t01="(t02-t01))
    }
}
