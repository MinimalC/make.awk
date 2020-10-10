#!/usr/bin/awk -f

@include "meta.awk"
@include "make.CExpression_evaluate.awk"

function Exxpression_evaluate(expression,    a, b, c, d) {
    if (typeof(fixFS) == "untyped") fixFS = @/[\x01]/
    if (typeof(fix) == "untyped") fix = "\x01"
    gsub(" ", fix, expression)
    for (d in defines) if ("body" in defines[d]) gsub(/ +/, fix, defines[d]["body"])
    return CExpression_evaluate(expression)
}

BEGIN {
    DEBUG=5

    defines["AWA"]["body"] = 5
    #defines["OHO"]["body"] = 5

    defines["__GNUC__"]["body"] = 7
    defines["__GNUC_MINOR__"]["body"] = 11
    defines["__GNUC_PREREQ"]["isFunction"] = 1
    defines["__GNUC_PREREQ"]["arguments"][1] = "maj"
    defines["__GNUC_PREREQ"]["arguments"][2] = "min"
    defines["__GNUC_PREREQ"]["arguments"]["length"] = 2
    defines["__GNUC_PREREQ"]["body"] = "\\ ( ( __GNUC__ << 16 ) + __GNUC_MINOR__ >= ( ( maj ) << 16 ) + ( min ) )"
    defines["SQLITE_THREADSAFE"]["body"] = "1 /*IMP:R-07272-22309*/"
    defines["SQLITE_MAX_MMAP_SIZE"]["body"] = "0x7fff0000"

    defines["__GNUG__"]["body"] = 1
#    defines["size_t"]["body"] = 1
    defines["_XOPEN_SOURCE"]["body"] = 1100

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


        print ""; print "\""Exxpression_evaluate( " defined ( __GNUC__ ) && defined ( AWA ) && AWA == 5 ")"\""

        print ""; print "\""Exxpression_evaluate( "'\\x002B' + L'\\0' + '\\111' + 'A'")"\""

        print ""; print "\""Exxpression_evaluate( " ( 5 + 5 ) ? ( 3 + 5 * 6 ) : 0")"\""

        print ""; print "\""Exxpression_evaluate( "defined ( SQLITE_THREADSAFE ) && SQLITE_THREADSAFE > 0")"\""

        print ""; print "\""Exxpression_evaluate( " ! defined ( SQLITE_OMIT_WAL ) || SQLITE_MAX_MMAP_SIZE > 0 ")"\""

        print ""; print "\""Exxpression_evaluate( " defined __GNUC__ \\ || ( defined __STDC_WANT_LIB_EXT2__ && __STDC_WANT_LIB_EXT2__ > 0 ) ")"\""

        print ""; print "\""Exxpression_evaluate( " ( _XOPEN_SOURCE - 0 ) >= 700 ")"\""

        print ""; print "\""Exxpression_evaluate(" ! defined __GNUC__ || __GNUC__ < 2")"\""

        print ""; print "\""Exxpression_evaluate( " ! __GNUC_PREREQ ( 7 , 0 )")"\""

    }

    exit
}

