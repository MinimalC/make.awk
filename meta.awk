#!/usr/bin/awk -f
# Gemeinfrei. Public Domain.
# 2020 Hans Riehm

#include "../make.awk/meta.awk"

BEGIN { BEGIN_meta() }

function BEGIN_meta() {
    LC_ALL="C"
    PROCINFO["sorted_in"] = "@ind_num_asc"

    FS="";OFS="";RS="\0";ORS="\n"

    MAX_NUMBER = 2147483648

    if (PROCINFO["argv"][1] == "-f") if (get_FileNameNoExt(PROCINFO["argv"][2]) == "meta") __BEGIN()
}

END { END_meta() }

function END_meta() {
    # no if (ERRORS) exit 0; else exit 1
    if (Index["length"]) __error("meta.awk: More Index_push() than Index_pop()")
}

function meta_ARGC_ARGV() {

    ARGC_ARGV_debug()
}

function __printTo(to, a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z,   message) {
    message = "" a b c d e f g h i j k l m n o p q r s t u v w x y z
    print message > to
}

function __printFTo(to, format, a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z,   message) {
    message = "" a b c d e f g h i j k l m n o p q r s t u v w x y z
    printf format, message > to
}

function __print(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z,   message) {
    __printTo("/dev/stdout", a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z)
}

function __warning(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z,   message) {
    __printTo("/dev/stderr", a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z)
}

function __error(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z,   message) {
    if (typeof(ERRORS) == "untyped" || typeof(ERRORS) == "number") ++ERRORS
    else __warning("__error: ERRORS should be number")
    __printTo("/dev/stderr", a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z)
}

function __debug(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z,   message) {
    if ("DEBUG" in SYMTAB && SYMTAB["DEBUG"])
        __printTo("/dev/stderr", a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z)
}

function __debugF(to, format, a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z,   message) {
    if ("DEBUG" in SYMTAB && SYMTAB["DEBUG"])
        __printFTo("/dev/stderr", format, a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z)
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
    ENVIRON_debug()
    PROCINFO_debug()
    FUNCTAB_debug()
    SYMTAB_debug()
    ARGV_debug()
}

function File_exists(fileName,    h, i, j, r,x,y,z) {
    if (!fileName) { __error("File_exists: fileName is null"); return }
    if (!system("test -s '"fileName"'")) return 1
    #r = 0
    #if (-1 < y = (getline j < fileName)) r = 1
    #else return 0
    #close(fileName)
    return 0 #r
}

function Directory_exists(directory) {
    if (!directory) { __error("Directory_exists: directory is null"); return }
    if (!system("test -d '"directory"'")) return 1
}

function change_Directory(directory) {
    if (!directory) { __error("change_Directory: directory is null"); return }
    if (!system("cd '"directory"'")) return 1
}

function create_Directory(directory) {
    if (!directory) { __error("create_Directory: directory is null"); return }
    if (!system("mkdir -r '"directory"'")) return 1
}

function create_SymbolicLink(directory, target) {
    if (!directory) { __error("create_SymbolicLink: directory is null"); return }
    if (!target) { __error("create_SymbolicLink: target is null"); return }
    if (!system("ln -s '"directory"' '"target"'")) return 1
}

function SymbolicLink_exists(target) {
    if (!target) { __error("SymbolicLink_exists: target is null"); return }
    if (!system("test -L '"target"'")) return 1
}

function create_HardLink(file, target) {
    if (!file) { __error("create_HardLink: file is null"); return }
    if (!target) { __error("create_HardLink: target is null"); return }
    if (!system("ln -P '"file"' '"target"'")) return 1
}

function File_contains(fileName, string,    h, i, j, p, q, r,x,y,z) {
    if (!fileName) { __error("File_contains: fileName is null"); return }
    if (!string) { __error("File_contains: string is null"); return }
    #if (!system("grep -r '"string"' "fileName" >/dev/null")) return 1
    while (0 < y = (getline j < fileName))
        if (index(j, string)) { r = 1; break }
    if (y == -1) return 0
    close(fileName)
    return r
}

