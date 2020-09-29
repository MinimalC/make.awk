#!/usr/bin/awk -f

@include "meta.awk"

BEGIN {
    DEBUG=5

    defines["length"] = definesI = 0

    Array_add(defines, "AWA")
    defines["AWA"]["body"] = 5
    #Array_add(defines, "OHO")
    #defines["OHO"]["body"] = 5

    Array_add(defines, "__GNUC__")
    defines["__GNUC__"]["body"] = 7
    Array_add(defines, "__GNUC_MINOR__")
    defines["__GNUC_MINOR__"]["body"] = 11
    Array_add(defines, "__GNUC_PREREQ")
    defines["__GNUC_PREREQ"]["isFunction"] = 1
    defines["__GNUC_PREREQ"]["arguments"][1] = "maj"
    defines["__GNUC_PREREQ"]["arguments"][2] = "min"
    defines["__GNUC_PREREQ"]["arguments"]["length"] = 2
    defines["__GNUC_PREREQ"]["body"] = "\\ ( ( __GNUC__ << 16 ) + __GNUC_MINOR__ >= ( ( maj ) << 16 ) + ( min ) )"
    Array_add(defines, "SQLITE_THREADSAFE")
    defines["SQLITE_THREADSAFE"]["body"] = "1 /*IMP:R-07272-22309*/"
    Array_add(defines, "SQLITE_MAX_MMAP_SIZE")
    defines["SQLITE_MAX_MMAP_SIZE"]["body"] = "0x7fff0000"

    Array_add(defines, "__GNUG__")
    defines["__GNUG__"]["body"] = 1
#    Array_add(defines, "size_t")
#    defines["size_t"]["body"] = 1

    for (m = 1; m <= ARGV_length(); ++m) {
        print ""; print "\""Exxpression_evaluate( ARGV[m])"\""
    } --m

    if (m == 0) {

        print ""; print "\""Exxpression_evaluate( " 5 * ( AWA ) + ( 5 + 5 ) + 5 * OHO ")"\""

        print ""; print "\""Exxpression_evaluate( "5 + 5 + 100 / ( 2 * AWA )")"\""

        print ""; print "\""Exxpression_evaluate( "5 * 5 + ( 5 + 1 * AWA )")"\""

        print ""; print "\""Exxpression_evaluate( "AWA * ( 30 / ( 12 - 2 * 3 ) ) + 5 == 6 * OHO")"\""

        print ""; print "\""Exxpression_evaluate( "AWA * ( 30 / ( 12 - 2 * 3 ) ) + 5 == 6 * 5")"\""

        print ""; print "\""Exxpression_evaluate( "defined ( AWA ) && ! defined ( OHO )")"\""

        print ""; print "\""Exxpression_evaluate( " 5UL  >  4")"\""

        print ""; print "\""Exxpression_evaluate( " __GNUC_PREREQ ( 2 , 7 )")"\""

        print ""; print "\""Exxpression_evaluate( " defined ( __GNUC__ ) && defined ( AWA ) && AWA == 5 ")"\""

        print ""; print "\""Exxpression_evaluate( "'\\x002B' + L'\\0' + '\\111' + 'A'")"\""

        print ""; print "\""Exxpression_evaluate( " ( 5 + 5 ) ? ( 3 + 5 * 6 ) : 0")"\""

        print ""; print "\""Exxpression_evaluate( "defined ( SQLITE_THREADSAFE ) && SQLITE_THREADSAFE > 0")"\""

        print ""; print "\""Exxpression_evaluate( " ! defined ( SQLITE_OMIT_WAL ) || SQLITE_MAX_MMAP_SIZE > 0 ")"\""

    }

    exit
}

