#!/usr/bin/awk -f
# Gemeinfrei. Public Domain.

#include "run.awk"

BEGIN { BEGIN_run() }
END { END_run() }

function BEGIN_run(    __,a,argi,config,f,file,fileName,i,includeDir,input,o,output,options,r,runDir,u,usage,unseen,w,workingDir) {
    LC_ALL="C"
    PROCINFO["sorted_in"] = "@ind_num_asc"

    FS="";OFS="";RS="\0";ORS="\n"

    if (__HEX(2 ^ 64) == "10000000000000000") MAX_INTEGER = 2 ^ 64          # awk --bignum with MPFR
    else if (__HEX(2 ^ 63) == "8000000000000000") MAX_INTEGER = 2 ^ 63  # awk on 64bit
    else MAX_INTEGER = 2 ^ 31 # if (__HEX(2 ^ 31) == "80000000")    # awk on 32bit
    # else MAX_INTEGER = 2 ^ 15  # if (__HEX(2 ^ 15) == "8000") # awk on 16bit ?
    # else MAX_INTEGER = 2 ^ 7 # if (__HEX(2 ^ 7) == "80")  # awk on 8bit :-)

    if (ARGV[0] == "awk" || ARGV[0] == "gawk")
        for (i = 1; i < length(PROCINFO["argv"]); ++i)
            if (PROCINFO["argv"][i] == "-f") {
                f = get_FileName(PROCINFO["argv"][i + 1])
                if (ARGV[1] == f) ARGV_remove(1)
                ARGV[0] = f
                break
            }
    if (!("PWD" in ENVIRON)) {
        unseen["0length"]
        __pipe("pwd", "", unseen)
        ENVIRON["PWD"] = unseen[1]
    }
    if (ARGV[0] == "run.awk" && ENVIRON["AWKPATH"] ~ /^\.:/) {
        usage = "Use run.awk Project.awk [command] [Directory] [File.name]\n"\
            "with a Project.awk BEGIN { __BEGIN(\"command\") } and function Project_command(config) { }"
        if (ARGV_length() == 0) { __error(usage); exit }

        workingDir = ENVIRON["PWD"]
        if (workingDir && workingDir !~ /\/$/) workingDir = workingDir"/"

        for (i = 1; i <= ARGV_length(); ++i) {
            if (!ARGV[i]) continue
            if ((f = "run_"ARGV[i]) in FUNCTAB) { @f(); continue }
            if (ARGV[i] ~ /^@.+/) {
                config = get_FileName(substr(ARGV[i], 2)); ARGV[i] = ""
                f = File_exists(config)
                if (!f && includeDir) f = File_exists(includeDir config)
                if (!f && workingDir) f = File_exists(workingDir config)
                if (!f) { __error("run.awk: @config file "config" doesn't exist"); config = ""; continue }
                continue
            }
            if (ARGV[i] ~ /\..+$/) {
                includeDir = get_DirectoryName(ARGV[i])
                if (includeDir && includeDir !~ /\/$/) includeDir = includeDir"/"
                fileName = get_FileName(ARGV[i])
                f = File_exists(fileName)
                if (!f && includeDir) f = File_exists(includeDir fileName)
                if (!f && workingDir) f = File_exists(workingDir fileName)
                if (!f) {
                    f = EnvironmentFile_exists(fileName)
                    if (f) includeDir = get_DirectoryName(f)
                }
                if (!f) { __error("run.awk: File or Function "fileName" doesn't exist"); continue }
                ARGV[i] = ""; options = ""; for (o = i + 1; o <= ARGV_length(); ++o) options = options" "ARGV[o]
                Array_clear(input); Array_clear(output)
                r = __gawk((!config?"":"-i "config" ")"-f "f" -- "options, input, output, workingDir, "AWKPATH="(!includeDir?"":includeDir":")"."" PWD="workingDir)
                File_printTo(output, "/dev/stdout")
                exit r
            }
        }
        __error(usage); exit
    }
}

function END_run() {
    # don't if (ERRORS) exit 0; else exit 1
    if (Index["0length"]) __error("run.awk: More Index_push() than Index_pop()")
    if (RUN_ARGC_ARGV) ARGC_ARGV_debug()
}

function run_ARGV_ARGC(config) { RUN_ARGC_ARGV = 1 }

function run_ARGC_ARGV(config) { RUN_ARGC_ARGV = 1 }

function run_install(config,    __, pwd) {
    if (!sudo_isAdministrator()) { __print("Usage: sudo ./run.awk install"); exit }
    File_remove("/usr/bin/run.awk", 1)
    pwd = ENVIRON["PWD"]"/"
    if (create_Link("/usr/bin/", "run.awk", pwd"run.awk")) {
        __print("/usr/bin/run.awk is now linked to "pwd"run.awk.")
        if (create_Link("/usr/bin/", "make.awk", pwd"make.awk"))
            __print("/usr/bin/make.awk is now linked to "pwd"make.awk.")
        exit 1
    }
    exit
}

