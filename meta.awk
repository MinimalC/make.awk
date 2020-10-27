#!/usr/bin/awk -f
# Gemeinfrei. Public Domain.
# 2020 Hans Riehm

#include "../make.awk/meta.awk"

BEGIN {
    PROCINFO["sorted_in"] = "@ind_num_asc"
    LC_ALL="C"
#   RS="\0"
}

# BEGINFILE { }

# ENDFILE { }

END {
    if (ERROR) exit 1
}

function __print(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z,   message, fileName) {
    message = a b c d e f g h i j k l m n o p q r s t u v w x y z
    # if ("OUTPUTFILENAME" in SYMTAB && SYMTAB["OUTPUTFILENAME"]) fileName = SYMTAB["OUTPUTFILENAME"] else
    fileName = "/dev/stdout"
    print message > fileName
}

function __warning(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z,   message) {
    message = a b c d e f g h i j k l m n o p q r s t u v w x y z
    print message > "/dev/stderr"
}

function __error(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z,   message) {
    message = a b c d e f g h i j k l m n o p q r s t u v w x y z
    ERROR = 1
    print message > "/dev/stderr"
}

function __debug(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z,   message) {
    if ("DEBUG" in SYMTAB && SYMTAB["DEBUG"]) {
        message = a b c d e f g h i j k l m n o p q r s t u v w x y z
        print message > "/dev/stderr"
    }
}


function ENVIRON_debug() {
    print "ENVIRON" >"/dev/stderr"
    Array_error(ENVIRON, 1)
}

function PROCINFO_debug() {
    print "PROCINFO" >"/dev/stderr"
    Array_error(PROCINFO, 1)
}

function ARGV_debug() {
    print "ARGV" >"/dev/stderr"
    Array_error(ARGV, 1)
}

function SYMTAB_debug() {
    print "SYMTAB" >"/dev/stderr"
    Array_error(SYMTAB, 1)
}

function FUNCTAB_debug() {
    print "FUNCTAB" >"/dev/stderr"
    Array_error(FUNCTAB, 1)
}


function File_exists(fileName,    h, i, j, r,x,y,z) {
    if (!fileName) { print "File_exists: fileName is null">"/dev/stderr"; return }
    if (!system("test -s '"fileName"'")) return 1
    #r = 0
    #if (-1 < y = (getline j < fileName)) r = 1
    #else return 0
    #close(fileName)
    return 0 #r
}

function Directory_exists(dirName) {
    if (!dirName) { print "Directory_exists: dirName is null">"/dev/stderr"; return }
    if (!system("test -d '"dirName"'")) return 1
}

function File_contains(fileName, string,    h, i, j, p, q, r,x,y,z) {
    if (!fileName) { print "File_contains: fileName is null">"/dev/stderr"; return }
    if (!string) { print "File_contains: string is null">"/dev/stderr"; return }
    #if (!system("grep -r '"string"' "fileName" >/dev/null")) return 1
    r = 0
    while (0 < y = (getline j < fileName))
        if (index(j, string)) { r = 1; break }
    if (y == -1) return 0
    close(fileName)
    return r
}

function get_FileName(pathName,    a,b,c,d,e,f,h, i, path, fileName) {
    path["length"] = split(pathName, path, "/")
    return fileName = path[path["length"]]
}

function get_FileNameExt(pathName,    a,b,c,d,e,f,file,h, i, path, fileExt) {
    path["length"] = split(pathName, path, "/")
    file["length"] = split(path[path["length"]], file, ".")
    return fileExt = file[file["length"]]
}

function get_DirectoryName(pathName,    h, i, path, dirName) {
    path["length"] = split(pathName, path, "/")
    for (i = 1; i < path["length"]; ++i)
        dirName = dirName path[i] "/"
    return dirName
}

function Path_join(pathName0, pathName1,    h, i, j, k, l, m, n, o, p, path0, path1, q, r, s) {
    path0["length"] = split(pathName0, path0, "/")
    if (path0[path0["length"]] == "") { delete path0[path0["length"]]; --path0["length"] }
    path1["length"] = split(pathName1, path1, "/")
    for (p = 1; p <= path1["length"]; ++p)
        path0[++path0["length"]] = path1[p]
    for (p = 1; p <= path0["length"]; ++p)
        if (path0[p + 1] == "..") { Array_remove(path0, p + 1); Array_remove(path0, p); p -= 2; continue }
    for (p = 1; p <= path0["length"]; ++p)
        r = r path0[p] (p < path0["length"] ? "/" : "")
    return r
}

