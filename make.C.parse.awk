#
# Gemeinfrei. Public Domain.
# 2021 Hans Riehm

#include "meta.awk"
#include "make.C.awk"

function is_CName(name, end) {

    if (end ? name ~ /[a-zA-Z$_0-9]/ : name ~ /[a-zA-Z$_]/) return 1

    if (name ~ /[¢£¥§µ]/) return 1      # U00A2 U00A3 U00A5 U00A7 U00B5

    if (name ~ /[À-ÖÙ-öù-퟿]/) return 1 # U00C0-U00D6 or U00D9-U00F6 or U00F9-UD7FF
}

function C_parse(fileName, input,
    __,a,b,c,comments,d,directory,e,f,g,h,hash,i,j,k,l,m,n,name,o,p,q,r,s,string,t,u,v,w,was,x,y,z,zahl)
{
if (DEBUG == 2) __debug("Q: C_parse0 File "fileName)
    if ( !input["length"] ) if (!fileName || !File_read(input, fileName)) return
    parsed[fileName]["name"] = fileName

    Index_push("", "", "", "\0", "\n")
for (z = 1; z <= input["length"]; ++z) {
    Index_reset(input[z])

    was = "newline"
    hash = ""

    for (i = 1; i <= NF; ++i) {
        if ($i == "/") {
            if ($(i + 1) == "*") {
                was = "comment"; comments = 1; n = i + 1
                while (++n) {
                    if (n > NF) {
                        if (++z <= input["length"]) { Index_append(NF, "\n"); Index_append(NF, input[z]); --n; continue }
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
if (DEBUG == 2) __debug(fileName": Line "z":"i".."n": "was)
                i = n
                if (i < NF) Index_append(i++, FIX)
                continue
            }
            if ($(i + 1) == "/") {
                was = "comment"
                $(++i) = "*"
                while ($NF == "\\") { Index_remove(NF); if (++z <= input["length"]) Index_append(NF, input[z]) }
                Index_append(NF, "*/")
if (DEBUG == 2) __debug(fileName": Line "z":"i": // "was)
                i = NF
                continue
            }
            was = "/"
            if ($(i + 1) == "=") { ++i; was = was"=" }
            if (i < NF) Index_append(i++, FIX)
            continue
        }
        if ($i == "\\") {
            if (i == NF) { Index_remove(i--); if (++z <= input["length"]) Index_append(NF, input[z]); continue }
            if ($(i + 1) == "n") {
                __warning(fileName": Line "z": Stray \\n")
                Index_remove(i, i + 1); --i
                continue
            }
            __error(fileName": Line "z": Stray \\ or \\"$(i + 1))
            Index_remove(i); --i
            continue
        }
        if ($i == "#") {
            if ($(i + 1) == "#") {
                ++i; was = "##"
if (DEBUG == 2) __debug(fileName": Line "z":"i": "was)
                if (i < NF) Index_append(i++, FIX)
                continue
            }
            if (was == "newline") {
                was = "#"; hash = "#"
                if (i > 1) { Index_removeRange(1, i - 1); i = 1 }
                n = 1; while (++n <= NF) {
                    if ($n ~ /\s/) continue
                    --n; break
                }
                if (n > i) Index_removeRange(i + 1, n)
# if (DEBUG == 2) __debug(fileName": Line "z":"i": "was)
                if (i < NF) Index_append(i++, FIX)
                continue
            }
            was = "#"
if (DEBUG == 2) __debug(fileName": Line "z":"i": "was)
            if (i < NF) Index_append(i++, FIX)
            continue
        }
        if ($i ~ /\s/) {
            n = i; while (++n <= NF) {
                if ($n ~ /\s/) continue
                --n; break
            }
if (DEBUG == 2) __debug(fileName": Line "z":"i".."n":")
            i = n
            if (i < NF) Index_append(i++, FIX)
            continue
        }
        if ($i == "L" && $(i + 1) == "\"") ++i
        if ($i == "\"") {
            was = "\""
            string = ""
            n = i; while (++n <= NF) {
                if ($n == "\\") {
                    if (n == NF) { Index_remove(n--); if (++z <= input["length"]) Index_append(NF, input[z]); continue }
                    string = string"\\"$(n + 1)
                    ++n; continue
                }
                if ($n == "\"") break
                string = string $n
                if (n == NF) {
                    # $(++NF) = "\\"; $(++NF) = "n"; n += 2
                    # if (++z <= input["length"]) Index_append(NF, input[z])
                    # continue
                    $(++NF) = "\""
                    __warning(fileName": Line "z": String \" without ending \"")
                    break
                }
            }
if (DEBUG == 2) __debug(fileName": Line "z":"i".."n": \""string"\"")
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
                        if (n == NF) { Index_remove(n--); if (++z <= input["length"]) Index_append(NF, input[z]); continue }
                        string = string"\\"$(n++)
                        continue
                    }
                    if ($n == ">") break
                    string = string $n
                }
if (DEBUG == 2) __debug(fileName": Line "z":"i".."n": "hash" <"string">")
                i = n
                Index_append(i++, FIX)
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
                    if (n == NF) { Index_remove(n--); if (++z <= input["length"]) Index_append(NF, input[z]); continue }
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
        if ($i == "(" || $i == "[") {
            was = $i
            if (i < NF) Index_append(i++, FIX)
            continue
        }
        if ($i == ")" || $i == "]") {
            was = $i
            if (i < NF) Index_append(i++, FIX)
            continue
        }
        if ($i == "," || $i == "?" || $i == "~") {
            was = $i
            if (i < NF) Index_append(i++, FIX)
            continue
        }
        if ($i == ":") {
            if ($(i + 1) == ":") { ++i; was = was":" }
            if (i < NF) Index_append(i++, FIX)
            continue
        }
        if ($i == ";" || $i == "{" || $i == "}") {
            was = $i
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
                    if ($i == "\\" && i == NF) { Index_remove(i--); if (++z <= input["length"]) Index_append(NF, input[z]); continue }
                    if ($i ~ /[0-9a-fA-F]/) { zahl = zahl $i; continue }
                    --i; break
                }
                while (++i <= NF) {
                    if ($i == "\\" && i == NF) { Index_remove(i--); if (++z <= input["length"]) Index_append(NF, input[z]); continue }
                    if ($i ~ /[ulUL]/) { zahl = zahl $i; continue }
                    --i; break
                }
                if (i < NF) Index_append(i++, FIX)
                if (hash == "#") hash = "# "zahl
                was = zahl
if (DEBUG == 2) __debug(fileName": Line "z":"i": "was)
                continue
            }
            zahl = $i
            while (++i <= NF) {
                if ($i == "\\" && i == NF) { Index_remove(i--); if (++z <= input["length"]) Index_append(NF, input[z]); continue }
                if ($i ~ /[0-9]/) { zahl = zahl $i; continue }
                --i; break
            }
            if ($(i + 1) ~ /[uUlL]/) {
                while (++i <= NF) {
                    if ($i == "\\" && i == NF) { Index_remove(i--); if (++z <= input["length"]) Index_append(NF, input[z]); continue }
                    if ($i ~ /[uUlL]/) { zahl = zahl $i; continue }
                    --i; break
                }
                if (i < NF) Index_append(i++, FIX)
                if (hash == "#") hash = "# "zahl
                was = zahl
if (DEBUG == 2) __debug(fileName": Line "z":"i": "was)
                continue
            }
            if ($(i + 1) == ".") {
                ++i; zahl = zahl $i
                # lies das Fragment
                while (++i <= NF) {
                    if ($i == "\\" && i == NF) { Index_remove(i--); if (++z <= input["length"]) Index_append(NF, input[z]); continue }
                    if ($i ~ /[0-9]/) { zahl = zahl $i; continue }
                    --i; break
                }
            }
            if ($(i + 1) ~ /[eE]/) {
                ++i; zahl = zahl $i
                if ($(i + 1) ~ /[+-]/) { ++i; zahl = zahl $i }
                # lies den Exponent
                while (++i <= NF) {
                    if ($i == "\\" && i == NF) { Index_remove(i--); if (++z <= input["length"]) Index_append(NF, input[z]); continue }
                    if ($i ~ /[0-9]/) { zahl = zahl $i; continue }
                    --i; break
                }
            }
            if ($(i + 1) ~ /[fFlLdD]/) {
                while (++i <= NF) {
                    if ($i == "\\" && i == NF) { Index_remove(i--); if (++z <= input["length"]) Index_append(NF, input[z]); continue }
                    if ($i ~ /[fFlLdD]/) { zahl = zahl $i; continue }
                    if ($i ~ /[0-9]/) { zahl = zahl $i; continue }
                    --i; break
                }
                if ($(i + 1) ~ /[xX]/) { ++i; zahl = zahl $i }
            }
            if (i < NF) Index_append(i++, FIX)
            was = zahl
            if (hash == "#") hash = "# "zahl
if (DEBUG == 2) __debug(fileName": Line "z":"i": "was)
            continue
        }
        if (is_CName($i)) {
            name = $i
            n = i; while (++n <= NF) {
                if ($n == "\\" && n == NF) { Index_remove(n--); if (++z <= input["length"]) Index_append(NF, input[z]); continue }
                if (is_CName($n, 1)) { name = name $n; continue }
                --n; break
            }
            was = name
            if (hash == "#") hash = "# "name
if (DEBUG == 2) __debug(fileName": Line "z":"i".."n": "was)
            i = n
            if (i < NF) Index_append(i++, FIX)
            continue
        }
        __warning(fileName": Line "z": Unknown Character X"__HEX(Char_codepoint($i))" "$i); Index_remove(i--)
    }

    parsed[fileName][++parsed[fileName]["length"]] = $0
}
    Index_pop()
if (DEBUG == 2) __debug("A: C_parse File "fileName)
    return 1
}