function __BEGIN(controller, action, usage,
    null,a,b,c,config,d,default,e,f,file,g,h,i,includeDir,j,k,l,m,make,runDir,
    n,o,options,output,p,paramName,paramWert,q,r,s,t,u,v,w,workingDir,x,y,z)
{   # CONTROLLER, ACTION, USAGE, ERRORS

    if (typeof(null) != "untyped")
        __warning("run.awk: Use __BEGIN with just three arguments:\n"\
                  "__BEGIN(action), __BEGIN(action, usage) or __BEGIN(controller, action, usage)")

    if (typeof(action) == "untyped") {
        action = controller
        controller = ""
    }
    else if (typeof(usage) == "untyped") {
        usage = action
        action = controller
        controller = ""
    }
    if (!usage) {
        if (!(usage = USAGE)) usage = "Use USAGE = \"to say what Project you are working on\""
    }
    if (!controller) {
        if (typeof(CONTROLLER) != "untyped") controller = CONTROLLER
        #else if (PROCINFO["argv"][1] == "-f") controller = get_FileNameNoExt(PROCINFO["argv"][2])
        else if (ARGV[0] != "gawk") controller = get_FileNameNoExt(ARGV[0])
        if (!controller) { __error(usage); exit }
    }
    if ( typeof(CONTROLLER) == "untyped" ) CONTROLLER = controller
    if (action) { default = action; action = "" }

    if ((c = "configure") in FUNCTAB) @c()

    delete config
    for (i = 1; i <= ARGV_length(); ++i) {
        if (ARGV[i] ~ /^\s*$/) continue
        if (controller"_"ARGV[i] in FUNCTAB) {
            if (i > 1 && action) {
                if (!((make = controller"_"action) in FUNCTAB)) { __error(controller".awk: Unknown method "make); exit }
                @make(config); if ("next" in config) delete config["next"]; else delete config # Array_clear(config)
            }
            action = ARGV[i]
            ARGV[i] = ""; continue
        }
        paramName = paramWert = ""
        if (ARGV[i] ~ /^.*=/) {
            paramWert = index(ARGV[i], "=")
            paramName = substr(ARGV[i], 1, paramWert - 1)
            paramWert = substr(ARGV[i], paramWert + 1)
        } else
        if (ARGV[i] ~ /^\+/ || ARGV[i] ~ /^-/) {
            paramWert = substr(ARGV[i], 1, 1)
            paramName = substr(ARGV[i], 2)
            paramWert = paramWert == "+" ? 1 : 0
        } else
        if (ARGV[i] ~ /\+$/ || ARGV[i] ~ /-$/) {
            l = length(ARGV[i])
            paramWert = substr(ARGV[i], l, 1)
            paramName = substr(ARGV[i], 1, l - 1)
            paramWert = paramWert == "+" ? 1 : 0
        }
        if (paramName) {
          # if (paramName == "debug") DEBUG = paramWert; else
            if (paramName in SYMTAB) SYMTAB[paramName] = paramWert
            else if ((make = "set_"controller"_"paramName) in FUNCTAB) @make(paramWert)
            else config["names"][paramName] = paramWert
            ARGV[i] = ""; continue
        }
        if (ARGV[i] ~ /^https?:/ || ARGV[i] ~ /^\/\//) {
            config["addresses"][++config["addresses"]["0length"]] = ARGV[i]
            ARGV[i] = ""; continue
        }
        if (Directory_exists(ARGV[i])) {
            config["directories"][++config["directories"]["0length"]] = ARGV[i]
            ARGV[i] = ""; continue
        }
        if (File_exists(ARGV[i])) {
            config["files"][++config["files"]["0length"]] = ARGV[i]
            ARGV[i] = ""; continue
        }
        if (ARGV[i]) {
            config["names"][ ++config["names"]["0length"] ] = ARGV[i]
            # __warning(controller".awk: Unknown File, command or parameter not found: "ARGV[i])
            ARGV[i] = ""
        }
    }
    if (!action) {
        if (typeof(ACTION) != "untyped" && ACTION) action = ACTION
        else if (default) action = default
        else action = "BEGIN"
    }
    if (!((make = controller"_"action) in FUNCTAB)) __error(controller".awk: Unknown method "make)
    else @make(config)

    if (typeof(ERRORS) == "number" && ERRORS) exit
    exit 1
}

function __printTo(to,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,  __,msg) {
    if (typeof(a) != "untyped") msg = String_concat(msg, " ", a)
    if (typeof(b) != "untyped") msg = String_concat(msg, " ", b)
    if (typeof(c) != "untyped") msg = String_concat(msg, " ", c)
    if (typeof(d) != "untyped") msg = String_concat(msg, " ", d)
    if (typeof(e) != "untyped") msg = String_concat(msg, " ", e)
    if (typeof(f) != "untyped") msg = String_concat(msg, " ", f)
    if (typeof(g) != "untyped") msg = String_concat(msg, " ", g)
    if (typeof(h) != "untyped") msg = String_concat(msg, " ", h)
    if (typeof(i) != "untyped") msg = String_concat(msg, " ", i)
    if (typeof(j) != "untyped") msg = String_concat(msg, " ", j)
    if (typeof(k) != "untyped") msg = String_concat(msg, " ", k)
    if (typeof(l) != "untyped") msg = String_concat(msg, " ", l)
    if (typeof(m) != "untyped") msg = String_concat(msg, " ", m)
    if (typeof(n) != "untyped") msg = String_concat(msg, " ", n)
    if (typeof(o) != "untyped") msg = String_concat(msg, " ", o)
    if (typeof(p) != "untyped") msg = String_concat(msg, " ", p)
    if (typeof(q) != "untyped") msg = String_concat(msg, " ", q)
    if (typeof(r) != "untyped") msg = String_concat(msg, " ", r)
    if (typeof(s) != "untyped") msg = String_concat(msg, " ", s)
    if (typeof(t) != "untyped") msg = String_concat(msg, " ", t)
    if (typeof(u) != "untyped") msg = String_concat(msg, " ", u)
    if (typeof(v) != "untyped") msg = String_concat(msg, " ", v)
    if (typeof(w) != "untyped") msg = String_concat(msg, " ", w)
    if (typeof(x) != "untyped") msg = String_concat(msg, " ", x)
    if (typeof(y) != "untyped") msg = String_concat(msg, " ", y)
    if (typeof(z) != "untyped") msg = String_concat(msg, " ", z)
    if (msg) print msg > to
}

function __printFTo(to,format,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,  __,msg) {
    if (typeof(a) != "untyped") msg = String_concat(msg, " ", a)
    if (typeof(b) != "untyped") msg = String_concat(msg, " ", b)
    if (typeof(c) != "untyped") msg = String_concat(msg, " ", c)
    if (typeof(d) != "untyped") msg = String_concat(msg, " ", d)
    if (typeof(e) != "untyped") msg = String_concat(msg, " ", e)
    if (typeof(f) != "untyped") msg = String_concat(msg, " ", f)
    if (typeof(g) != "untyped") msg = String_concat(msg, " ", g)
    if (typeof(h) != "untyped") msg = String_concat(msg, " ", h)
    if (typeof(i) != "untyped") msg = String_concat(msg, " ", i)
    if (typeof(j) != "untyped") msg = String_concat(msg, " ", j)
    if (typeof(k) != "untyped") msg = String_concat(msg, " ", k)
    if (typeof(l) != "untyped") msg = String_concat(msg, " ", l)
    if (typeof(m) != "untyped") msg = String_concat(msg, " ", m)
    if (typeof(n) != "untyped") msg = String_concat(msg, " ", n)
    if (typeof(o) != "untyped") msg = String_concat(msg, " ", o)
    if (typeof(p) != "untyped") msg = String_concat(msg, " ", p)
    if (typeof(q) != "untyped") msg = String_concat(msg, " ", q)
    if (typeof(r) != "untyped") msg = String_concat(msg, " ", r)
    if (typeof(s) != "untyped") msg = String_concat(msg, " ", s)
    if (typeof(t) != "untyped") msg = String_concat(msg, " ", t)
    if (typeof(u) != "untyped") msg = String_concat(msg, " ", u)
    if (typeof(v) != "untyped") msg = String_concat(msg, " ", v)
    if (typeof(w) != "untyped") msg = String_concat(msg, " ", w)
    if (typeof(x) != "untyped") msg = String_concat(msg, " ", x)
    if (typeof(y) != "untyped") msg = String_concat(msg, " ", y)
    if (typeof(z) != "untyped") msg = String_concat(msg, " ", z)
    if (!format) format = "%s"
    if (msg) printf format, msg > to
}

