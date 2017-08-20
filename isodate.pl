#!/usr/bin/perl

use strict;
use warnings;

use POSIX;
use Getopt::Std;

my %opts;
getopts("ulewozvrd:f:",\%opts);

sub logerror {
    print STDERR "Error: @_\n"
}

sub replace_epoch {
    # field delimeter
    $opts{'d'} = "," unless (defined($opts{'d'}));
    # field no with epoch ts
    $opts{'f'} = 1 unless (defined($opts{'f'}) && $opts{'f'} =~ /^\d+$/);

    my $lno = 0;
    my ($c_epoch, $c_ts) = ("", "");

    while (my $l = <STDIN>) {
        $lno++;
        
        my @l = split($opts{'d'}, $l);
        if ($opts{'f'} - 1 > $#l) {
            print $l;
            logerror sprintf("line %d: only %d fields in line < %d",$lno,$#l+1,$opts{'f'});
            next;
        }

        my $t = $l[$opts{'f'} - 1];
        if ($t ne $c_epoch) {
            if ($t !~ /^\d+$/) {
                print $l;
                chomp($t);
                logerror sprintf("line %d: expect epoch, but found: '%s'", $lno, $t);
                next;
            }
            $c_epoch = $t;
            if (defined($opts{'l'})) { 
                $c_ts = strftime("%Y-%m-%dT%H:%M:%SZ",localtime($t));
            } else { 
                $c_ts = strftime("%Y-%m-%dT%H:%M:%SZ",gmtime($t));
            } 
        }
        $l[$opts{'f'} - 1] = $c_ts;
        print join($opts{'d'}, @l);
    }
}

# --- main

if (defined($opts{'r'})) {
    replace_epoch();
    exit 0;
}

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

sub oneline {
    my $ts;
    if ($opts{'u'})    { $ts = $tsInfo{'utc'};    }
    elsif ($opts{'l'}) { $ts = $tsInfo{'loc'};    }
    elsif ($opts{'e'}) { $ts = $tsInfo{'epoch'};  }
    elsif ($opts{'w'}) { $ts = $tsInfo{'week'};   }
    elsif ($opts{'o'}) { $ts = $tsInfo{'offset'}; }
    elsif ($opts{'z'}) { $ts = $tsInfo{'tz'};     }
    else { $ts = $tsInfo{'utc'} . " " . $tsInfo{'loc'} . " " . 
                 $tsInfo{'epoch'} . " " . $tsInfo{'tz'} . " " .
                 $tsInfo{'week'};
    }
    print $ts,"\n";
}

sub verbose {
    printf "%6s: %s\n", "UTC", $tsInfo{'utc'};
    printf "%6s: %s\n", "Local", $tsInfo{'loc'};
    printf "%6s: %s\n", "Epoch", $tsInfo{'epoch'};
    printf "%6s: %s\n", "Offset", $tsInfo{'offset'};
    printf "%6s: %s\n", "TZ", $tsInfo{'tz'};
    printf "%6s: %s\n", "Week", $tsInfo{'week'};
}

if (defined($opts{'v'})) { verbose() }
else { oneline() }