#!/usr/bin/awk -f
# Gemeinfrei. Public Domain.
# 2020 Hans Riehm

BEGIN {
    PROCINFO["sorted_in"] = "@ind_num_asc"
    LC_ALL="C"
#   RS="\0"
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


function File_exists(fileName,    h, i, j) {
    if (!fileName) { print "File_exists: fileName is null">"/dev/stderr"; return }
#    if ((getline j < fileName) < 0) return 1
    if (!system("test -s "fileName)) return 1
}

function Directory_exists(dirName) {
    if (!dirName) { print "Directory_exists: dirName is null">"/dev/stderr"; return }
    if (!system("test -d "dirName)) return 1
}

function File_contains(fileName, string) {
    if (!fileName) { print "File_contains: fileName is null">"/dev/stderr"; return }
    if (!string) { print "File_contains: string is null">"/dev/stderr"; return }
    if (!system("grep -r '"string"' "fileName" >/dev/null")) return 1
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
    for (h = l; h >= i; --h) {
        array[h] = array[h - 1]
    }
    if (typeof(value) != "untyped") array[i] = value
    else array[i] # = 0
    # return i
}

function StringArray_insertBefore(array, string0, string1,    h, i, j, k, l, m, n, n0, n1, o) {
    l = array["length"]
    for (n = 1; n <= l; ++n) {
        if (array[n] == string0) { n0 = n; continue }
        if (array[n] == string1) { n1 = n; continue }
    }
    if (!n0) {
        Array_insert(array, 1, string0)
        Array_insert(array, 1, string1)
    }
    else if (!n1) {
        Array_insert(array, n0, string1)
    }
    else if (n1 > n0) {
        Array_remove(n1)
        Array_insert(array, n0, string1)
    }
}

function StringArray_insertAfter(array, string0, string1,    h, i, j, k) {
    l = array["length"]
    for (n = 1; n <= l; ++n) {
        if (array[n] == string0) { n0 = n; continue }
        if (array[n] == string1) { n1 = n; continue }
    }
    if (!n0) {
        Array_insert(array, l, string1)
        Array_insert(array, l, string0)
    }
    else if (!n1) {
        Array_insert(array, n0 + 1, string1)
    }
    else if (n1 < n0) {
        Array_remove(n1)
        Array_insert(array, n0 + 1, string1)
    }
}

function Array_remove(array, i,    h, j, k, l, m, n) {
    if (typeof(i) == "untyped") { error = "i is no Number"; nextfile }
    if (typeof(i) != "number") { delete array[i]; return }
    l = array["length"]
    for (n = i + 1; n <= l; ++n) {
        array[n - 1] = array[n]
    }
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


function String_join(sepp, array,    h, i, reture) {
    for (i = 1; i <= array["length"]; ++i) {
        if (i == 1) reture = array[1]
        else reture = reture sepp array[i]
    }
    return reture
}

function String_concat(string0, sepp, string1) {
    if (typeof(string1) == "untyped") { string1 = sepp; sepp = OFS }
    if (!string0) return string1
    if (!string1) return string0
    return string0 sepp string1
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

function Index_pop(fromFS, fromOFS,    h, i, reture) {

    if (typeof(fromOFS) != "untyped") OFS = fromOFS
    if (typeof(fromFS) != "untyped")  FS  = fromFS
    reture = $0

    if (i = Array_length(Index)) {

        ORS = Index[i]["OUTPUTRECORDSEP"]
        RS  = Index[i]["RECORDSEP"]
        OFS = Index[i]["OUTPUTFIELDSEP"]
        FS  = Index[i]["FIELDSEP"]
        $0  = Index[i][0]

        Array_remove(Index, i)
    }
    Index_reset()
    return reture
}

#function Index_prependOrNot(i, value, ifNot) {
#    if (i == 1) return Index_reset()
#    return Index_prepend(i, value, ifNot)
#}

function Index_prepend(i, value, ifNot,    p, q, r) {
    if (typeof(value) == "untyped") { error = "value is untyped"; nextfile }
    r = 0
    if (typeof(ifNot) == "untyped" || $(i - 1) != ifNot) {
        $i = value OFS $i
        r = length(value)
    }
    Index_reset()
    return r
}

function Index_append(i, value, ifNot,    p, q, r) {
    if (typeof(value) == "untyped") { error = "value is untyped"; nextfile }
    r = 0
    if (typeof(ifNot) == "untyped" || $(i + 1) != ifNot) {
        $i = $i OFS value
        r = length(value)
    }
    Index_reset()
    return r
}

function Index_remove(i) {
    $i = ""
    return Index_reset()
}

function Index_merge(i, len,    h, j, k, l) {
    l = i + len
    for (j = i; ++j <= l; ) {
        $i = $i $j
        $j = ""
    }
    return Index_reset()
}

function Index_reset() {
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

function get_FileName(fileName,    h, i, reture) {
    Index_push(fileName, "/", "")
    reture = $NF
    Index_pop()
    return reture
}

function get_DirectoryName(fileName,    h, i, reture) {
    Index_push(fileName, "/", "/")
    $NF = ""
    Index_reset()
    reture = $0
    Index_pop()
    return reture
}

function Path_join(path0, path1,    a, b, c, d, e, f, g, h, i, reture, updirs) {
    Index_push(path1, "/", "/")
    i = 1; do {
        if ($i == "..") {
            if (i > 1) $(i - 1) = ""
            else {
                ++updirs
                $i = ""
            }
            continue
        }
        if ($i == ".") { $i = ""; continue }
    } while (i <= NF)
    Index_pop()
    return reture
}


# DEPRECATED

function __get_FileName(fileName,    h, i, splits, dirName) {
    split(fileName, splits, "/")
    dirName = splits[length(splits)]
    return dirName
}

function __get_DirectoryName(fileName,    h, i, splitsL, dirName) {
    split(fileName, splits, "/")
    splitsL = length(splits)
    if (splitsL == 1) return ""
    for (i = 1; i < splitsL; ++i)
        dirName = dirName splits[i]"/"
    return dirName
}