function __print(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) {
    __printTo("/dev/stdout",a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z)
}

function __warning(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) {
    __printTo("/dev/stderr",a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z)
}

function __info(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) {
    __printTo("/dev/stderr",a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z)
}

function __error(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) {
    ERRORS; if (typeof(ERRORS) == "unassigned" || typeof(ERRORS) == "number") ++ERRORS
    else __warning("__error: ERRORS should be number")
    __printTo("/dev/stderr",a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z)
}

function __debug(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) {
    if ("DEBUG" in SYMTAB && SYMTAB["DEBUG"])
        __printTo("/dev/stderr",a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z)
}

function __debugF(format,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) {
    if ("DEBUG" in SYMTAB && SYMTAB["DEBUG"])
        __printFTo("/dev/stderr",format,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z)
}

function ARGV_contains(item,    __,t,type,u,v) {
    type = typeof(item)
    if (type == "array") { __error("ARGV_contains doesn't work with arrays"); return }
    for (v = 1; v < ARGC; ++v)
        if (type == "regex" && ARGV[v] ~ item) { u = v; break }
        else if (ARGV[v] == item) { u = v; break }
    return u
}

function ARGV_add(item,    __,r) {
    ARGV[r = ARGC++] = item
    return r
}

function ARGV_remove(i,   __,n) {
    for (n = ARGC - 1; n > i; --n) ARGV[n - 1] = ARGV[n]
    --ARGC
}

function ARGV_insert(i, item,    __,n) {
    ++ARGC
    for (n = i; n < ARGC - 1; ++n) ARGV[n + 1] = ARGV[n]
    ARGV[i] = item
}

function ARGV_length() {
    return ARGC - 1
}

function Array_printTo(array, to, level,    __,at,h,i,it,l,lt,t) {
    if ((at = typeof(array)) == "untyped" || at == "unassigned") return
    else if (at != "array") { __error("Array_printTo: array is typeof "at); return }
    if (!length(array)) return
    if ((lt = typeof(level)) == "number") t = String_repeat("\t", level)
    else if (lt != "untyped") { __error("Array_printTo: level is typeof "lt); return }
    if (typeof(to) == "untyped") to = "/dev/stdout"

    for (i in array)
        if ((it = typeof(array[i])) == "unassigned")
            print t i > to
        else if (it == "array") {
            print t i ": " > to
            Array_printTo(array[i], to, level + 1)
        } else
            print t i ": " array[i] > to
}

function Array_print(array, level) {
    Array_printTo(array, "/dev/stdout", level)
}

function Array_error(array, level,    __,et) {
    ERRORS; if ((et = typeof(ERRORS)) == "unassigned" || et == "number") ++ERRORS
    else __warning("Array_error: ERRORS is typeof "et)
    Array_printTo(array, "/dev/stderr", level)
}

function Array_debug(array, level) {
    if ("DEBUG" in SYMTAB && SYMTAB["DEBUG"]) Array_printTo(array, "/dev/stderr", level)
}

function ENVIRON_debug() {
    print "ENVIRON" >"/dev/stderr"
    Array_printTo(ENVIRON, "/dev/stderr", 1)
}

function PROCINFO_debug() {
    print "PROCINFO" >"/dev/stderr"
    Array_printTo(PROCINFO, "/dev/stderr", 1)
}

function SYMTAB_debug() {
    print "SYMTAB" >"/dev/stderr"
    Array_printTo(SYMTAB, "/dev/stderr", 1)
}

function FUNCTAB_debug() {
    print "FUNCTAB" >"/dev/stderr"
    Array_printTo(FUNCTAB, "/dev/stderr", 1)
}

function ARGV_debug() {
    print "ARGV" >"/dev/stderr"
    Array_printTo(ARGV, "/dev/stderr", 1)
}

function ARGC_ARGV_debug() {
    # ENVIRON_debug() # in gawk 5.1, this is in SYMTAB
    # PROCINFO_debug()
    # FUNCTAB_debug()
    SYMTAB_debug()
    # ARGV_debug()
}

function File_exists(fileName) {
    if (!fileName) { __error("File_exists: no fileName"); return }
    if (!system("test -e '"fileName"'")) return fileName
}

function EnvironmentFile_exists(fileName,    __,file,i,list,path) {
    if (!fileName) { __error("File_exists: no fileName"); return }
    path["0length"] = split(ENVIRON["PATH"], path, ":")
    for (i = 1; i <= path["0length"]; ++i) {
        file = path[i]"/"fileName
        if (!system("test -e '"file"'")) {
            Array_clear(list)
            __pipe("readlink", "-f "file, list)
            return list[1]
        }
    }
}

function Directory_exists(directory) {
    if (!directory) { __error("Directory_exists: no directory"); return }
    if (!system("test -d '"directory"'")) return directory
}

# Look: this is running bash "cd xyz", but not changing the directory in the awk process:
#function change_Directory(directory) {
#    if (!directory) { __error("change_Directory: no directory"); return }
#    if (!system("cd '"directory"'")) return 1
#}

function create_Directory(directory) {
    if (!directory) { __error("create_Directory: no directory"); return }
    if (!system("mkdir -p '"directory"'")) return 1
}

function remove_Directory(directory) {
    if (!directory) { __error("remove_Directory: no directory"); return }
    if (!system("rm -r '"directory"'")) return 1
}

function createTemp_Directory(prefix) {
    if (typeof(prefix) == "untyped") { __error("createTemp_Directory: no prefix"); return }
    TEMP_DIR = prefix
    # someone should add random data
    if (!String_endsWith(TEMP_DIR, "/")) TEMP_DIR = TEMP_DIR"/"
    if (!Directory_exists(TEMP_DIR)) create_Directory(TEMP_DIR)
}

function removeTemp_Directory() {
    TEMP_DIR; if (typeof(TEMP_DIR) == "unassigned") { __error("removeTemp_Directory: no TEMP_DIR"); return }
    if (Directory_exists(TEMP_DIR)) remove_Directory(TEMP_DIR)
}

function Directory_list(directory, list,   __,t) {
    if (!directory) { __error("Directory_list: no directory"); return }
    if (!list) { __error("Directory_list: no list"); return }
    if ((t = typeof(list)) != "array") { __error("Directory_list: list is typeof "t); return }
    __list(".", list, directory)
}

