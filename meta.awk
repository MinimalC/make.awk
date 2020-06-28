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


function File_exists(fileName) {
    if (!fileName) { print "File_exists: fileName is null">"/dev/stderr"; return }
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

function Array_remove(array, i) {
    if (typeof(i) == "untyped") { error = "i is no Number"; nextfile }
    if (typeof(i) != "number") { delete array[i]; return }
    if (Array_length(array)) --array["length"]
    delete array[i]
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


function Index_pushArray(newArray, newFS, newOFS, newRS, newORS,    h, i, j, k, l, m, n) {
    # save old Index
    i = Array_add(Index)
    if (typeof(newORS) != "untyped") {
        if (newORS != ORS) Index[i]["OUTPUTRECORDSEP"] = ORS
        ORS = newORS
    }
    if (typeof(newRS) != "untyped") {
        if (newRS != RS) Index[i]["RECORDSEP"] = RS
        RS = newRS
    }
    if (typeof(newOFS) != "untyped") {
        if (newOFS != OFS) Index[i]["OUTPUTFIELDSEP"] = OFS
        OFS = newOFS
    }
    if (typeof(newFS) != "untyped") {
        if (newFS != FS) Index[i]["FIELDSEP"] = FS
        FS = newFS
    }
    Index[i][0] = $0

    # new Index
    if (typeof(newArray) != "untyped") {
        if (typeof(newArray) != "array") { error = "newArray isn't Array"; nextfile }

        for (n = 1; n <= newArray["length"]; ++n) {
            m = m newArray[n] ORS
        }
        return $0 = m
    }
    return Index_reset()
}

function Index_push(newIndex, newFS, newOFS, newRS, newORS,    h, i) {
    # save old Index
    i = Array_add(Index)
    if (typeof(newORS) != "untyped") {
        if (newORS != ORS) Index[i]["OUTPUTRECORDSEP"] = ORS
        ORS = newORS
    }
    if (typeof(newRS) != "untyped") {
        if (newRS != RS) Index[i]["RECORDSEP"] = RS
        RS = newRS
    }
    if (typeof(newOFS) != "untyped") {
        if (newOFS != OFS) Index[i]["OUTPUTFIELDSEP"] = OFS
        OFS = newOFS
    }
    if (typeof(newFS) != "untyped") {
        if (newFS != FS) Index[i]["FIELDSEP"] = FS
        FS = newFS
    }
    Index[i][0] = $0

    # new Index
    if (typeof(newIndex) != "untyped") {
        return $0 = newIndex
    }
    return Index_reset()
}

function Index_pop(    h, i) {

    if (i = Array_length(Index)) {

        if (typeof(Index[i]["OUTPUTRECORDSEP"]) != "untyped")
            ORS  = Index[i]["OUTPUTRECORDSEP"]
        if (typeof(Index[i]["RECORDSEP"]) != "untyped")
            RS   = Index[i]["RECORDSEP"]
        if (typeof(Index[i]["OUTPUTFIELDSEP"]) != "untyped")
            OFS  = Index[i]["OUTPUTFIELDSEP"]
        if (typeof(Index[i]["FIELDSEP"]) != "untyped")
            FS   = Index[i]["FIELDSEP"]

        $0 = Index[i][0]

        Array_remove(Index, i)
    }
    return Index_reset()
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

function Index_save(oldRecords) {
    if (!oldRecords) return $0
    return oldRecords ORS $0
}

function Index_nextRecord(    p, q, r) {
    r = 0
    if ((r = getline) <= 0) r = 0
    return r
}

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
