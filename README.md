# isodate

Utility for printing ISO timestamps and converting from epoch

## Examples

```
$ isodate                   # oneliner with timestamps 
2017-08-18T04:14:01Z 2017-08-18T00:14:01-0400 1503029641 EDT 2017-W33-5
$ isodate -v                # verbose output
   UTC: 2017-08-18T04:14:52Z
 Local: 2017-08-18T00:14:52-0400
 Epoch: 1503029692
Offset: -0400
    TZ: EDT
  Week: 2017-W33-5
$ isodate -v 1483228800     # verbose output, convert epoch to human-readable
   UTC: 2017-01-01T00:00:00Z
 Local: 2016-12-31T19:00:00-0500
 Epoch: 1483228800
Offset: -0500
    TZ: EST
  Week: 2016-W52-7
```