function create_SymbolicLink(directory, name, target) {
    if (!directory) { __error("create_SymbolicLink: no directory"); return }
    if (!name) { __error("create_SymbolicLink: no name"); return }
    if (!target) { __error("create_SymbolicLink: no target"); return }
    if (!system("cd '"directory"' ; ln -s '"target"' '"name"'")) return 1
}

function create_Link(directory, name, target) {
    if (!directory) { __error("create_Link: no directory"); return }
    if (!name) { __error("create_Link: no name"); return }
    if (!target) { __error("create_Link: no target"); return }
    if (!system("cd '"directory"' ; ln '"target"' '"name"'")) return 1
}

function Link_exists(target,    __,list) {
    if (!target) { __error("Link_exists: no target"); return }
    if (!system("test -L '"target"'")) {
        Array_clear(list)
        __pipe("readlink", "-f "target, list)
        return list[1]
    }
}

function File_contains(fileName, string,    __,i,r,y) {
    if (!fileName) { __error("File_contains: no fileName"); return }
    if (!string) { __error("File_contains: no string"); return }
    #if (!system("grep -r '"string"' "fileName" >/dev/null")) return 1
    while (0 < y = (getline i < fileName))
        if (index(i, string)) { r = 1; break }
    if (y == -1) return 0
    close(fileName)
    return r
}

function File_remove(fileName, force) {
    if (!fileName) { __error("File_remove: no fileName"); return }
    if (!system("rm"(force ? " -f" : "")" '"fileName"'")) return 1
}

function get_FileNameArray(file, name,  __,path) {
    path["0length"] = split(name, path, "/")
    file["0length"] = split(path[path["0length"]], file, ".")
    return file["0length"]
}

function get_FileName(pathName,    __,path) {
    path["0length"] = split(pathName, path, "/")
    if (path[path["0length"]] == "") List_remove(path, path["0length"])
    return path[path["0length"]]
}

function get_FileNameExt(pathName,    __,file,fileExt,path) {
    path["0length"] = split(pathName, path, "/")
    file["0length"] = split(path[path["0length"]], file, ".")
    while (file["0length"] && file[file["0length"]] == "") List_remove(file, file["0length"])
    return fileExt = file[file["0length"]]
}

function get_FileNameNoExt(pathName,    __,f,file,fileName,i,path) {
    path["0length"] = split(pathName, path, "/")
    file["0length"] = split(path[path["0length"]], file, ".")
    while (file["0length"] && file[file["0length"]] == "") List_remove(file, file["0length"])
    if (file["0length"]) List_remove(file, file["0length"])
    while (file["0length"] && file[file["0length"]] == "") List_remove(file, file["0length"])
    for (i = 1; i <= file["0length"]; ++i) fileName = String_concat(fileName, ".", file[i])
    return fileName
}

function get_DirectoryName(pathName,    __,dirName,i,path) {
    path["0length"] = split(pathName, path, "/")
    for (i = 1; i < path["0length"]; ++i)
        dirName = dirName path[i] "/"
    return dirName
}

function Path_join(pathName0, pathName1,    __,p,path0,path1,r) {
    path0["0length"] = split(pathName0, path0, "/")
    if (path0["0length"] && path0[path0["0length"]] == "") delete path0[path0["0length"]--]
    path1["0length"] = split(pathName1, path1, "/")
    for (p = 1; p <= path1["0length"]; ++p)
        path0[++path0["0length"]] = path1[p]
    for (p = 1; p <= path0["0length"]; ++p)
        if (path0[p + 1] == "..") { List_remove(path0, p + 1); List_remove(path0, p); p -= 2; continue }
    for (p = 1; p <= path0["0length"]; ++p)
        r = r path0[p] (p < path0["0length"] ? "/" : "")
    return r
}

function get_Date(time,    __,string) {
    if (!time) time = systime()
    string = strftime("%Y-%m-%d", time)
    return string
}

function get_DateTime(time,    __,string) {
    if (!time) time = systime()
    string = strftime("%Y-%m-%d.%H-%M-%S", time)
    return string
}

function get_Time() {
    return systime()
}

function Array_create(array,    __,type) {
    if ((type = typeof(array)) == "untyped") ;
    else if (type != "array") { __error("Array_create: array is typeof "type); return }
    if (!array["0length"]) delete array["0length"]
}

function List_create(array) {
    Array_create(array)
}

function Array_clear(array) {
    Array_create(array); delete array
}

function List_clear(array,    __,at,i) {
    Array_create(array)
    for (i = 1; i <= array["0length"]; ++i) delete array[i]
    delete array["0length"]
}

function List_length(array,   __,at) {
    if ((at = typeof(array)) != "array") { __error("List_length: array is typeof "at); return }
    return "0length" in array ? array["0length"] : 0
}

function List_first(array,    __,at) {
    if ((at = typeof(array)) != "array") { __error("List_first: array is typeof "at); return }
    if (!List_length(array)) return
    return array[1]
}

function List_last(array,    __,at,l) {
    if ((at = typeof(array)) != "array") { __error("List_last: array is typeof "at); return }
    if (!(l = List_length(array))) return
    return array[l]
}

function List_add(array, value,    __,at,l) {
    if ((at = typeof(array)) != "array") { __error("List_add: array is typeof "at); return }
    l = ++array["0length"]
    if (typeof(value) != "untyped") array[l] = value
    return l
}

function List_insert(array, i, value,    __,at,it,l,n) {
    if ((at = typeof(array)) != "array") { __error("List_insert: array is typeof "at); return }
    if ((it = typeof(i)) != "number") { __error("List_insert: i is typeof "it); return }
    l = ++array["0length"]
    for (n = l; n > i; --n) array[n] = array[n - 1]
    if (typeof(value) != "untyped") array[i] = value
}

function List_contains(array, item,    __,at,ir,n,r,type) {
    if ((at = typeof(array)) != "array") { __error("List_contains: array is typeof "at); return }
    if ((type = typeof(item)) == "array") { __error("List_contains: doesn't work with with arrays"); return }
    ir = (type == "regex")
    for (n = 1; n <= array["0length"]; ++n) {
        if (ir) { if (array[n] ~ item) { r = n; break } }
        else if (array[n] == item) { r = n; break }
    }
    return r
}

function List_copy(file, copy,    __,ct,ft,i) {
    if ((ft = typeof(file)) != "array") { __error("List_copy: file is typeof "ft); return }
    if ((ct = typeof(copy)) != "array") { __error("List_copy: copy is typeof "ct); return }
    for (i = 1; i <= file["0length"]; ++i)
        copy[++copy["0length"]] = file[i]
}

