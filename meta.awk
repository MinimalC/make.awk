#!/usr/bin/awk -f
# Gemeinfrei. Public Domain.
# 2020 Hans Riehm

@include "../make.awk/meta.Expression_evaluate.awk"

BEGIN {
    PROCINFO["sorted_in"] = "@ind_num_asc"
    LC_ALL="C"
#   RS="\0"
}

BEGINFILE {
    if ("error" in SYMTAB && error) error = ""
    if ("warning" in SYMTAB && warning) warning = ""
}

ENDFILE {
    if ("error" in SYMTAB && error)
        print "ERROR! "error > "/dev/stderr"
    if ("warning" in SYMTAB && warning)
        print "WARNING: "warning > "/dev/stderr"
}

END {
    if ("error" in SYMTAB && error) exit 1
}


function File_exists(fileName,    h, i, j, r) {
    if (!fileName) { print "File_exists: fileName is null">"/dev/stderr"; return }
    #if (!system("test -s "fileName)) return 1
    if (!((getline j < fileName) < 0)) r = 1
    close(fileName)
    return r
}

function Directory_exists(dirName) {
    if (!dirName) { print "Directory_exists: dirName is null">"/dev/stderr"; return }
    if (!system("test -d "dirName)) return 1
}

function File_contains(fileName, string,    h, i, j, p, q, r) {
    if (!fileName) { print "File_contains: fileName is null">"/dev/stderr"; return }
    if (!string) { print "File_contains: string is null">"/dev/stderr"; return }
    #if (!system("grep -r '"string"' "fileName" >/dev/null")) return 1
    while ((getline j < fileName) < 0)
        if (index($0, string) > 0) { r = 1; break }
    close(fileName)
    return r
}


function __warning(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z,   message) {
    message = a b c d e f g h i j k l m n o p q r s t u v w x y z
#    warning = String_concat(warning, "\n", message)
    print message >"/dev/stderr"
}
function __error(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z,   message) {
    message = a b c d e f g h i j k l m n o p q r s t u v w x y z
#    error = String_concat(error, "\n", message)
    print message >"/dev/stderr"
    # nextfile
}

function __debug(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z,   message) {
    if ("DEBUG" in SYMTAB && DEBUG) {
        message = a b c d e f g h i j k l m n o p q r s t u v w x y z
        print message >"/dev/stderr"
    }
}
function __debug2(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z,   message) {
    if ("DEBUG" in SYMTAB && DEBUG == 2) {
        message = a b c d e f g h i j k l m n o p q r s t u v w x y z
        print message >"/dev/stderr"
    }
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


function Array_create(array) {
    # if (typeof(array) == "array") { error = "this is already Array"; nextfile }
    Array_clear(array)
}

function Array_length(array) {
    if (typeof(array) == "untyped") return 0
    if (typeof(array) != "array") { error = "this is no Array"; nextfile }
    # if (typeof(array["length"]) == "untyped") array["length"] = 0
    return array["length"]
}

function Array_first(array) {
    if (!Array_length(array)) return
    return array[1]
}

function Array_last(array,    h, i, j, k, l) {
    if (!(l = Array_length(array))) return
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

function Array_clear(array,    h, i) {
    for (i = 1; i <= array["length"]; ++i) delete array[i]
    array["length"] = 0
}

function Array_print(array, level,    h, i, prefix) {
    if (!level) level = 0
    if (!prefix) prefix = ""; for (i = 0; i < level; i++) prefix = prefix "\t"
    if (typeof(array) != "array") {
        print prefix "Array_print: array is typeof \""typeof(array)"\"">"/dev/stderr"
        return
    }
    for (i in array)
        if (typeof(array[i]) == "array")
            Array_print(array[i], level + 1)
        else
            print prefix i ": " array[i]
}

function Array_debug(array, level) { if ("DEBUG" in SYMTAB && DEBUG) { Array_error(array, level) } }

function Array_error(array, level,    h, i, prefix) {
    if (!level) level = 0
    if (!prefix) prefix = ""; for (i = 0; i < level; i++) prefix = prefix "\t"
    if (typeof(array) != "array") {
        print prefix "Array_error: array is typeof \""typeof(array)"\"">"/dev/stderr"
        return
    }
    for (i in array)
        if (typeof(array[i]) == "array")
            Array_error(array[i], level + 1)
        else
            print prefix i ": " array[i] >"/dev/stderr"
}

function ENVIRON_debug() {
    print "ENVIRON" >"/dev/stderr"
    Array_error(ENVIRON, 1)
}

function PROCINFO_debug() {
    print "PROCINFO" >"/dev/stderr"
    Array_error(PROCINFO, 1)
    #print "SYMTAB" >"/dev/stderr"
    #Array_error(SYMTAB, 1)
    #print "FUNCTAB" >"/dev/stderr"
    #Array_error(FUNCTAB, 1)
}

function ARGV_debug() {
    print "ARGV" >"/dev/stderr"
    Array_error(ARGV, 1)
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
    if (string0 == "") return string1
    if (string1 == "") return string0
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
            else m = m OFS newArray[n]
        }
        return $0 = m
    }
    return Index_reset()
}

