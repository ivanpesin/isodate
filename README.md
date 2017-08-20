# isodate

`isodate` -- print timestamps and convert epoch to human-readable form.

## Usage

    isodate [ -r [-d <delim>] [-f <fno>] [-l] | <selector> [<epoch>]]

### Replace mode

In this mode, `isodate` reads from `stdin`, replaces the epoch timestamp 
in specified position, and prints modified output to `stdout`. It is 
useful for reading logs that have timestamps as epoch.

By default, epoch timestamp is replaced with UTC timestamp, unless `-l` is 
specified.

```
    -r          replace mode.
    -d <delim>  use <delim> as a field separator. Default: ','
    -f <fno>    replace epoch timestamp in field <fno>. First field has
                number 1, which is also a default value.
    -l          replace with local timestamp instead of UTC timestamp.
```

### Timestamps mode

In this mode `isodate` prints timestamps for either current or provided time.
`isodate` supports following timestamps:

- `-u`, UTC time: `2017-08-20T17:52:48Z`
- `-l`, Local time: `2017-08-20T13:52:48-0400`
- `-e`, Epoch time: `1503251568`
- `-o`, Offset: `-0400`, always local
- `-z`, Timezone: `EDT`
- `-w`, ISO week: `2017-W33-7`, always UTC

Options are mutually exclusive. If no options are specified, `isodate` will
display all timestamps in one line, separated by space.

There is also `-v` option, to produce a verbose output, where each timestamp
is on a separate line.

By default, `isodate` displays timestamps for current time. It is also 
possible to specify epoch time for which to displat timestamps

## Examples:

### Replace mode
    $ cat log_with_epoch_ts.log | isodate -r -d, -f2
    $ cat log_with_epoch_ts.log | isodate -r -d, -f2 -l

### Timestamp mode

Show all timestamps in one line.

    $ isodate
    2017-08-20T17:52:48Z 2017-08-20T13:52:48-0400 1503251568 EDT 2017-W33-7

Show UTC only:

    $ isodate -u
    2017-08-20T17:53:24Z

Show local time for epoch time `1000000000`:

    $ isodate -l 1000000000
    2001-09-08T21:46:40-0400

Show verbose output:

    $ isodate -v
       UTC: 2017-08-20T18:08:09Z
     Local: 2017-08-20T14:08:09-0400
     Epoch: 1503252489
    Offset: -0400
        TZ: EDT