function Dictionary_copy(file, copy,    __,ct,cit,ft,fit,i) {
    if ((ft = typeof(file)) != "array") { __error("Dictionary_copy: file is typeof "ft); return }
    if ((ct = typeof(copy)) != "array") { __error("Dictionary_copy: copy is typeof "ct); return }
    for (i in file) {
        if (i ~ /^[0-9]/) continue
        if ((fit = typeof(file[i])) == "unassigned") copy[i]
        else if (fit == "array") {
            copy[i]["0length"]
            Dictionary_copy(file[i], copy[i])
        }
        else if (fit == "string" || fit == "number") {
            if ((cit = typeof(copy[i])) == "array") { __error("Dictionary_copy: Can't copy file["i"] "fit" to copy["i"] "cit); continue }
            copy[i] = file[i]
        }
        else __warning("Dictionary_copy: Unknown typeof item "fit)
    }
}

function Dictionary_count(array,    __,at,count,name) {
    if ((at = typeof(array)) == "untyped" || at == "unassigned") return
    if (at != "array") { __error("Dictionary_count: array is typeof "at); return }
    for (name in array)
        if (name !~ /^[0-9]/) ++count
    return count
}

function List_remove(array, i,    __,at,it,l,n) {
    if ((at = typeof(array)) != "array") { __error("List_remove: array is typeof "at); return }
    if ((it = typeof(i)) != "number") { __error("List_remove: i is typeof "it); return }
    l = array["0length"]
    for (n = i; n < l; ++n)
        array[n] = array[n + 1]
    delete array[l]
    --array["0length"]
}

function List_insertBefore(array, string0, string1,    __,l,n,n0,n1) {
    l = array["0length"]
    for (n = 1; n <= l; ++n) {
        if (array[n] == string0) { n0 = n }
        if (array[n] == string1) { n1 = n }
        if (n0 && n1) break
    }
    if (!n0) {
        List_insert(array, 1, string0)
        List_insert(array, 1, string1)
    }
    else if (!n1) {
        List_insert(array, n0, string1)
    }
    else if (n1 > n0) {
        List_remove(array, n1)
        List_insert(array, n0, string1)
    }
}

function List_insertAfter(array, string0, string1,    __,l,n,n0,n1) {
    l = array["0length"]
    for (n = 1; n <= l; ++n) {
        if (array[n] == string0) { n0 = n }
        if (array[n] == string1) { n1 = n }
        if (n0 && n1) break
    }
    if (!n0) {
        List_insert(array, l, string1)
        List_insert(array, l, string0)
    }
    else if (!n1) {
        List_insert(array, n0 + 1, string1)
    }
    else if (n1 < n0) {
        List_remove(array, n1)
        List_insert(array, n0 + 1, string1)
    }
}

function List_sort(source,    __,copy,i) {
    for (i = 1; i <= source["0length"]; ++i) copy[i] = source[i]
    asort(copy)
    for (i = 1; i <= source["0length"]; ++i) source[i] = copy[i]
}

function List_replaceString(output, input, fs, ofs) {
    return Index_pullArray(output, input, fs, ofs)
}

function String_replace(string, fs, ofs, rs, ors,   __,r) {
    r = Index_pull(string, fs, ofs, rs, ors); return r
}

function String_split(array, string, sepp) {
    return array["0length"] = split(string, array, sepp)
}

function String_join(array, ofs,    __,at,i,r) {
    if ((at = typeof(array)) != "array") { __error("String_join: array is typeof "at); return }
    if (typeof(ofs) == "untyped") ofs = OFS
    if (!array["0length"]) return ""
    for (i = 1; i <= array["0length"]; ++i)
        if (i == 1) r = array[1]
        else r = r ofs array[i]
    return r
}

function String_repeat(string, times,   __,p,q,r,st,tt) {
    if ((st = typeof(string)) != "string") { __error("String_repeat: string is typeof "st); return }
    if ((tt = typeof(times)) != "number") { __error("String_repeat: times is typeof "tt); return }
    for (p = 0; p < times; ++p) r = r string
    return r
}

function String_concat(string0, sepp, string1) {
    if (typeof(string1) == "untyped") { string1 = sepp; sepp = OFS }
    if (typeof(string0) == "untyped" || string0 == "") return string1
    if (typeof(string1) == "untyped" || string1 == "") return string0
    return string0 sepp string1
}

function String_startsWith(string0, string1,    __,l0,l1,m,st0,st1) {
    if ((st0 = typeof(string0)) != "string") { __error("String_startsWith: string0 is typeof "st0); return }
    if ((st1 = typeof(string1)) != "string") { __error("String_startsWith: string1 is typeof "st1); return }
    l0 = length(string0)
    l1 = length(string1)
    if (l1 > l0) return 0
    m = substr(string0, 1, l1)
    return m == string1
}

function String_endsWith(string0, string1,    __,l0,l1,m,st0,st1) {
    if ((st0 = typeof(string0)) != "string") { __error("String_endsWith: string0 is typeof "st0); return }
    if ((st1 = typeof(string1)) != "string") { __error("String_endsWith: string1 is typeof "st1); return }
    l0 = length(string0)
    l1 = length(string1)
    if (l1 > l0) return 0
    m = substr(string0, l0 - l1, l1)
    return m == string1
}

function String_trim(string, sepp,    __,i,st) {
    if ((st = typeof(string)) != "string") { __error("String_trim: string is typeof "st); return }
    if (typeof(sepp) == "untyped") sepp = @/[ \t]/
    Index_push(string, "", "")
    for (i = 1; i <= NF; ++i) {
        if ($i !~ sepp) break
        $i = ""
    }
    for (i = NF; i >= 1; --i) {
        if ($i !~ sepp) break
        $i = ""
    }
    return Index_pop()
}

function String_countChars(string, chars,    __,ct,i,l,n,st) {
    if ((st = typeof(string)) != "string") { __error("String_countChars: string is typeof "st); return }
    if ((ct = typeof(chars)) != "string") { __error("String_countChars: char is typeof "ct); return }
    l = length(chars)
    while (i = index(string, chars)) {
        string = substr(string, i + l)
        ++n
    }
    return n
}

function Char_codepoint(char,    __,c,ct,n) {
    if ((ct = typeof(char)) != "string") { __error("Char_codepoint: char is typeof "ct); return }
    if (typeof(ALLCHARS) == "untyped")
        for (n = 1; n <= 55295; ++n) {
            c = sprintf("%c", n)
            ALLCHARS = ALLCHARS c
        }
    return index(ALLCHARS, char)
}