function Index_pushRange(offset0, length0, newFS, newOFS, newRS, newORS,    h, i, j) {
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
    for (j = 1; j <= NF; ++j) {
        if (j < offset0) $j = ""
        if (typeof(length0) != "number" || j > offset0 + length0) $j = ""
    }
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
    if (typeof(newIndex) != "untyped") {
        return $0 = newIndex
    }
    return Index_reset()
}

function Index_pop(fromFS, fromOFS,    h, i, p, q, r) {

    if (typeof(fromOFS) != "untyped") OFS = fromOFS
    if (typeof(fromFS) != "untyped")  FS  = fromFS
    r = Index_reset()

    if (i = Array_length(Index)) {

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

function Index_append(i, value, ifNot) {
    if (typeof(ifNot) == "untyped" || (i < NF || $(i + 1) != ifNot))
        r = Index_insert(i + 1, value)
    return r
}

function Index_remove(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z) {
    if (typeof(a) != "untyped") $a = ""
    if (typeof(b) != "untyped") $b = ""
    if (typeof(c) != "untyped") $c = ""
    if (typeof(d) != "untyped") $d = ""
    if (typeof(e) != "untyped") $e = ""
    if (typeof(f) != "untyped") $f = ""
    if (typeof(g) != "untyped") $g = ""
    if (typeof(h) != "untyped") $h = ""
    if (typeof(i) != "untyped") $i = ""
    if (typeof(j) != "untyped") $j = ""
    if (typeof(k) != "untyped") $k = ""
    if (typeof(l) != "untyped") $l = ""
    if (typeof(m) != "untyped") $m = ""
    if (typeof(n) != "untyped") $n = ""
    if (typeof(o) != "untyped") $o = ""
    if (typeof(p) != "untyped") $p = ""
    if (typeof(q) != "untyped") $q = ""
    if (typeof(r) != "untyped") $r = ""
    if (typeof(s) != "untyped") $s = ""
    if (typeof(t) != "untyped") $t = ""
    if (typeof(u) != "untyped") $u = ""
    if (typeof(v) != "untyped") $v = ""
    if (typeof(w) != "untyped") $w = ""
    if (typeof(x) != "untyped") $x = ""
    if (typeof(y) != "untyped") $y = ""
    if (typeof(z) != "untyped") $z = ""
    return Index_reset()
}

function Index_removeRange(from0, to0,    h, i) {
    if (typeof(to0) == "untyped") to0 = NF
    for (i = from0; i <= to0; ++i) $i = ""
    return Index_reset()
}

#function Index_merge(i, len,    h, j, k, l) {
#    l = i + len
#    for (j = i; ++j <= l; ) {
#        $i = $i $j
#        $j = ""
#    }
#    return Index_reset()
#}

function Index_reset(    h, i, j, k, l, m, n) {
    for (i = 1; i <= NF; ++i) {
        if ($i == "") { ++n; continue }
        $(i - n) = $i
    }
    NF -= n
    return $0 = $0
}

#function Index_save(oldRecords) {
#    if (!oldRecords) return $0
#    return oldRecords ORS $0
#}

#function Index_nextRecord(    p, q, r) {
#    if ((r = getline) <= 0) r = 0
#    return r
#}

function get_FileName(fileName,    p, q, r) {
    Index_push(fileName, "/", "")
    r = $NF
    Index_pop()
    return r
}

function get_DirectoryName(fileName,    p, q, r) {
    Index_push(fileName, "/", "/")
    $NF = ""
#    Index_reset()
#    ++NF
    r = $0
    Index_pop()
    return r
}

function Path_join(directory, fileName,    h, i, j, k, l, m, n, o, p, q, r, s) {
    if (directory == "") directory = "."
    Index_push(directory"/"fileName, "/", "/")
    s = $1 != ""
    for (n = 1; n <= NF; ++n) {
        if ($n == "") Index_remove(n--)
        if (n > 1 && $n == ".") Index_remove(n--)
        if (n == 2 && $n == "..") { Index_remove(n - 1); --n }
        if (n > 2 && $n == "..") { Index_remove(n - 1, n); n -= 2 }
    }
    if (!s && $1 != ".." && $1 != ".") { Index_insert(1, " "); $1 = "" }
    r = $0
    Index_pop()
    return r
}

# DEPRECATED

function __get_FileName(fileName,    h, i, splits, dirName) {
    split(fileName, splits, "/")
    dirName = splits[length(splits)]
    return dirName
}

function __get_DirectoryName(fileName,    h, i, splits, splitsL, dirName) {
    split(fileName, splits, "/")
    splitsL = length(splits)
    if (splitsL == 1) return ""
    for (i = 1; i < splitsL; ++i)
        dirName = dirName splits[i]"/"
    return dirName
}
