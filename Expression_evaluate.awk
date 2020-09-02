#!/usr/bin/awk -f

@include "meta.awk"

BEGIN {
    DEBUG=2

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
    defines["__GNUC_PREREQ"]["function"][1] = "maj"
    defines["__GNUC_PREREQ"]["function"][2] = "min"
    defines["__GNUC_PREREQ"]["function"]["length"] = 2
    defines["__GNUC_PREREQ"]["body"] = "\\ ( ( __GNUC__ << 16 ) + __GNUC_MINOR__ >= ( ( maj ) << 16 ) + ( min ) )"
    Array_add(defines, "SQLITE_THREADSAFE")
    defines["SQLITE_THREADSAFE"]["body"] = "1 /* IMP: R-07272-22309 */"

    Array_add(defines, "__GNUG__")
    defines["__GNUG__"]["body"] = 1
#    Array_add(defines, "size_t")
#    defines["size_t"]["body"] = 1

    for (m = 1; m <= ARGV_length(); ++m) {
        print ""; print "\""Expression_evaluate( ARGV[m], defines)"\""
    } --m

    if (m == 0) {

        print ""; print "\""Expression_evaluate( " 5 * (AWA) + (5 + 5) + 5 * OHO ", defines)"\""

        print ""; print "\""Expression_evaluate( "5 + 5 + 100 / (2 * AWA)", defines)"\""

        print ""; print "\""Expression_evaluate( "5 * 5 + (5 + 1 * AWA)", defines)"\""

        print ""; print "\""Expression_evaluate( "AWA*(30/(12-2*3))+5==6*OHO", defines)"\""

        print ""; print "\""Expression_evaluate( "AWA*(30/(12-2*3))+5==6*5", defines)"\""

        print ""; print "\""Expression_evaluate( "defined(AWA) && !defined(OHO)", defines)"\""

        print ""; print "\""Expression_evaluate( " 5UL  >  4", defines)"\""

        print ""; print "\""Expression_evaluate( " __GNUC_PREREQ (2, 7)", defines)"\""

        print ""; print "\""Expression_evaluate( " !( defined ( __GNUG__ ) && defined ( size_t ) ) ", defines)"\""

        print ""; print "\""Expression_evaluate( "'\\x002B' + L'\\0' + '\\111' + 'A'", defines)"\""

        print ""; print "\""Expression_evaluate( " (5 + 5) ? ( 3 + 5 * 6 ) : 0", defines)"\""

        print ""; print "\""Expression_evaluate( "defined(SQLITE_THREADSAFE) && SQLITE_THREADSAFE > 0", defines)"\""
    }

    exit
}

