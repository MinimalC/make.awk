#!/usr/bin/awk -f

@include "run.awk"
@include "make.CDefine.awk"

function Define_eval(expression,    __,d) {
    if (typeof(REFIX) == "untyped") REFIX = @/\xA0/
    if (typeof(FIX) == "untyped") FIX = "\xA0"
    gsub(/\s+/, FIX, expression)
    for (d in C_defines) if ("value" in C_defines[d]) gsub(/\s+/, FIX, C_defines[d]["value"])
    return CDefine_evaluate(expression)
}

BEGIN {
    DEBUG=4

    C_defines["AWA"]["value"] = 5
    #C_defines["OHO"]["value"] = 5

    C_defines["__GNUC__"]["value"] = 7
    C_defines["__GNUC_MINOR__"]["value"] = 11
    C_defines["__GNUC_PREREQ"]["isFunction"] = 1
    C_defines["__GNUC_PREREQ"]["arguments"][1] = "maj"
    C_defines["__GNUC_PREREQ"]["arguments"][2] = "min"
    C_defines["__GNUC_PREREQ"]["arguments"]["0length"] = 2
    C_defines["__GNUC_PREREQ"]["value"] = "\\ ( ( __GNUC__ << 16 ) + __GNUC_MINOR__ >= ( ( maj ) << 16 ) + ( min ) )"
    C_defines["SQLITE_THREADSAFE"]["value"] = "1 /*IMP:R-07272-22309*/"
    C_defines["SQLITE_MAX_MMAP_SIZE"]["value"] = "0x7fff0000"

    C_defines["__GNUG__"]["value"] = 1
#    C_defines["size_t"]["value"] = 1
    C_defines["_XOPEN_SOURCE"]["value"] = 1100

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

        print ""; print "\""Define_eval( " /*IMP:R-07272-22309*/ 1")"\""


    }

    exit
}