function File_remove(fileName, force) {
    if (!fileName) { __error("File_remove: fileName is null"); return }
    if (!system("rm"(force ? " -f" : "")" '"fileName"'")) return 1
    return 0
}

function get_FileName(pathName,    a,b,c,d,e,f,h, i, path, fileName) {
    path["length"] = split(pathName, path, "/")
    if (path[path["length"]] == "") List_remove(path, path["length"])
    return fileName = path[path["length"]]
}

function get_FileNameExt(pathName,    a,b,c,d,e,f,file,h, i, path, fileExt) {
    path["length"] = split(pathName, path, "/")
    file["length"] = split(path[path["length"]], file, ".")
    return fileExt = file[file["length"]]
}

function get_FileNameNoExt(pathName,    a,b,c,d,e,f,file,h, i, path, fileName) {
    path["length"] = split(pathName, path, "/")
    file["length"] = split(path[path["length"]], file, ".")
    if (file["length"]) List_remove(file, file["length"])
    for (i = 1; i <= file["length"]; ++i) fileName = String_concat(fileName, ".", file[i])
    return fileName
}

function get_DirectoryName(pathName,    h, i, path, dirName) {
    path["length"] = split(pathName, path, "/")
    for (i = 1; i < path["length"]; ++i)
        dirName = dirName path[i] "/"
    return dirName
}

function Path_join(pathName0, pathName1,    h, i, j, k, l, m, n, o, p, path0, path1, q, r, s) {
    path0["length"] = split(pathName0, path0, "/")
    if (path0["length"] && path0[path0["length"]] == "") delete path0[path0["length"]--]
    path1["length"] = split(pathName1, path1, "/")
    for (p = 1; p <= path1["length"]; ++p)
        path0[++path0["length"]] = path1[p]
    for (p = 1; p <= path0["length"]; ++p)
        if (path0[p + 1] == "..") { List_remove(path0, p + 1); List_remove(path0, p); p -= 2; continue }
    for (p = 1; p <= path0["length"]; ++p)
        r = r path0[p] (p < path0["length"] ? "/" : "")
    return r
}

function chartonum(char,    a, b, c, h, i, j, k, l, m, n) {
    if (typeof(ALLCHARS) == "untyped")
        for (n = 1; n <= 32767; ++n) {
            c = sprintf("%c", n)
            ALLCHARS = ALLCHARS c
        }
    return index(ALLCHARS, char)
}

function ARGV_contains(item,    s, t, u, v) {
    for (v = 1; v < ARGC; ++v)
        if (ARGV[v] == item) { u = v; break }
    return u
}

function ARGV_add(item,    p, q, r, s, t, u, v) {
    if (!(r = ARGV_contains(item))) ARGV[r = ARGC++] = item
    return r
}

function ARGV_remove(i) {
    ARGV[i] = ""
}
function ARGV_length() {
    return ARGC - 1
}

function Array_clear(array,    h, i, j, k, l) {
    if (typeof(array) == "untyped" || typeof(array) == "unassigned") return
    if (typeof(array) != "array") { __error("Array_clear: array is no Array"); return }
    for (i in array) delete array[i]
}

function List_clear(array,    h, i) {
    if (typeof(array) == "untyped" || typeof(array) == "unassigned") return
    if (typeof(array) != "array") { __error("List_clear: array is no Array"); return }
    for (i = 1; i <= array["length"]; ++i) delete array[i]
    array["length"] = 0
}

function cd_awk_coprocess(variables, directory, options, input, output,  a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) {
    __coprocess(variables" cd '"directory"' && awk", options, input, output)
}

