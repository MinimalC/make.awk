#!/usr/bin/awk -f

@include "run.awk"
@include "make.CDefine_eval.awk"

function Define_eval(expression,    __,d) {
    if (typeof(REFIX) == "untyped") REFIX = @/\xA0/
    if (typeof(FIX) == "untyped") FIX = "\xA0"
    gsub(/\s+/, FIX, expression)
    for (d in C_defines) if ("body" in C_defines[d]) gsub(/\s+/, FIX, C_defines[d]["body"])
    return CDefine_eval(expression)
}

BEGIN {
    DEBUG=4

    C_defines["AWA"]["body"] = 5
    #C_defines["OHO"]["body"] = 5

    C_defines["__GNUC__"]["body"] = 7
    C_defines["__GNUC_MINOR__"]["body"] = 11
    C_defines["__GNUC_PREREQ"]["isFunction"] = 1
    C_defines["__GNUC_PREREQ"]["arguments"][1] = "maj"
    C_defines["__GNUC_PREREQ"]["arguments"][2] = "min"
    C_defines["__GNUC_PREREQ"]["arguments"]["length"] = 2
    C_defines["__GNUC_PREREQ"]["body"] = "\\ ( ( __GNUC__ << 16 ) + __GNUC_MINOR__ >= ( ( maj ) << 16 ) + ( min ) )"
    C_defines["SQLITE_THREADSAFE"]["body"] = "1 /*IMP:R-07272-22309*/"
    C_defines["SQLITE_MAX_MMAP_SIZE"]["body"] = "0x7fff0000"

    C_defines["__GNUG__"]["body"] = 1
#    C_defines["size_t"]["body"] = 1
    C_defines["_XOPEN_SOURCE"]["body"] = 1100

    for (m = 1; m <= ARGV_length(); ++m) {
        print ""; print "\""Define_eval( ARGV[m])"\""
    } --m

    if (m == 0) {

        print ""; print "\""Define_eval( " 5 * ( AWA ) + ( 5 + 5 ) + 5 * OHO ")"\""

        print ""; print "\""Define_eval( "5 + 5 + 100 / ( 2 * AWA )")"\""

        print ""; print "\""Define_eval( "5 * 5 + ( 5 + 1 * AWA )")"\""

        print ""; print "\""Define_eval( "AWA * ( 30 / ( 12 - 2 * 3 ) ) + 5 == 6 * OHO")"\""

        print ""; print "\""Define_eval( "AWA * ( 30 / ( 12 - 2 * 3 ) ) + 5 == 6 * 5")"\""

        print ""; print "\""Define_eval( "defined ( AWA ) && ! defined ( OHO )")"\""

        print ""; print "\""Define_eval( " 5UL  >  4")"\""


        print ""; print "\""Define_eval( " defined ( __GNUC__ ) && defined ( AWA ) && AWA == 5 ")"\""

        print ""; print "\""Define_eval( "'\\x002B' + L'\\0' + '\\111' + 'A'")"\""

        print ""; print "\""Define_eval( " ( 5 + 5 ) ? ( 3 + 5 * 6 ) : 0")"\""

        print ""; print "\""Define_eval( "defined ( SQLITE_THREADSAFE ) && SQLITE_THREADSAFE > 0")"\""

        print ""; print "\""Define_eval( " ! defined ( SQLITE_OMIT_WAL ) || SQLITE_MAX_MMAP_SIZE > 0 ")"\""

        print ""; print "\""Define_eval( " defined __GNUC__ \\ || ( defined __STDC_WANT_LIB_EXT2__ && __STDC_WANT_LIB_EXT2__ > 0 ) ")"\""

        print ""; print "\""Define_eval( " ( _XOPEN_SOURCE - 0 ) >= 700 ")"\""

        print ""; print "\""Define_eval(" ! defined __GNUC__ || __GNUC__ < 2")"\""

        print ""; print "\""Define_eval( " ! __GNUC_PREREQ ( 7 , 0 )")"\""

    }

    exit
}