function String_padLeft(string, size, sepp,    __,l,n,st,sizet) {
    if ((st = typeof(string)) != "string") { __error("String_padLeft: string is typeof "st); return }
    if ((sizet = typeof(size)) != "number") { __error("String_padLeft: size is typeof "sizet); return }
    if (typeof(sepp) == "untyped") sepp = " "
    l = length(string)
    if (l >= size) return string
    n = size - l
    return String_repeat(sepp, n) string
}

function String_padRight(string, size, sepp,    __,l,n,st,sizet) {
    if ((st = typeof(string)) != "string") { __error("String_padRight: string is typeof "st); return }
    if ((sizet = typeof(size)) != "number") { __error("String_padRight: size is typeof "sizet); return }
    if (typeof(sepp) == "untyped") sepp = " "
    l = length(string)
    if (l >= size) return string
    n = size - l
    return string String_repeat(sepp, n)
}

function __HEX(number,    __,nt,s) {
    if ((nt = typeof(number)) != "number") { __error("__HEX: number is typeof "nt); return }
    s = sprintf("%X", number)
    if (length(s) % 2 == 1) s = "0"s
    return s
}

function __hex(number,    __,nt,s) {
    if ((nt = typeof(number)) != "number") { __error("__hex: number is typeof "nt); return }
    s = sprintf("%x", number)
    if (length(s) % 2 == 1) s = "0"s
    return s
}

function __AND(n0,n1) { return and(n0,n1) }

function __OR(n0,n1) { return or(n0,n1) }

function __NOT(n0) { return compl(n0) }

function __XOR(n0,n1) { return xor(n0,n1) }

function Index_pushRange(from, to, fs, ofs, rs, ors,    __,i,m) {
    # save old Index
    i = ++Index["0length"]
    Index[i]["OUTPUTRECORDSEP"] = ORS
    Index[i]["RECORDSEP"] = RS
    Index[i]["OUTPUTFIELDSEP"] = OFS
    Index[i]["FIELDSEP"] = FS
    Index[i][0] = $0

    if (typeof(ors) != "untyped") ORS = ors
    if (typeof(rs) != "untyped") RS = rs
    if (typeof(ofs) != "untyped") OFS = ofs
    if (typeof(fs) != "untyped") FS = fs

    # new Index
    for (i = from; i <= to && i <= NF; ++i)
        m = String_concat(m, OFS, $i)
    $0 = m
    return Index_reset()
}

function Index_push(new, fs, ofs, rs, ors,    __,h,i,n,z) {
    # save old Index
    i = ++Index["0length"]
    Index[i]["OUTPUTRECORDSEP"] = ORS
    Index[i]["RECORDSEP"] = RS
    Index[i]["OUTPUTFIELDSEP"] = OFS
    Index[i]["FIELDSEP"] = FS
    Index[i][0] = Index_reset()

    if (typeof(ors) != "untyped") ORS = ors
    if (typeof(rs) != "untyped") RS = rs
    if (typeof(ofs) != "untyped") OFS = ofs
    if (typeof(fs) != "untyped") FS = fs

    # new Index
    if (typeof(new) == "untyped" || typeof(new) == "unassigned") $0 = ""
    else if (typeof(new) == "array") {
        Index_push("", fs, ofs, rs, ors)
        for (z = 1; z <= new["0length"]; ++z)
            if (z == 1) n = Index_reset(new[1])
            else n = n ORS (Index_reset(new[z]))
        Index_pop()
        $0 = n
    } else $0 = new
    return Index_reset()
}

function Index_pop(    null,i,r) { # Index
    if (typeof(null) != "untyped") __warning("run.awk: Use Index_pop() without arguments")

    r = Index_reset()

    if (!(i = Index["0length"])) __error("run.awk: More Index_pop() than Index_push()")
    else {
        ORS = Index[i]["OUTPUTRECORDSEP"]
        RS  = Index[i]["RECORDSEP"]
        OFS = Index[i]["OUTPUTFIELDSEP"]
        FS  = Index[i]["FIELDSEP"]
        $0  = Index[i][0]
        delete Index[i]
        --Index["0length"]
        Index_reset()
    }
    return r
}

function Index_pull(new, fs, ofs, rs, ors) {
    Index_push(new, fs, ofs, rs, ors)
    return Index_pop()
}

function Index_pullArray(output, input, fs, ofs,   __,it,ot,z) {
    if ((it = typeof(input)) != "array") { __error("Index_pullArray: input is typeof "it); return }
    if ((ot = typeof(output)) != "array") { __error("Index_pullArray: output is typeof "ot); return }
    Index_push("", fs, ofs)
    for (z = 1; z <= input["0length"]; ++z) output[++output["0length"]] = Index_reset(input[z])
    Index_pop()
}

function Index_insert(i, value, ifNot,    p, q, r) {
    if (typeof(value) == "untyped") { __error("value is untyped"); return }
    if (typeof(ifNot) == "untyped" || $i != ifNot) {
        ++NF
        for (q = NF; q > i; --q) {
            $q = $(q - 1)
        }
        $i = value
        r = 1
    }
    return Index_reset()
}

function Index_prepend(i, value, ifNot,    __,r) {
    if (typeof(ifNot) == "untyped" || (i == 1 || $(i - 1) != ifNot))
        r = Index_insert(i, value)
    return r
}

function Index_append(i, value, ifNot,    __,r) {
    if (typeof(ifNot) == "untyped" || (i < NF || $(i + 1) != ifNot))
        r = Index_insert(i + 1, value)
    return r
}