function __BEGIN(controller, action, usage, # public CONTROLLER, ACTION, USAGE, ERRORS
    a,b,c,d,default,e,f,file,g,h,i,includeDir,includeName,j,k,l,m,make,n,o,options,origin,output,p,paramName,paramWert,q,r,s,t,u,v,w,workingDir,x,y,z)
{
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
        if (typeof(USAGE) != "untyped" && USAGE) usage = USAGE
        else usage = "Use awk -f meta.awk Project.awk command [Directory] [File.name]\n"\
                     "with Project.awk BEGIN { __BEGIN(\"action\") } and function Project_command(config) { }"
    }
    if (!controller) {
        if (typeof(CONTROLLER) != "untyped" && CONTROLLER) controller = CONTROLLER
        else if (PROCINFO["argv"][1] == "-f") controller = get_FileNameNoExt(PROCINFO["argv"][2])
        if (controller == "meta") {
            if (ARGV_length() == 0) { __error(usage); exit }
            if ("meta_"ARGV[1] in FUNCTAB) ;
            else if (!File_exists(ARGV[1])) { __error("meta.awk: File or Function "ARGV[1]" doesn't exist"); exit }
            else {
                file = ARGV[1]
                workingDir = ENVIRON["PWD"]
                for (o = 2; o <= ARGV_length(); ++o) options = options" "ARGV[o]
                output["length"]
                r = cd_awk_coprocess("", workingDir, "-f "file" "options, "", output)
                File_printTo(output, "/dev/stdout")
                exit r
            }
        }
        if (!controller) { __error(usage); exit }
    }
    if (action) { default = action; action = "" }

    for (i = 1; i <= ARGV_length(); ++i) {
        if (ARGV[i] ~ /^\s*$/) continue
        if (controller"_"ARGV[i] in FUNCTAB) {
            if (i > 1 && action) {
                if (!((make = controller"_"action) in FUNCTAB)) { __error(controller".awk: Unknown method "make); exit }
                @make(origin); if ("next" in origin) delete origin["next"]; else Array_clear(origin)
            }
            action = ARGV[i]
            ARGV[i] = ""; continue
        }
        paramName = ""
        if (ARGV[i] ~ /^.*=/) {
            paramWert = index(ARGV[i], "=")
            paramName = substr(ARGV[i], 1, paramWert - 1)
            paramWert = substr(ARGV[i], paramWert + 1)
        } else
        if (ARGV[i] ~ /^\+/) {
            paramName = substr(ARGV[i], 2)
            paramWert = 1
        } else
        if (ARGV[i] ~ /^-/) {
            paramName = substr(ARGV[i], 2)
            paramWert = 0
        }
        if (paramName) {
          # if (paramName == "debug") DEBUG = paramWert; else
            if (paramName in SYMTAB) SYMTAB[paramName] = paramWert
            else if ((make = "set_"controller"_"paramName) in FUNCTAB) @make(paramWert)
            else origin["parameters"][paramName] = paramWert
            ARGV[i] = ""; continue
        }
        if (Directory_exists(ARGV[i])) {
            origin["directories"][++origin["directories"]["length"]] = ARGV[i]
            ARGV[i] = ""; continue
        }
        if (File_exists(ARGV[i])) {
            origin["files"][++origin["files"]["length"]] = ARGV[i]
            ARGV[i] = ""; continue
        }
        __warning(controller".awk: Unknown File, command or parameter not found: "ARGV[i])
        ARGV[i] = ""
    }
    if (!action) {
        if (typeof(ACTION) != "untyped" && ACTION) action = ACTION
        else if (default) action = default
        else action = "BEGIN"
    }
    if (!((make = controller"_"action) in FUNCTAB)) __error(controller".awk: Unknown method "make)
    else @make(origin)

    if (typeof(ERRORS) == "number" && ERRORS) exit
    exit 1
}

function List_length(array,   s,t) {
    t = typeof(array)
    if (t == "untyped" || t == "unassigned") return
    if (t != "array") __error("List_length: array isn't Array but '"t"'")
    return "length" in array ? array["length"] : 0
}

function List_first(array) {
    if (!List_length(array)) return
    return array[1]
}