function chartonum(char,    a, b, c, h, i, j, k, l, m, n) {
    if (typeof(ALLCHARS) == "untyped") {
        for (n = 1; n <= 32767; ++n) {
            c = sprintf("%c", n)
            ALLCHARS = ALLCHARS c
        }
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
    for (i in array) delete array[i]
}

function List_clear(array,    h, i) {
    if ("length" in array) {
        for (i = 1; i <= array["length"]; ++i) delete array[i]
        array["length"] = 0
    }
}

function Array_getLength(array) {
    if (typeof(array) == "untyped" || typeof(array) == "unassigned") return 0
    if (typeof(array) != "array") __error("Array_getLength: array is no Array")
    return "length" in array ? array["length"] : 0
}

function Array_first(array) {
    if (!Array_getLength(array)) return
    return array[1]
}

function Array_last(array,    h, i, j, k, l) {
    if (!(l = Array_getLength(array))) return
    return array[l]
}

function Array_add(array, value,    h, i, j, k, l) {
    l = ++array["length"]
    if (typeof(value) != "untyped") array[l] = value
    return l
}

function Array_insert(array, i, value,    h, j, k, l) {
    l = ++array["length"]
    # move all above including i
    for (h = l; h >= i; --h)
        array[h] = array[h - 1]
    if (typeof(value) != "untyped") array[i] = value
}

function Array_contains(array, item,    h, i, j, k, l, m, n, n0) {
    l = array["length"]
    n0 = 0
    for (n = 1; n <= l; ++n)
        if (array[n] == item) { n0 = n; break }
    return n0
}

function Array_copy(array0, array1,    h, i, j, k, l, m, n) {
    for (i in array0) array1[i] = array0[i]
}

function List_add(array, string) {
    if (!Array_contains(array, string)) Array_add(array, string)
}

function List_insertBefore(array, string0, string1,    h, i, j, k, l, m, n, n0, n1) {
    l = array["length"]
    for (n = 1; n <= l; ++n) {
        if (array[n] == string0) { n0 = n }
        if (array[n] == string1) { n1 = n }
        if (n0 && n1) break
    }
    if (!n0) {
        Array_insert(array, 1, string0)
        Array_insert(array, 1, string1)
    }
    else if (!n1) {
        Array_insert(array, n0, string1)
    }
    else if (n1 > n0) {
        Array_remove(array, n1)
        Array_insert(array, n0, string1)
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
        Array_insert(array, l, string1)
        Array_insert(array, l, string0)
    }
    else if (!n1) {
        Array_insert(array, n0 + 1, string1)
    }
    else if (n1 < n0) {
        Array_remove(array, n1)
        Array_insert(array, n0 + 1, string1)
    }
}

function Array_remove(array, i,    h, j, k, l, m, n) {
    if (typeof(i) == "untyped") { __error("i is untyped"); return }
    if (typeof(i) != "number") { delete array[i]; return }
    l = array["length"]
    for (n = i; n < l; ++n)
        array[n] = array[n + 1]
    delete array[l]
    --array["length"]
}

function Array_print(array, level,    h, i, prefix) {
    if (!level) level = 0
    if (!prefix) prefix = ""; for (i = 0; i < level; i++) prefix = prefix "\t"
    if (typeof(array) != "array") {
        print prefix "Array_print: array is typeof \""typeof(array)"\"">"/dev/stderr"
        return
    }
    for (i in array)
        if (typeof(array[i]) == "array") {
            print prefix i ": "
            Array_print(array[i], level + 1)
        } else
            print prefix i ": " array[i]
}

function Array_debug(array, level) { if ("DEBUG" in SYMTAB && SYMTAB["DEBUG"]) { Array_error(array, level) } }

function Array_error(array, level,    h, i, prefix) {
    if (!level) level = 0
    if (!prefix) prefix = ""; for (i = 0; i < level; i++) prefix = prefix "\t"
    if (typeof(array) != "array") {
        print prefix "Array_error: array is typeof \""typeof(array)"\"">"/dev/stderr"
        return
    }
    for (i in array)
        if (typeof(array[i]) == "array"){
            print prefix i ": " >"/dev/stderr"
            Array_error(array[i], level + 1)
        } else
            print prefix i ": " array[i] >"/dev/stderr"
}

function String_join(sepp, array,    h, i, r) {
    if (array["length"] == 0) return ""
    for (i = 1; i <= array["length"]; ++i) {
        if (i == 1) r = array[1]
        else r = r sepp array[i]
    }
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

function String_trim(string, sepp,    h, i, j) {
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

function Index_pushArray(newArray, newFS, newOFS, newRS, newORS,    h, i, j, k, l, m, n) {
    # save old Index
    i = Array_add(Index)
    Index[i]["OUTPUTRECORDSEP"] = ORS
    Index[i]["RECORDSEP"] = RS
    Index[i]["OUTPUTFIELDSEP"] = OFS
    Index[i]["FIELDSEP"] = FS
    Index[i][0] = $0

    if (typeof(newORS) != "untyped") ORS = newORS
    if (typeof(newRS) != "untyped") RS = newRS
    if (typeof(newOFS) != "untyped") OFS = newOFS
    if (typeof(newFS) != "untyped") FS = newFS

    # new Index
    if (typeof(newArray) != "untyped") {
        if (typeof(newArray) != "array") { error = "newArray isn't Array"; nextfile }

        for (n = 1; n <= newArray["length"]; ++n) {
            if (n == 1) m = newArray[1]
            else m = m ORS newArray[n]
        }
        $0 = m
    }
    return Index_reset()
}

function Index_pushRange(from, to, newFS, newOFS, newRS, newORS,    h, i, j, k, l, m, n) {
    # save old Index
    i = Array_add(Index)
    Index[i]["OUTPUTRECORDSEP"] = ORS
    Index[i]["RECORDSEP"] = RS
    Index[i]["OUTPUTFIELDSEP"] = OFS
    Index[i]["FIELDSEP"] = FS
    Index[i][0] = $0

    if (typeof(newORS) != "untyped") ORS = newORS
    if (typeof(newRS) != "untyped") RS = newRS
    if (typeof(newOFS) != "untyped") OFS = newOFS
    if (typeof(newFS) != "untyped") FS = newFS

    # new Index
    for (i = from; i <= to && i <= NF; ++i)
        m = String_concat(m, OFS, $i)
    $0 = m
    return Index_reset()
}


function Index_push(newIndex, newFS, newOFS, newRS, newORS,    h, i) {
    # save old Index
    i = Array_add(Index)
    Index[i]["OUTPUTRECORDSEP"] = ORS
    Index[i]["RECORDSEP"] = RS
    Index[i]["OUTPUTFIELDSEP"] = OFS
    Index[i]["FIELDSEP"] = FS
    Index[i][0] = $0

    if (typeof(newORS) != "untyped") ORS = newORS
    if (typeof(newRS) != "untyped") RS = newRS
    if (typeof(newOFS) != "untyped") OFS = newOFS
    if (typeof(newFS) != "untyped") FS = newFS

    # new Index
    if (typeof(newIndex) != "untyped") $0 = newIndex
    return Index_reset()
}

function Index_pop(fromFS, fromOFS, fromRS, fromORS,    h, i, p, q, r) {

    if (typeof(fromORS) != "untyped") ORS = fromORS
    if (typeof(fromRS) != "untyped")  RS  = fromRS
    if (typeof(fromOFS) != "untyped") OFS = fromOFS
    if (typeof(fromFS) != "untyped")  FS  = fromFS
    r = Index_reset()

    if (i = Array_getLength(Index)) {

        ORS = Index[i]["OUTPUTRECORDSEP"]
        RS  = Index[i]["RECORDSEP"]
        OFS = Index[i]["OUTPUTFIELDSEP"]
        FS  = Index[i]["FIELDSEP"]
        $0  = Index[i][0]

        Array_remove(Index, i)
    }
    Index_reset()
    return r
}

function Index_insert(i, value, ifNot,    p, q, r) {
    if (typeof(value) == "untyped") { error = "value is untyped"; nextfile }
    if (typeof(ifNot) == "untyped" || $i != ifNot) {
        ++NF
        for (q = NF; q > i; --q) {
            $q = $(q - 1)
        }
        $i = value
        r = 1
    }
    Index_reset()
    return r
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
    if (typeof(a) == "number") { removed = String_concat(removed, OFS, $a); $a = "" }
    if (typeof(b) == "number") { removed = String_concat(removed, OFS, $b); $b = "" }
    if (typeof(c) == "number") { removed = String_concat(removed, OFS, $c); $c = "" }
    if (typeof(d) == "number") { removed = String_concat(removed, OFS, $d); $d = "" }
    if (typeof(e) == "number") { removed = String_concat(removed, OFS, $e); $e = "" }
    if (typeof(f) == "number") { removed = String_concat(removed, OFS, $f); $f = "" }
    if (typeof(g) == "number") { removed = String_concat(removed, OFS, $g); $g = "" }
    if (typeof(h) == "number") { removed = String_concat(removed, OFS, $h); $h = "" }
    if (typeof(i) == "number") { removed = String_concat(removed, OFS, $i); $i = "" }
    if (typeof(j) == "number") { removed = String_concat(removed, OFS, $j); $j = "" }
    if (typeof(k) == "number") { removed = String_concat(removed, OFS, $k); $k = "" }
    if (typeof(l) == "number") { removed = String_concat(removed, OFS, $l); $l = "" }
    if (typeof(m) == "number") { removed = String_concat(removed, OFS, $m); $m = "" }
    if (typeof(n) == "number") { removed = String_concat(removed, OFS, $n); $n = "" }
    if (typeof(o) == "number") { removed = String_concat(removed, OFS, $o); $o = "" }
    if (typeof(p) == "number") { removed = String_concat(removed, OFS, $p); $p = "" }
    if (typeof(q) == "number") { removed = String_concat(removed, OFS, $q); $q = "" }
    if (typeof(r) == "number") { removed = String_concat(removed, OFS, $r); $r = "" }
    if (typeof(s) == "number") { removed = String_concat(removed, OFS, $s); $s = "" }
    if (typeof(t) == "number") { removed = String_concat(removed, OFS, $t); $t = "" }
    if (typeof(u) == "number") { removed = String_concat(removed, OFS, $u); $u = "" }
    if (typeof(v) == "number") { removed = String_concat(removed, OFS, $v); $v = "" }
    if (typeof(w) == "number") { removed = String_concat(removed, OFS, $w); $w = "" }
    if (typeof(x) == "number") { removed = String_concat(removed, OFS, $x); $x = "" }
    if (typeof(y) == "number") { removed = String_concat(removed, OFS, $y); $y = "" }
    if (typeof(z) == "number") { removed = String_concat(removed, OFS, $z); $z = "" }
    # Index_clearEmpty()
    Index_reset()
    return removed
}

function Index_removeRange(from0, to0,    h, i, removed) {
    if (typeof(to0) == "untyped") to0 = NF
    for (i = from0; i <= to0; ++i) { removed = String_concat(removed, OFS, $i); $i = "" }
    Index_reset()
    # Index_clearEmpty()
    return removed
}

#function Index_merge(i, len,    h, j, k, l) {
#    l = i + len
#    for (j = i; ++j <= l; ) {
#        $i = $i $j
#        $j = ""
#    }
#    return Index_reset()
#}

function Index_clearEmpty(    h, i, j, k, l, m, n) {
    for (i = 1; i <= NF; ++i) {
        if ($i == "") { ++n; continue }
        $(i - n) = $i
    }
    NF -= n
}
function Index_reset(newIndex,    h, i, j, k, l, m, n) {
    Index_clearEmpty()
    if (typeof(newIndex) != "untyped") $0 = newIndex
    return $0 = $0
}

function File_read(file, fileName, rs, ors,    w, x, y, z) {
    if (!file["name"]) file["name"] = fileName
    x = z = file["length"]
    if (typeof(rs) == "untyped") rs = @/\r?\n/
    if (typeof(ors) == "untyped") ors = "\n"
    Index_push("", "", "", rs, ors)
    while (0 < y = ( getline < fileName )) {
        z = ++file["length"]
        file[z] = $0
    }
    Index_pop()
    if (y == -1) {
        __error("File doesn't exist: "fileName)
        return
    }
    close(fileName)
    return z - x
}

function File_print(file, rs, ors,    x, y, z) {
    if (typeof(rs) == "untyped") rs = @/\r?\n/
    if (typeof(ors) == "untyped") ors = "\n"
    Index_push("", "", "", rs, ors)
    while (++z <= file["length"])
        print file[z]
    Index_pop()
}

function File_error(file, rs, ors,    x, y, z) {
    if (typeof(rs) == "untyped") rs = @/\r?\n/
    if (typeof(ors) == "untyped") ors = "\n"
    Index_push("", "", "", rs, ors)
    while (++z <= file["length"])
        __error(file[z])
    Index_pop()
}

function File_debug(file, rs, ors,    x, y, z) { if ("DEBUG" in SYMTAB && SYMTAB["DEBUG"]) File_error(file, rs, ors) }

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
    r = ""; while (++z <= file["length"]); r = String_concat(r, ors, file[z])
    return r
}

function File_clearLines(file, regex,    h, i) {
    for (i = 1; i <= file["length"]; ++i)
        if (file[i] ~ regex) file[i] = ""
}

function List_copy(file, copy,    h, i) {
    for (i = 1; i <= file["length"]; ++i)
        copy[i] = file[i]
    copy["length"] = file["length"]
}

function File_splitBy(file, sepp, before, after,    h, i, m,n,o,old,x,y,z) {
    List_copy(file, old)
    List_clear(file)
    Index_push("")
    Z = ++file["length"]
    for (z = 1; z <= old["length"]; ++z) {
        $0 = old[z]; Index_reset()

        for (i = 1; i <= NF; ++i) {
            if ($i ~ before) {
                if (i > 1) {
                    file[Z] = String_concat(file[Z], sepp, Index_removeRange(1, i - 1))
                    Z = ++file["length"]
                    i = 0; continue
                }
                continue
            }
            if ($i ~ after) {
                if (NF > 1 && i < NF) {
                    file[Z] = String_concat(file[Z], sepp, Index_removeRange(1, i))
                    Z = ++file["length"]
                    i = 0; continue
                }
                continue
            }
        }

        file[Z] = String_concat(file[Z], sepp, $0)
    }
    Index_pop()
}