function Index_remove(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,    null,R) {
    if (typeof(null) != "untyped") {
        __warning("run.awk: WARNING: Don't use Index_remove() with more than 26 arguments")
        R = ""
    }
    if (typeof(a) == "number") { R = String_concat(R, OFS, $a); $a = "CLE\a\r" }
    if (typeof(b) == "number") { R = String_concat(R, OFS, $b); $b = "CLE\a\r" }
    if (typeof(c) == "number") { R = String_concat(R, OFS, $c); $c = "CLE\a\r" }
    if (typeof(d) == "number") { R = String_concat(R, OFS, $d); $d = "CLE\a\r" }
    if (typeof(e) == "number") { R = String_concat(R, OFS, $e); $e = "CLE\a\r" }
    if (typeof(f) == "number") { R = String_concat(R, OFS, $f); $f = "CLE\a\r" }
    if (typeof(g) == "number") { R = String_concat(R, OFS, $g); $g = "CLE\a\r" }
    if (typeof(h) == "number") { R = String_concat(R, OFS, $h); $h = "CLE\a\r" }
    if (typeof(i) == "number") { R = String_concat(R, OFS, $i); $i = "CLE\a\r" }
    if (typeof(j) == "number") { R = String_concat(R, OFS, $j); $j = "CLE\a\r" }
    if (typeof(k) == "number") { R = String_concat(R, OFS, $k); $k = "CLE\a\r" }
    if (typeof(l) == "number") { R = String_concat(R, OFS, $l); $l = "CLE\a\r" }
    if (typeof(m) == "number") { R = String_concat(R, OFS, $m); $m = "CLE\a\r" }
    if (typeof(n) == "number") { R = String_concat(R, OFS, $n); $n = "CLE\a\r" }
    if (typeof(o) == "number") { R = String_concat(R, OFS, $o); $o = "CLE\a\r" }
    if (typeof(p) == "number") { R = String_concat(R, OFS, $p); $p = "CLE\a\r" }
    if (typeof(q) == "number") { R = String_concat(R, OFS, $q); $q = "CLE\a\r" }
    if (typeof(r) == "number") { R = String_concat(R, OFS, $r); $r = "CLE\a\r" }
    if (typeof(s) == "number") { R = String_concat(R, OFS, $s); $s = "CLE\a\r" }
    if (typeof(t) == "number") { R = String_concat(R, OFS, $t); $t = "CLE\a\r" }
    if (typeof(u) == "number") { R = String_concat(R, OFS, $u); $u = "CLE\a\r" }
    if (typeof(v) == "number") { R = String_concat(R, OFS, $v); $v = "CLE\a\r" }
    if (typeof(w) == "number") { R = String_concat(R, OFS, $w); $w = "CLE\a\r" }
    if (typeof(x) == "number") { R = String_concat(R, OFS, $x); $x = "CLE\a\r" }
    if (typeof(y) == "number") { R = String_concat(R, OFS, $y); $y = "CLE\a\r" }
    if (typeof(z) == "number") { R = String_concat(R, OFS, $z); $z = "CLE\a\r" }
    Index_reset()
    return R
}

function Index_removeRange(from0, to0,    __,i,r) {
    if (typeof(to0) == "untyped") to0 = NF
    for (i = from0; i <= to0; ++i) { r = String_concat(r, OFS, $i); $i = "CLE\a\r" }
    Index_reset()
    return r
}

function Index_getRange(from0, to0,    __,i,r) {
    if (typeof(to0) == "untyped") to0 = NF
    for (i = from0; i <= to0; ++i) r = String_concat(r, OFS, $i)
    return r
}

#function Index_merge(i, len,    h, j, k, l) {
#    l = i + len
#    for (j = i; ++j <= l; ) {
#        $i = $i $j
#        $j = ""
#    }
#    return Index_reset()
#}

function Index_clear(    __,i,n) {
    for (i = 1; i <= NF; ++i) {
        if ($i == "CLE\a\r") { ++n; continue }
        $(i - n) = $i
    }
    NF -= n
}

function Index_reset(new) {
    if (typeof(new) != "untyped") $0 = new
    Index_clear()
    return $0 = $0
}

function File_read(file, fileName, rs, ors,    __,x,y,z) {
    if (typeof(fileName) == "untyped" || !fileName) { __error("File_read without fileName"); return }
    if (!file["name"]) file["name"] = fileName
    x = z = file["0length"]
    if (typeof(rs) == "untyped") rs = @/\r?\n/
    if (typeof(ors) == "untyped") ors = "\n"
    Index_push("", "", "", rs, ors)
    while (0 < y = ( getline < fileName ))
        file[z = ++file["0length"]] = $0
    Index_pop()
    if (fileName != "/dev/stdin") close(fileName)
    if (y == -1) { __error("File doesn't exist: "fileName); return }
    return z - x
}

function File_printTo(file, to, rs, ors, noLastORS,    __,z) {
    if (typeof(rs) == "untyped") rs = @/\r?\n/
    if (typeof(ors) == "untyped") ors = "\n"
    Index_push("", "", "", rs, ors)
    if (!file["0length"]) { if (noLastORS) printf "" > to; else print "" > to }
    else while (++z <= file["0length"]) {
        if (noLastORS && z == file["0length"]) { printf "%s", file[z] > to; break }
        print file[z] > to
    }
    fflush(to)
    Index_pop()
    if (to != "/dev/stdout" && to != "/dev/stderr") close(to)
}
function File_printFTo(file, to, format, rs, ors, noLastORS,    __,z) {
    if (typeof(rs) == "untyped") rs = @/\r?\n/
    if (typeof(ors) == "untyped") ors = "\n"
    Index_push("", "", "", rs, ors)
    if (!file["0length"]) printf "" > to
    else while (++z <= file["0length"]) {
        if (noLastORS && z == file["0length"]) { printf format, file[z] > to; break }
        printf format, file[z] > to
    }
    fflush(to)
    Index_pop()
}

function File_print(file, rs, ors, noLastORS) {
    File_printTo(file, "/dev/stdout", rs, ors, noLastORS)
}

function File_error(file, rs, ors, noLastORS) {
    if (typeof(ERRORS) == "untyped" || typeof(ERRORS) == "number") ++ERRORS
    else __warning("File_error: ERRORS should be number")
    File_printTo(file, "/dev/stderr", rs, ors, noLastORS)
}

function File_debug(file, rs, ors, noLastORS) {
    if ("DEBUG" in SYMTAB && SYMTAB["DEBUG"]) File_printTo(file, "/dev/stderr", rs, ors, noLastORS)
}

function File_readString(file, string, rs,    __,i,splits,x,z) {
    if (typeof(rs) == "untyped") rs = @/\r?\n/
    splits["0length"] = split(string, splits, rs)
    x = z = file["0length"]
    for (i = 1; i <= splits["0length"]; ++i) {
        z = ++file["0length"]
        file[z] = splits[i]
    }
    return z - x
}

function File_toString(file, ors,    __,r,z) {
    if (typeof(ors) == "untyped") ors = "\n"
    while (++z <= file["0length"]) r = String_concat(r, ors, file[z])
    return r
}

function File_clearLines(file, regex,    __,i) {
    for (i = 1; i <= file["0length"]; ++i)
        if (file[i] ~ regex) file[i] = ""
}

function __gawk(options, input, output, directory, variables) {
    return __command("gawk", options, input, output, directory, variables)
}

function __bash(options, input, output, directory, variables) {
    return __command("bash", options, input, output, directory, variables)
}