function List_last(array,    h, i, k, l) {
    if (!(l = List_length(array))) return
    return array[l]
}

function List_add(array, value,    h, i, k, l) {
    l = ++array["length"]
    if (typeof(value) != "untyped") array[l] = value
    return l
}

function List_insert(array, i, value,    h, k, l) {
    l = ++array["length"]
    # move all above including i
    for (h = l; h >= i; --h)
        array[h] = array[h - 1]
    if (typeof(value) != "untyped") array[i] = value
}

function List_contains(array, item,    m,n,r) {
    if (typeof(array) == "untyped" || typeof(array) == "unassigned") return
    if (typeof(array) != "array") { __error("List_contains: no array but "typeof(array)); return }
    for (n = 1; n <= array["length"]; ++n) {
        if (typeof(item) == "regex") { if (array[n] ~ item) { r = n; break } }
        else { if (array[n] == item) { r = n; break } }
    }
    return r
}

function List_copy(file, copy,    h, i, j, k, l, m, n) {
    if (typeof(file) != "array") { __error("List_copy: file is not array, but "typeof(file)); return }
    if (typeof(copy) != "array") { __error("List_copy: copy is not array, but "typeof(copy)); return }
    for (i = 1; i <= file["length"]; ++i)
        copy[++copy["length"]] = file[i]
}

function Dictionary_copy(file, copy,    h, i, j, k, l, m, n) {
    if (typeof(file) != "array") { __error("Dictionary_copy: file is not array, but "typeof(file)); return }
    if (typeof(copy) != "array") { __error("Dictionary_copy: copy is not array, but "typeof(copy)); return }
    for (i in file) {
        if (i == "length" || i ~ /^[1-9][0-9]*$/) continue
        if (typeof(file[i]) == "unassigned") {
            copy[i]
            continue
        }
        if (typeof(file[i]) == "array") {
            Dictionary_copy(file[i], copy[i])
            continue
        }
        copy[i] = file[i]
    }
}

function List_remove(array, i,    h, j, k, l, m, n) {
    if (typeof(i) == "untyped") { __error("i is untyped"); return }
    if (typeof(i) != "number") { delete array[i]; return }
    l = array["length"]
    for (n = i; n < l; ++n)
        array[n] = array[n + 1]
    delete array[l]
    --array["length"]
}

function Array_printTo(array, to, level,    h,i,t) {
    if (typeof(array) == "untyped" || typeof(array) == "unassigned") return
    t = String_repeat("\t", level)
    if (typeof(array) != "array") { __error(t"Array_print: array is typeof \""typeof(array)"\""); return }
    if (typeof(level) == "untyped") ++level
    if (typeof(to) == "untyped") to = "/dev/stdout"
    for (i in array)
        if (typeof(array[i]) == "array") {
            print t i ": " > to
            Array_printTo(array[i], to, level + 1)
        } else
            print t i ": " array[i] > to
}

function Array_print(array) {
    Array_printTo(array, "/dev/stdout")
}

function Array_error(array) {
    if (typeof(ERRORS) == "untyped" || typeof(ERRORS) == "number") ++ERRORS
    else __warning("Array_error: ERRORS should be number")
    Array_printTo(array, "/dev/stderr")
}

function Array_debug(array, level) {
    if ("DEBUG" in SYMTAB && SYMTAB["DEBUG"]) Array_printTo(array, "/dev/stderr")
}

