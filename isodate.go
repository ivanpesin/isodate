package main

import (
	"bufio"
	"bytes"
	"flag"
	"fmt"
	"os"
	"strconv"
	"strings"
	"time"
)

var t = time.Now()
var wyr, wnr = t.UTC().ISOWeek()
var dow = t.UTC().Weekday()

var tsInfo = make(map[string]string)

var utc = flag.Bool("u", false, "show UTC timestamp")
var loc = flag.Bool("l", false, "show local timestamp")
var epoch = flag.Bool("s", false, "show unix epoch")
var week = flag.Bool("w", false, "show week number")
var verbose = flag.Bool("v", false, "show verbose output")
var replace = flag.Bool("r", false, "replace epoch with timestamp")
var delim = flag.String("d", ",", "delimeter for epoch replace")
var fno = flag.Int("f", 1, "field number for epoch replace")

func formatTimeStamps() {
	tsInfo["utc"] = t.UTC().Format("2006-01-02T15:04:05Z")
	tsInfo["loc"] = t.Format("2006-01-02T15:04:05-0700")
	tsInfo["epoch"] = fmt.Sprintf("%d", t.Unix())
	tsInfo["week"] = fmt.Sprintf("%d-W%02d-%d", wyr, wnr, dow)
	tsInfo["offset"] = t.Format("-0700")
	tsInfo["tz"] = t.Format("MST")
}

func showOneline() {
	buf := bytes.NewBufferString("")
	switch {
	case *utc:
		buf.WriteString(tsInfo["utc"])
	case *loc:
		buf.WriteString(tsInfo["loc"])
	case *epoch:
		buf.WriteString(tsInfo["epoch"])
	case *week:
		buf.WriteString(tsInfo["week"])
	default:
		buf.WriteString(fmt.Sprintf("%s %s %s %s %s",
			tsInfo["utc"],
			tsInfo["loc"],
			tsInfo["epoch"],
			tsInfo["tz"],
			tsInfo["week"]))
	}
	buf.WriteString("\n")
	fmt.Printf("%s", buf)
}

func showVerbose() {
	buf := bytes.NewBufferString("")
	buf.WriteString(fmt.Sprintf("   UTC: %s\n", tsInfo["utc"]))
	buf.WriteString(fmt.Sprintf(" Local: %s\n", tsInfo["loc"]))
	buf.WriteString(fmt.Sprintf(" Epoch: %s\n", tsInfo["epoch"]))
	buf.WriteString(fmt.Sprintf("Offset: %s\n", tsInfo["offset"]))
	buf.WriteString(fmt.Sprintf("    TZ: %s\n", tsInfo["tz"]))
	buf.WriteString(fmt.Sprintf("  Week: %s\n", tsInfo["week"]))
	fmt.Printf("%s", buf)
}

func replaceEpoch() {

	s := bufio.NewScanner(os.Stdin)
	lno := 0
	cacheEpoch := ""
	cacheTS := ""

	for s.Scan() {
		lno++
		line := s.Text()
		f := strings.Split(line, *delim)
		if *fno > len(f) {
			fmt.Fprintf(os.Stderr, "Error: line %d has only %d fields < %d\n", lno, len(f), *fno)
			continue
		}

		if f[*fno-1] != cacheEpoch {
			ts, err := strconv.ParseInt(f[*fno-1], 10, 64)
			if err != nil {
				fmt.Fprintf(os.Stderr, "Error: line %d: expect epoch, but found: %s\n", lno, f[*fno-1])
				continue
			}

			cacheEpoch = f[*fno-1]
			if *loc {
				cacheTS = time.Unix(ts, 0).Format("2006-01-02T15:04:05-0700")
			} else {
				cacheTS = time.Unix(ts, 0).UTC().Format("2006-01-02T15:04:05Z")
			}
		}
		f[*fno-1] = cacheTS

		fmt.Printf("%s\n", strings.Join(f, *delim))
	}
}

func main() {

	flag.Parse()

	// replace epoch in input
	if *replace {
		replaceEpoch()
		os.Exit(0)
	}

	// if epoch ts specified on cmd line
	if len(flag.Args()) > 0 {
		s, err := strconv.ParseInt(flag.Arg(0), 10, 64)
		if err != nil {
			fmt.Printf("epoch timestamp expected: %s\n", err.Error())
			os.Exit(1)
		}
		t = time.Unix(s, 0)
		wyr, wnr = t.UTC().ISOWeek()
		dow = t.UTC().Weekday()
	}
	if dow == 0 {
		dow = 7
	}

	// create all timestamps
	formatTimeStamps()

	// display in requested format
	if *verbose {
		showVerbose()
		os.Exit(0)
	}

	showOneline()

}
