#!/usr/bin/perl

use strict;
use warnings;

use POSIX;
use Getopt::Std;

my %opts;
getopts("v",%opts);

sub logerror {
    print STDERR "Error: @_\n"
}

# --- main
my $t = time;
if ($#ARGV > -1) {
    if ($ARGV[0] =~ /^\d+$/) { $t = $ARGV[0] }
    else {
        logerror "epoch expected, got: ${ARGV[0]}";
        exit 1;
    }
}

my %tsInfo;
$tsInfo{'utc'} = strftime("%Y-%m-%dT%H:%M:%SZ",gmtime($t));
$tsInfo{'loc'} = strftime("%Y-%m-%dT%H:%M:%S%z",localtime($t));
$tsInfo{'epoch'} = $t;
$tsInfo{'offset'} = strftime("%z",localtime($t));
$tsInfo{'tz'} = strftime("%Z",localtime($t));
$tsInfo{'week'} = strftime("%G-W%V-%u",gmtime($t));


print $tsInfo{'utc'} . " " . $tsInfo{'loc'} . " " . 
        $tsInfo{'epoch'} . " " . $tsInfo{'tz'} . " " .
        $tsInfo{'week'} . "\n";
