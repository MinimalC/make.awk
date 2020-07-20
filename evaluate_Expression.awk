#!/usr/bin/awk -f

@include "meta.awk"

BEGIN {

    defines["length"] = definesI = 0
    definesI = Array_add(defines, "AWA")
    defines["AWA"]["body"] = 5
    #definesI = Array_add(defines, "OHO")
    #defines["OHO"]["body"] = 5

    for (m = 1; m <= ARGV_length(); ++m) {

        print ""; print "\""evaluate_Expression( ARGV[m], defines)"\""
    } --m

    if (m == 0) {

        print ""; print "\""evaluate_Expression( " 5 * (AWA) + (5 + 5) + 5 * OHO ", defines)"\""

        print ""; print "\""evaluate_Expression( "5 + 5 + 100 / (2 * AWA)", defines)"\""

        print ""; print "\""evaluate_Expression( "5 * 5 + (5 + 1 * AWA)", defines)"\""

        print ""; print "\""evaluate_Expression( "AWA*(30/(12-2*3))+5==6*OHO", defines)"\""

        print ""; print "\""evaluate_Expression( "defined(AWA)", defines)"\""
    }

    exit
}

