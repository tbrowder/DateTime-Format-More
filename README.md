# DateTime::Format::More

[![Build Status](https://travis-ci.org/tbrowder/DateTime-Format-More-Perl6.svg?branch=master)](https://travis-ci.org/tbrowder/DateTime-Format-More-Perl6)

This module assumes the user is on a system that has a local time zone defined (which of
course may be UTC).

Note that on Debian or other *nix systems there are several ways for system administrators
to set the system time zone for local time use (for instance, cron uses local time,
so it may be useful for administering remote systems to have all remote systems set
to either the administrator's time zone or the time zone of the physical host's
location, depending on needs).

One way is to define the TZ environment variable in the /etc/environment file.  In
the author's Debian hosts that entry looks like:

    TZ=America/Chicago

and that takes care of daylight savings time changes automatically, too.

On Windows systems...

And on Mac systems...


## References

- link to time zone info

Current module
[Misc::Utils](https://github.com/tbrowder/Misc-Utils-Perl6) will be
broken up into more domain-focused modules, one of which will be this
one.
