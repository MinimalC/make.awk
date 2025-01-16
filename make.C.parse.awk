#
# Gemeinfrei. Public Domain.

#include "run.awk"
#include "make.C.awk"

function is_CName(name, end) {
    # U00A2 U00A3 U00A5 U00A7 U00B5
    # U00C0-U00D6 or U00D9-U00F6 or U00F9-UD7FF
    # /[a-zA-Z$_¢£¥§µÀ-ÖÙ-öù-퟿]/ ÿ
    if (length(name) == 1) {
        if (!end) { if (name ~ /[a-zA-Z$_]/) return 1 }
        else if (name ~ /[a-zA-Z$_0-9]/) return 1
        return
    }
    if (name ~ /^[a-zA-Z$_][a-zA-Z$_0-9]*$/) return 1
}

function C_parse(fileName, input,
    __,a,b,c,comments,d,directory,e,f,g,h,hash,i,j,k,l,m,n,name,newline,o,p,q,r,s,string,t,u,v,w,was,x,y,z,zahl)
{
if (DEBUG == 2) __debug("Q: C_parse0 File "fileName)
    if ( !input["0length"] ) if (!fileName || !File_read(input, fileName)) return
    parsed[fileName]["name"] = fileName

    Index_push("", "", "", "\0", "\n")
for (z = 1; z <= input["0length"]; ++z) {
    Index_reset(input[z])

    newline = 1
    hash = ""

    for (i = 1; i <= NF; ++i) {
        if ($i ~ /\s/) {
            while (++i <= NF) {
                if ($i ~ /\s/) continue
                --i; break
            }
            if (i < NF) Index_append(i++, FIX)
            continue
        }
        if ($i == "#") {
            if (newline) {
                was = hash = "#"
                #if (i > 1) { Index_removeRange(1, i - 1); i = 1 }
                #n = 1; while (++n <= NF) {
                #    if ($n ~ /\s/) continue
                #    --n; break
                #}
                #if (n > i) Index_removeRange(i + 1, n)
# if (DEBUG == 2) __debug(fileName": Line "z":"i": "was)
                if (i < NF) Index_append(i++, FIX)
                continue
            }
            if ($(i + 1) == "#") {
                ++i; was = "##"
if (DEBUG == 2) __debug(fileName": Line "z":"i": "was)
                if (i < NF) Index_append(i++, FIX)
                continue
            }
            was = "#"
if (DEBUG == 2) __debug(fileName": Line "z":"i": "was)
            if (i < NF) Index_append(i++, FIX)
            continue
        }
        newline = 0
        if ($i == "/") {
            if ($(i + 1) == "*") {
                comments = 1; n = i + 1
                while (++n) {
                    if (n > NF) {
                        if (++z <= input["0length"]) { Index_append(NF, "\n"input[z]); --n; continue }
                        break
                    }
                    if (n > i + 2 && $(n - 1) == "/" && $n == "*") {
                        ++comments; $(n - 1) = "*"; __warning(fileName" Line "z": "comments". Comment in Comment /* /*")
                        continue
                    }
                    if (n > i + 2 && $(n - 1) == "*" && $n == "/") {
                        if (comments == 1) {
                            comments = 0
                            break
                        }
                        --comments; $n = "*"
                        continue
                    }
                }
                i = n
                if (i < NF) Index_append(i++, FIX)
                continue
            }
            if ($(i + 1) == "/") {
                $(++i) = "*"
                while ($NF == "\\") { Index_remove(NF); if (++z <= input["0length"]) Index_append(NF, "\n"input[z]) }
                Index_append(NF, "*/")
                i = NF
                continue
            }
            was = "/"
            if ($(i + 1) == "=") { ++i; was = was"=" }
            if (i < NF) Index_append(i++, FIX)
            continue
        }
        if ($i == "\\") {
            if (i == NF) { Index_remove(i--); if (++z <= input["0length"]) Index_append(NF, input[z]); continue }
            if ($(i + 1) == "n") {
                __warning(fileName": Line "z": Stray \\n")
                Index_remove(i, i + 1); --i
                continue
            }
            __error(fileName": Line "z": Stray \\ or \\"$(i + 1))
            Index_remove(i); --i
            continue
        }
        if ($i == "L" && $(i + 1) == "\"") ++i
        if ($i == "\"") {
            string = ""
            n = i; while (++n <= NF) {
                if ($n == "\\") {
                    if (n == NF) { Index_remove(n--); if (++z <= input["0length"]) Index_append(NF, input[z]); continue }
                    string = string"\\"$(n + 1)
                    ++n; continue
                }
                if ($n == "\"") break
                string = string $n
                if (n == NF) {
                    # $(++NF) = "\\"; $(++NF) = "n"; n += 2
                    # if (++z <= input["0length"]) Index_append(NF, input[z])
                    # continue
                    $(++NF) = "\""
                    __warning(fileName": Line "z": String \" without ending \"")
                    break
                }
            }
            was = "string"
if (DEBUG == 2) __debug(fileName": Line "z":"i".."n": "was" \""string"\"")
            i = n
            if (i < NF) Index_append(i++, FIX)
            continue
        }
        if ($i == "<") {
            was = "<"
            if (hash == "# include" || hash == "# using") {
                string = ""
                n = i; while (++n <= NF) {
                    if ($n == "\\") {
                        if (n == NF) { Index_remove(n--); if (++z <= input["0length"]) Index_append(NF, input[z]); continue }
                        string = string"\\"$(n++)
                        continue
                    }
                    if ($n == ">") break
                    string = string $n
                }
if (DEBUG == 2) __debug(fileName": Line "z":"i".."n": <"string">")
                i = n
                if (i < NF) Index_append(i++, FIX)
                continue
            }
            if (C_compiler == "tcc" && $(i + 1) == "c" && $(i + 2) == "d" && $(i + 3) == ">") {
                was = "##"
if (DEBUG == 2) __debug(fileName": Line "z":"i": "was)
                Index_remove(i + 2, i + 3)
                $i = "#"; $(++i) = "#"
                if (i < NF) Index_append(i++, FIX)
                continue
            }
            if ($(i + 1) == "<") { ++i; was = was"<" }
            if ($(i + 1) == "=") { ++i; was = was"=" }
            if (i < NF) Index_append(i++, FIX)
            continue
        }
        if ($i == "L" && $(i + 1) == "'") ++i
        if ($i == "'") {
            was = "'"
            string = ""
            n = i; while (++n <= NF) {
                if ($n == "\\") {
                    if (n == NF) { Index_remove(n--); if (++z <= input["0length"]) Index_append(NF, input[z]); continue }
                    string = string"\\"$(n++)
                    continue
                }
                if ($n == "'") break
                string = string $n
            }
            i = n
            if (i < NF) Index_append(i++, FIX)
            continue
        }
        if ($i == "*") {
            if ($(i + 1) == "/") {
                __warning(fileName": Line "z": Comment Ending */")
                Index_remove(i, i + 1); --i
                continue
            }
            was = "*"
            if ($(i + 1) == "=") { ++i; was = was"=" }
            if (i < NF) Index_append(i++, FIX)
            continue
        }
        if ($i == "=" || $i == "%" || $i == "^" || $i == "!") {
            was = $i
            if ($(i + 1) == "=") { ++i; was = was"=" }
            if (i < NF) Index_append(i++, FIX)
            continue
        }
        if ($i == "&" || $i == "|") {
            was = $i
            if ($(i + 1) == $i) { ++i; was = was $i }
            else if ($(i + 1) == "=") { ++i; was = was"=" }
            if (i < NF) Index_append(i++, FIX)
            continue
        }
        if ($i == ">") {
            was = ">"
            if ($(i + 1) == ">") { ++i; was = was">" }
            if ($(i + 1) == "=") { ++i; was = was"=" }
            if (i < NF) Index_append(i++, FIX)
            continue
        }
        if ($i == ".") {
            was = "."
            if ( $(i + 1) == "." && $(i + 2) == "." ) { i += 2; was = "..." }
            # if ( $(i + 1) == "." ) { ++i; was = ".." }
            if (i < NF) Index_append(i++, FIX)
            continue
        }
        if ($i == "(" || $i == "[" || $i == ")" || $i == "]" || $i == "{" || $i == "}") {
            was = $i
            if (i < NF) Index_append(i++, FIX)
            continue
        }
        if ($i == ";" || $i == "," || $i == "?" || $i == "~") {
            was = $i
            if (i < NF) Index_append(i++, FIX)
            continue
        }
        if ($i == ":") {
            if ($(i + 1) == ":") { ++i; was = was":" }
            if (i < NF) Index_append(i++, FIX)
            continue
        }
        if ($i == "+") {
            if ($(i + 1) ~ /[0-9]/ && was !~ /[0-9]/) continue
            was = "+"
            if ($(i + 1) == "+") { ++i; was = was"+" }
            else if ($(i + 1) == "=") { ++i; was = was"=" }
            if (i < NF) Index_append(i++, FIX)
            continue
        }
        if ($i == "-") {
            if ($(i + 1) ~ /[0-9]/ && was !~ /[0-9]/) continue
            was = "-"
            if ($(i + 1) == ">") { ++i; was = was">" }
            else if ($(i + 1) == "-") { ++i; was = was"-" }
            else if ($(i + 1) == "=") { ++i; was = was"=" }
            if (i < NF) Index_append(i++, FIX)
            continue
        }
        if ($i ~ /[0-9]/) {
            if ($i == "0" && $(i + 1) == "x") {
                i += 2
                zahl = "0x"
                while (++i <= NF) {
                    if ($i == "\\" && i == NF) { Index_remove(i--); if (++z <= input["0length"]) Index_append(NF, input[z]); continue }
                    if ($i ~ /[0-9a-fA-F]/) { zahl = zahl $i; continue }
                    --i; break
                }
                while (++i <= NF) {
                    if ($i == "\\" && i == NF) { Index_remove(i--); if (++z <= input["0length"]) Index_append(NF, input[z]); continue }
                    if ($i ~ /[ulUL]/) { zahl = zahl $i; continue }
                    --i; break
                }
                if (i < NF) Index_append(i++, FIX)
                if (hash == "#") { was = "#"; hash = "# "zahl }
                else was = "zahl"
if (DEBUG == 2) __debug(fileName": Line "z":"i": "was" "zahl)
                continue
            }
            zahl = $i
            while (++i <= NF) {
                if ($i == "\\" && i == NF) { Index_remove(i--); if (++z <= input["0length"]) Index_append(NF, input[z]); continue }
                if ($i ~ /[0-9]/) { zahl = zahl $i; continue }
                --i; break
            }
            if ($(i + 1) ~ /[uUlL]/) {
                while (++i <= NF) {
                    if ($i == "\\" && i == NF) { Index_remove(i--); if (++z <= input["0length"]) Index_append(NF, input[z]); continue }
                    if ($i ~ /[uUlL]/) { zahl = zahl $i; continue }
                    --i; break
                }
                if (i < NF) Index_append(i++, FIX)
                if (hash == "#") { was = "#"; hash = "# "zahl }
                else was = "zahl"
if (DEBUG == 2) __debug(fileName": Line "z":"i": "was" "zahl)
                continue
            }
            if ($(i + 1) == ".") {
                ++i; zahl = zahl $i
                # lies das Fragment
                while (++i <= NF) {
                    if ($i == "\\" && i == NF) { Index_remove(i--); if (++z <= input["0length"]) Index_append(NF, input[z]); continue }
                    if ($i ~ /[0-9]/) { zahl = zahl $i; continue }
                    --i; break
                }
            }
            if ($(i + 1) ~ /[eE]/) {
                ++i; zahl = zahl $i
                if ($(i + 1) ~ /[+-]/) { ++i; zahl = zahl $i }
                # lies den Exponent
                while (++i <= NF) {
                    if ($i == "\\" && i == NF) { Index_remove(i--); if (++z <= input["0length"]) Index_append(NF, input[z]); continue }
                    if ($i ~ /[0-9]/) { zahl = zahl $i; continue }
                    --i; break
                }
            }
            if ($(i + 1) ~ /[fFlLdD]/) {
                while (++i <= NF) {
                    if ($i == "\\" && i == NF) { Index_remove(i--); if (++z <= input["0length"]) Index_append(NF, input[z]); continue }
                    if ($i ~ /[fFlLdD]/) { zahl = zahl $i; continue }
                    if ($i ~ /[0-9]/) { zahl = zahl $i; continue }
                    --i; break
                }
                if ($(i + 1) ~ /[xX]/) { ++i; zahl = zahl $i }
            }
            if (i < NF) Index_append(i++, FIX)
            if (hash == "#") { was = "#"; hash = "# "zahl }
            else was = "zahl"
if (DEBUG == 2) __debug(fileName": Line "z":"i": "was" "zahl)
            continue
        }
        if (is_CName($i)) {
            #if (was == "name" && name == "struct") name = "struct "$i
            name = $i
            n = i; while (++n <= NF) {
                if ($n == "\\" && n == NF) { Index_remove(n--); if (++z <= input["0length"]) Index_append(NF, input[z]); continue }
                if (is_CName($n, 1)) { name = name $n; continue }
                --n; break
            }
            if (hash == "#") { was = "#"; hash = "# "name }
            else was = "name"
if (DEBUG == 2) __debug(fileName": Line "z":"i".."n": "was" "name)
            i = n
            if (i < NF) Index_append(i++, FIX)
            continue
        }
        __warning(fileName": Line "z": Unknown Character X"__HEX(Char_codepoint($i))" "$i); Index_remove(i--)
    }
    parsed[fileName][++parsed[fileName]["0length"]] = $0
}
    Index_pop()
if (DEBUG == 2) __debug("A: C_parse File "fileName)
    return 1
}