function List_insertBefore(array, string0, string1,    h, i, j, k, l, m, n, n0, n1) {
    l = array["length"]
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

function List_insertAfter(array, string0, string1,    h, i, j, k, l, m, n, n0, n1) {
    l = array["length"]
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

function List_sort(source,    a,b,c,copy,h,i) {
    for (i = 1; i <= source["length"]; ++i) copy[i] = source[i]
    asort(copy)
    for (i = 1; i <= source["length"]; ++i) source[i] = copy[i]
}

function String_split(array, string, sepp) {
    array["length"] = split(string, array, sepp)
}

function String_join(array, ofs,    h,i,r) {
    if (typeof(ofs) == "untyped") ofs = OFS
    if (typeof(array) != "array") { __error("array is no Array"); return }
    if (!array["length"]) return ""
    for (i = 1; i <= array["length"]; ++i)
        if (i == 1) r = array[1]
        else r = r ofs array[i]
    return r
}

function String_repeat(string, times,   o,p,q,r) {
    for (p = 0; p < times; ++p) r = r string
    return r
}

function String_concat(string0, sepp, string1) {
    if (typeof(string1) == "untyped") { string1 = sepp; sepp = OFS }
    if (typeof(string0) == "untyped" || string0 == "") return string1
    if (typeof(string1) == "untyped" || string1 == "") return string0
    return string0 sepp string1
}

function String_startsWith(string0, string1,    h, i, j, k, l0, l1, m) {
    l0 = length(string0)
    l1 = length(string1)
    if (l1 > l0) return 0
    m = substr(string0, 1, l1)
    return m == string1
}

function String_endsWith(string0, string1,    h, i, j, k, l0, l1, m) {
    l0 = length(string0)
    l1 = length(string1)
    if (l1 > l0) return 0
    m = substr(string0, l0 - l1, l1)
    return m == string1
}

function String_trim(string, sepp,    h, i) {
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

function String_countChars(string, chars,    h,i,l,n) {
    l = length(chars)
    while (i = index(string, chars)) {
        string = substr(string, i + l)
        ++n
    }
    return n
}

function Index_pushRange(from, to, fs, ofs, rs, ors,    h, i, m) {
    # save old Index
    i = ++Index["length"]
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

function Index_push(new, fs, ofs, rs, ors,    h,i,n,z) {
    # save old Index
    i = ++Index["length"]
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
    if (typeof(new) == "untyped" || typeof(new) == "unassigned")
        $0 = ""
    else if (typeof(new) == "array") {
        for (z = 1; z <= new["length"]; ++z)
            if (z == 1) n = Index_reset(new[1])
            else n = n ORS (Index_reset(new[z]))
        $0 = n
    }
    else $0 = new
    return Index_reset()
}

function Index_pop(    a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r) {

    r = Index_reset()

    if (!(i = Index["length"])) __error("meta.awk: More Index_pop() than Index_push()")
    else {
        ORS = Index[i]["OUTPUTRECORDSEP"]
        RS  = Index[i]["RECORDSEP"]
        OFS = Index[i]["OUTPUTFIELDSEP"]
        FS  = Index[i]["FIELDSEP"]
        $0  = Index[i][0]
        delete Index[i]
        --Index["length"]
        Index_reset()
    }
    return r
}

function Index_pull(new, fs, ofs, rs, ors) {
    Index_push(new, fs, ofs, rs, ors)
    return Index_pop()
}

function Index_pullArray(output, input, fs, ofs, rs, ors,   x,y,z) {
    Index_push("", fs, ofs, rs, ors)
    for (z = 1; z <= input["length"]; ++z) output[++output["length"]] = Index_reset(input[z])
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

function Index_prepend(i, value, ifNot,    p, q, r) {
    if (typeof(ifNot) == "untyped" || (i == 1 || $(i - 1) != ifNot))
        r = Index_insert(i, value)
    return r
}

function Index_append(i, value, ifNot,    p,q,r) {
    if (typeof(ifNot) == "untyped" || (i < NF || $(i + 1) != ifNot))
        r = Index_insert(i + 1, value)
    return r
}

function Index_remove(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z,    removed) {
    if (typeof(a) == "number") { removed = String_concat(removed, OFS, $a); $a = "CLE\a\r" }
    if (typeof(b) == "number") { removed = String_concat(removed, OFS, $b); $b = "CLE\a\r" }
    if (typeof(c) == "number") { removed = String_concat(removed, OFS, $c); $c = "CLE\a\r" }
    if (typeof(d) == "number") { removed = String_concat(removed, OFS, $d); $d = "CLE\a\r" }
    if (typeof(e) == "number") { removed = String_concat(removed, OFS, $e); $e = "CLE\a\r" }
    if (typeof(f) == "number") { removed = String_concat(removed, OFS, $f); $f = "CLE\a\r" }
    if (typeof(g) == "number") { removed = String_concat(removed, OFS, $g); $g = "CLE\a\r" }
    if (typeof(h) == "number") { removed = String_concat(removed, OFS, $h); $h = "CLE\a\r" }
    if (typeof(i) == "number") { removed = String_concat(removed, OFS, $i); $i = "CLE\a\r" }
    if (typeof(j) == "number") { removed = String_concat(removed, OFS, $j); $j = "CLE\a\r" }
    if (typeof(k) == "number") { removed = String_concat(removed, OFS, $k); $k = "CLE\a\r" }
    if (typeof(l) == "number") { removed = String_concat(removed, OFS, $l); $l = "CLE\a\r" }
    if (typeof(m) == "number") { removed = String_concat(removed, OFS, $m); $m = "CLE\a\r" }
    if (typeof(n) == "number") { removed = String_concat(removed, OFS, $n); $n = "CLE\a\r" }
    if (typeof(o) == "number") { removed = String_concat(removed, OFS, $o); $o = "CLE\a\r" }
    if (typeof(p) == "number") { removed = String_concat(removed, OFS, $p); $p = "CLE\a\r" }
    if (typeof(q) == "number") { removed = String_concat(removed, OFS, $q); $q = "CLE\a\r" }
    if (typeof(r) == "number") { removed = String_concat(removed, OFS, $r); $r = "CLE\a\r" }
    if (typeof(s) == "number") { removed = String_concat(removed, OFS, $s); $s = "CLE\a\r" }
    if (typeof(t) == "number") { removed = String_concat(removed, OFS, $t); $t = "CLE\a\r" }
    if (typeof(u) == "number") { removed = String_concat(removed, OFS, $u); $u = "CLE\a\r" }
    if (typeof(v) == "number") { removed = String_concat(removed, OFS, $v); $v = "CLE\a\r" }
    if (typeof(w) == "number") { removed = String_concat(removed, OFS, $w); $w = "CLE\a\r" }
    if (typeof(x) == "number") { removed = String_concat(removed, OFS, $x); $x = "CLE\a\r" }
    if (typeof(y) == "number") { removed = String_concat(removed, OFS, $y); $y = "CLE\a\r" }
    if (typeof(z) == "number") { removed = String_concat(removed, OFS, $z); $z = "CLE\a\r" }
    Index_reset()
    return removed
}

function Index_removeRange(from0, to0,    h, i, removed) {
    if (typeof(to0) == "untyped") to0 = NF
    for (i = from0; i <= to0; ++i) { removed = String_concat(removed, OFS, $i); $i = "CLE\a\r" }
    Index_reset()
    return removed
}

function Index_getRange(from0, to0,    h, i, text) {
    if (typeof(to0) == "untyped") to0 = NF
    for (i = from0; i <= to0; ++i) text = String_concat(text, OFS, $i)
    return text
}

#function Index_merge(i, len,    h, j, k, l) {
#    l = i + len
#    for (j = i; ++j <= l; ) {
#        $i = $i $j
#        $j = ""
#    }
#    return Index_reset()
#}

function Index_clear(    h, i, j, k, l, m, n) {
    for (i = 1; i <= NF; ++i) {
        if ($i == "CLE\a\r") { ++n; continue }
        $(i - n) = $i
    }
    NF -= n
}

function Index_reset(new,    h, i, j, k, l, m, n) {
    if (typeof(new) != "untyped") $0 = new
    Index_clear()
    return $0 = $0
}

function File_read(file, fileName, rs, ors,    w, x, y, z) {
    if (typeof(fileName) == "untyped" || !fileName) { __error("File_read without fileName"); return }
    if (!file["name"]) file["name"] = fileName
    x = z = file["length"]
    if (typeof(rs) == "untyped") rs = @/\r?\n/
    if (typeof(ors) == "untyped") ors = "\n"
    Index_push("", "", "", rs, ors)
    while (0 < y = ( getline < fileName ))
        file[z = ++file["length"]] = $0
    Index_pop()
    if (fileName != "/dev/stdin") close(fileName)
    if (y == -1) { __error("File doesn't exist: "fileName); return }
    return z - x
}

function File_printTo(file, to, rs, ors, noLastORS,    x, y, z) {
    if (typeof(rs) == "untyped") rs = @/\r?\n/
    if (typeof(ors) == "untyped") ors = "\n"
    Index_push("", "", "", rs, ors)
    while (++z <= file["length"]) {
        if (noLastORS && z == file["length"]) { printf "%s", file[z] > to; break }
        print file[z] > to
    }
    Index_pop()
    if (to != "/dev/stdout" && to != "/dev/stderr") close(to)
}
function File_printFTo(file, to, format, rs, ors, noLastORS,    x, y, z) {
    if (typeof(rs) == "untyped") rs = @/\r?\n/
    if (typeof(ors) == "untyped") ors = "\n"
    Index_push("", "", "", rs, ors)
    while (++z <= file["length"]) {
        if (noLastORS && z == file["length"]) { printf format, file[z] > to; break }
        printf format, file[z] > to
    }
    Index_pop()
}

function File_print(file, rs, ors, noLastORS,    x, y, z) {
    File_printTo(file, "/dev/stdout", rs, ors, noLastORS)
}

function File_error(file, rs, ors, noLastORS,    x, y, z) {
    if (typeof(ERRORS) == "untyped" || typeof(ERRORS) == "number") ++ERRORS
    else __warning("File_error: ERRORS should be number")
    File_printTo(file, "/dev/stderr", rs, ors, noLastORS)
}

function File_debug(file, rs, ors, noLastORS,    x, y, z) {
    if ("DEBUG" in SYMTAB && SYMTAB["DEBUG"]) File_printTo(file, "/dev/stderr", rs, ors, noLastORS)
}

function String_read(file, string, rs,    h,i,s,splits,x,z) {
    if (typeof(rs) == "untyped") rs = @/\r?\n/
    splits["length"] = split(string, splits, rs)
    x = z = file["length"]
    for (i = 1; i <= splits["length"]; ++i) {
        z = ++file["length"]
        file[z] = splits[i]
    }
    return z - x
}

function File_toString(file, ors,    o,r,s,x,y,z) {
    if (typeof(ors) == "untyped") ors = "\n"
    while (++z <= file["length"]) r = String_concat(r, ors, file[z])
    return r
}

function File_clearLines(file, regex,    h, i) {
    for (i = 1; i <= file["length"]; ++i)
        if (file[i] ~ regex) file[i] = ""
}

function __pipe(command, options, output,    a,b,c,cmd,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) {
    cmd = command" "options
    Index_push("", "", "", "\n", "\n")
    o = typeof(output) == "array"
    while (0 < y = ( cmd | getline ))
        if (o) output[++output["length"]] = $0
    Index_pop()
    if (y == -1) { __error("Command doesn't exist: "command); return }
    return close(cmd)
}

function __coprocess(command, options, input, output,    a,b,c,cmd,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) {
    cmd = command" "options
    if (typeof(input) == "array")
        for (i = 1; i <= input["length"]; ++i)
            print input[i] |& cmd
    else print "" |& cmd
    close(cmd, "to")
    Index_push("", "", "", "\n", "\n")
    o = typeof(output) == "array"
    while (0 < y = ( cmd |& getline ))
        if (o) output[++output["length"]] = $0
    Index_pop()
    if (y == -1) { __error("Command doesn't exist: "command); return }
    return close(cmd)
}
