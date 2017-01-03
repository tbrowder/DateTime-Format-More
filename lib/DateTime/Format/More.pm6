unit module DateTime::Format::More:auth<github:tbrowder>;

# file:  ALL-SUBS.md
# title: Subroutines Exported by the `:ALL` Tag

# export a debug var for users
our $DEBUG is export(:DEBUG) = False;
BEGIN {
    if %*ENV<DATETIME_FORMAT_MORE_DEBUG> {
	$DEBUG = True;
    }
    else {
	$DEBUG = False;
    }
}

sub time-stamp(:$set-time, :$code, :$utc, Int :$round = -1 --> Str) is export(:time-stamp) {
    my $dt; # DateTime object
    if $set-time {
        $dt = DateTime.new($set-time);
    }
    else {
        $dt = DateTime.now;
    }

    my $dts;

    if $utc {
        $dt .= utc;
    }
    elsif $code {
        my $tzo = $dt.timezone; # signed: ssss OR -ssss
        my $tcode = time-zone-code($tzo);
        $dt .= local;
        $dts = $dt.Str;
        $dts ~~ s/<[-+]> \d\d\:\d\d $/\-$tcode/;
    }

    my $default-fmt = { sprintf "%04d-%02d-%02dT%02d:%02d:%05.2fZ",
                .year, .month, .day, .hour, .minute, .second};
    my $fmt2 = { sprintf "%04d-%02d-%02dT%02d:%02d:%05.2f%+03d%02d",
                .year, .month, .day, .hour, .minute, .second,
                .timezone div 3600, .timezone % 3600};

    if $round >= 0 {
        # need string format
        $dts = $dt.Str if !$dts;
        # need seconds
        say "DEBUG: \$dts = '$dts'";
        if $dts ~~ / \: (\d\d\.\d+) / {
            my $sec = ~$0; # need value as a string in order to capture the trailing zeroes
            say "DEBUG: seconds = '$sec'";
            #my $dec = $$$$
            #my $round-sec = sprintf "%
        }
    }

    if $dts {
        return $dts;
    }
    else {
        return $dt.Str;
    }

} # time-stamp

=begin pod
sub time-stamp(Bool :$basic = True,
               Bool :$day = True,
               Bool :$local = True,
               Str  :$set-time,
               Str  :$tz,
               Bool :$decorated = True) is export(:time-stamp) {

    # default is extended UTC
    my $tz-offset = 'Z';
    if $tz {
        $tz-offset = time-zone-offset-us($tz);
        $tz-offset ~~ s:g/ \: // if $basic;
    }

    my $date;
    if $day {
	$date = DateTime.now(formatter => {
	sprintf "%04d-%02d-%02d",
	.year, .month, .day});
        $date ~~ s:g/ \: // if $basic;
    }
    elsif $local {
	$date = DateTime.now.local(formatter => {
				    sprintf "%04d-%02d-%02dT%02d:%02d:%02d",
				    .year, .month, .day, .hour, .minute, .second});
        $date ~~ s:g/ <[:-]> // if $basic;
    }
    elsif $decorated {
	$date = DateTime.now.utc(formatter => {
	# bzr-friendly format (no ':' used)
	sprintf "%04d%02d%02dT%02dh%02dm%02ds",
	.year, .month, .day, .hour, .minute, .second});
    }
    else {
        # ISO 8601 extended
	$date = DateTime.now.utc(formatter => {
				    sprintf "%04d-%02d-%02dT%02d:%02d:%02d",
				    .year, .month, .day, .hour, .minute, .second});
        $date ~~ s:g/ <[:-]> // if $basic;
    }

    $date ~= $tz-offset;

    return $date;
} # time-stamp
=end pod

sub time-zone-code(Int $tz-offset, Bool :$dst = False) {
    # given a time zone offset in seconds, return either a
    # three- or four-character string describing a
    # US time zone or the one-character Naval Time code,
    # including 'Z' for zero (UTC)

    my $c;
    # convert the time zone offset to hours
    my $o = $tz-offset div 3600;
    $o += 1 if $dst;
    given $o {
        # standard
        when  +12 { $c = 'M'    }
        when  +11 { $c = 'L'    }
        when  +10 { $c = 'ChST' }
        when   +9 { $c = 'I'    }
        when   +8 { $c = 'H'    }
        when   +7 { $c = 'G'    }
        when   +6 { $c = 'F'    }
        when   +5 { $c = 'E'    }
        when   +4 { $c = 'D'    }
        when   +3 { $c = 'C'    }
        when   +2 { $c = 'B'    }
        when   +1 { $c = 'A'    }
        when    0 { $c = 'Z'    }
        when   -1 { $c = 'N'    }
        when   -2 { $c = 'O'    }
        when   -3 { $c = 'P'    }
        when   -4 { $c = 'AST'  }
        when   -5 { $c = 'EST'  }
        when   -6 { $c = 'CST'  }
        when   -7 { $c = 'MST'  }
        when   -8 { $c = 'PST'  }
        when   -9 { $c = 'AHST' }
        when  -10 { $c = 'HAST' }
        when  -11 { $c = 'X'    }
        when  -12 { $c = 'Y'    }
    }

    return $c;

} # time-zone-code

sub time-zone-offset-us(Str $tz, :$basic) {
    # given a three-character string describing a US time zone,
    # return the ISO 8601 extended (or basic) offset
    my $offset = 'Z'; # UTC
    given $tz {
        # standard
        when /:i ast / { $offset = '-04:00' }
        when /:i est / { $offset = '-05:00' }
        when /:i cst / { $offset = '-06:00' }
        when /:i mst / { $offset = '-07:00' }
        when /:i pst / { $offset = '-08:00' }
        # daylight
        when /:i adt / { $offset = '-03:00' }
        when /:i edt / { $offset = '-04:00' }
        when /:i cdt / { $offset = '-05:00' }
        when /:i mdt / { $offset = '-06:00' }
        when /:i pdt / { $offset = '-07:00' }
    }

    $offset ~~ s/\:00// if $basic;

    return $offset;
} # time-zone-offset-us

sub time-parse(Str:D $s) is export(:time-parse) {
    # assumed to be in extended ISO 8601 format (with ':' and '-');

=begin pod
Date and time expressed according to ISO 8601:
  Date:	                          2016-11-10
  Combined date and time in UTC:  2016-11-10T16:31:40+00:00
                                  2016-11-10T16:31:40Z
                                  20161110T163140Z
  Week:	                          2016-W45
  Date with week number:	  2016-W45-4
  Date without year:	          --11-10
  Ordinal date:	                  2016-315
=end pod
    # just a simple test for now:
    if $s !~~ / <[:-]>+ / {
        die "FATAL:  Time string '$s' is not in ISO 8601 extended format";
    }

    # separate date and time parts


} # time-parse