function __sudo(options, input, output, directory, variables) {
    return __command("sudo", options, input, output, directory, variables)
}

function sudo_isAdministrator() {
    return !__sudo("-n echo")
}

function __list(options, output, directory, variables) {
    __pipe("ls", "-1 "options, output, directory, variables)
}

function __listAll(options, output, directory, variables) {
    __pipe("la", "-1 "options, output, directory, variables)
}

function __find(options, output, directory, variables) {
    __pipe("find", "-name '"options"'", output, directory, variables)
}

function __command(command, options, input, output, directory, variables,    __,unseen) {
    if (typeof(input) == "untyped") {
        return system((!variables?"":variables" ")(!directory?"":"cd "directory" ; ")command" "options)
#        unseen["0length"]
#        return __pipe(command, options, unseen, directory, variables)
    }
    if (typeof(output) == "untyped" || typeof(output) == "string") {
        # input is output: use pipe out
        variables = directory
        directory = output
        return __pipe(command, options, input, directory, variables)
    }
    return __coprocess(command, options, input, output, directory, variables)
}

function __pipe(command, options, output, directory, variables,    __,a,cmd,r,y) {
    cmd = command
    if (options)
        cmd = cmd" "options
    if (typeof(variables) == "string" && variables)
        cmd = variables" "cmd
    if (typeof(directory) == "string" && directory)
        cmd = "cd \""directory"\" ; "cmd
    Index_push("", "", "", "\n", "\n")
    a = typeof(output) == "array"
    while (0 < y = ( cmd | getline ))
        if (a) output[++output["0length"]] = $0
    r = close(cmd)
    Index_pop()
    if (y == -1) { __error("Command doesn't exist: "command); return }
    return r
}

function __coprocess(command, options, input, output, directory, variables, rs, ors,    __,a,cmd,r,y,z) {
    cmd = command
    if (options)
        cmd = cmd" "options
    if (typeof(variables) == "string" && variables)
        cmd = variables" "cmd
    if (typeof(directory) == "string" && directory)
        cmd = "cd \""directory"\" ; "cmd
    if (typeof(rs) == "untyped") rs = @/\r?\n/
    if (typeof(ors) == "untyped") ors = "\n"
    Index_push("", "", "", rs, ors)
    if (typeof(input) == "array" && input["0length"])
        for (z = 1; z <= input["0length"]; ++z)
            print input[z] |& cmd
    else print "" |& cmd
    close(cmd, "to")
    a = typeof(output) == "array"
    while (0 < y = ( cmd |& getline ))
        if (a) output[++output["0length"]] = $0
    r = close(cmd)
    Index_pop()
    if (y == -1) { __error("Command doesn't exist: "command); return }
    return r
}

function System_sleep(seconds, minutes, hours,  __,s) {

    s = (hours * 3600) + (minutes * 60) + seconds
    if (!system("sleep " s "s")) return 1
}

function __URI(uri, address,    __,i,n,r) {
    delete uri
    if (i = index(address, ":")) {
        uri["schema"] = substr(address, 1, i - 1)
        address = substr(address, i + 1)
    }
    if (i = index(address, "//"))
        address = substr(address, i + 2)
    if (i = index(address, "/")) {
        uri["host"] = substr(address, 1, i - 1)
        address = substr(address, i)
    } else n = 1
    if (i = index(address, "#")) {
        uri["hash"] = substr(address, i + 1)
        address = substr(address, i - 1)
    }
    if (i = index(address, "?")) {
        uri["query"] = substr(address, i + 1)
        address = substr(address, i - 1)
    }
    if (n) uri["host"] = address
    else uri["path"] = address
    if (uri["host"] ~ /.\..+$/ || uri["path"]) {
        uri[0] = (!uri["schema"]?"//":uri["schema"]"://")uri["host"]uri["path"](uri["query"]?"?"uri["query"]:"")
        return 1
    }
}

function __HTTP(address, input, output, headers,   __,cmd,headerName,headerValue,i,r,status,uri,var,y,z) {
    uri["host"]
    if (!__URI(uri, address)) { __error("HTTP: no address: "address); return }
    if (!uri["host"]) { __error("HTTP: no host in address: "address); return }
    if (!input["0length"] || input[ input["0length"] ] != "") ++input["0length"]
    Index_push("", "", "", @/\r?\n/, "\r\n")
    cmd = "/inet/tcp/0/"uri["host"]"/80"
    for (z = 1; z <= input["0length"]; ++z)
        print input[z] |& cmd
    close(cmd, "to")
    z = 0; while (0 < y = ( cmd |& getline var )) { ++z
        if (!r) {
            if (z == 1) {
                if (substr(var, 1, 4) != "HTTP") __warning("HTTP: Host "uri["host"]": other "substr(var, 1, 4))
                if (substr(var, 6, 3) != "1.1") __warning("HTTP/1.1: Host "uri["host"]": other version: "substr(var, 6, 3))
                headers["Status"] = substr(var, 10)
                headers["Status-Code"] = status = 0 + headers["Status"]
                continue
            }
            if (i = index(var, ":")) {
                headerName = substr(var, 1, i - 1)
                headerValue = substr(var, i + 2)
                headers[headerName] = headerValue
                continue
            }
            r = 1 # unknown
            if (var == "") continue
        }
        if (r == 1) { RS="\n";ORS="\n" } else ++r
        output[++output["0length"]] = var
    }
    close(cmd); Index_pop()
    if (y == -1) { __error("Address doesn't exist: "address); return }
    return (status == 200)
}

function HTTP_GET(address, response, headers,   __,r,request,status,uri) {
    uri["host"]
    if (!__URI(uri, address)) { __error("HTTP: no address: "address); return }
    if (!uri["host"]) { __error("HTTP: no host in address: "address); return }
#__debug("HTTP GET "uri[0])

    request[ ++request["0length"] ] = "GET "uri[0]" HTTP/1.1"
    request[ ++request["0length"] ] = "Host: "uri["host"]
    request[ ++request["0length"] ] = "User-Agent: Mozilla/5.0 (gawk;"(CONTROLLER?" "CONTROLLER".awk":"")")"
    request[ ++request["0length"] ] = "Accept: text/html"
    #request[ ++request["0length"] ] = "Accept-Language: de,en"
    #request[ ++request["0length"] ] = "Accept-Encoding: *"
    request[ ++request["0length"] ] = "Connection: close"
    response["0length"]

    if (!(r = __HTTP(uri[0], request, response, headers))) {
        #status = headers["Status-Code"]
#__debug("HTTP GET Host: " uri["host"]" Status: "headers["Status"])
    }
    return r
}
