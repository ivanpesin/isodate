#!/usr/bin/perl

use strict;
use warnings;

use POSIX;
use Getopt::Std;

my %opts;
getopts("ulewozvhrd:f:",\%opts);

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

sub usage {
    print <<'EOF';
isodate -- print timestamps and convert epoch to human-readable form.

Usage:
    isodate [ -r [-d <delim>] [-f <fno>] [-l] | <selector> [<epoch>]]

    Replace mode
    -r      read from stdin and replace epoch timestamp in specified 
            position. Replaces with UTC timestamp, unless '-l'
            specified to use local timestamp.
    -d <delim>
            use <delim> as a field separator. Default: ','
    -f <fno>
            replace epoch timestamp in field <fno>. First field has
            number 1, which is also a default value.

    Timestamps mode
    -u      show UTC timestamp    
    -l      show local timestamp
    -e      show epoch timestamp
    -o      show local offset
    -z      show local timezone
    -w      show ISO week (always in UTC)
    -v      show verbose multiline output with all timestmaps

    If no selectors specified, timestamps are shown in one line, 
    separated by space. Selectors are mutually exclusive.

    If <epoch> is specified after selectors, it is used instead of
    current time for all timestamps.

Examples:

    Replace mode:
    $ cat log_with_epoch_ts.log | isodate -r -d , -f 2
    $ cat log_with_epoch_ts.log | isodate -r -d , -f 2 -l

    Timestamp mode:
    $ isodate
    2017-08-20T17:52:48Z 2017-08-20T13:52:48-0400 1503251568 EDT 2017-W33-7
    $ isodate -u
    2017-08-20T17:53:24Z
    $ isodate -l 1000000000
    2001-09-08T21:46:40-0400

EOF
    exit 0;
}

# --- main
if (defined($opts{'h'})) { usage; }
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