package main

import (
	"bytes"
	"flag"
	"fmt"
	"os"
	"strconv"
	"time"
)

var t = time.Now()
var _, wnr = t.ISOWeek()

var utc = flag.Bool("u", false, "show UTC timestamp")
var loc = flag.Bool("l", false, "show local timestamp")
var epoch = flag.Bool("s", false, "show unix epoch")
var week = flag.Bool("w", false, "show week number")
var verbose = flag.Bool("v", false, "show verbose output")
var delim = flag.String("d", ",", "show unix epoch")
var fno = flag.Int("f", 1, "show unix epoch")

func showOneline() {

	buf := bytes.NewBufferString("")
	switch {
	case *utc:
		buf.WriteString(t.UTC().Format("2006-01-02T15:04:05Z"))
	case *loc:
		buf.WriteString(t.Format("2006-01-02T15:04:05-0700"))
	case *epoch:
		buf.WriteString(fmt.Sprintf("%d", t.Unix()))
	case *week:
		buf.WriteString(fmt.Sprintf("W%02d", wnr))
	default:
		buf.WriteString(fmt.Sprintf("%s %s %d %s W%02d",
			t.UTC().Format("2006-01-02T15:04:05Z"),
			t.Format("2006-01-02T15:04:05-0700"),
			t.Unix(),
			t.Format("MST"),
			wnr))
	}
	buf.WriteString("\n")
	fmt.Printf("%s", buf)
}

func showVerbose() {
	buf := bytes.NewBufferString("")
	buf.WriteString(fmt.Sprintf("   UTC: %s\n", t.UTC().Format("2006-01-02T15:04:05Z")))
	buf.WriteString(fmt.Sprintf(" Local: %s\n", t.Format("2006-01-02T15:04:05-0700")))
	buf.WriteString(fmt.Sprintf(" Epoch: %d\n", t.Unix()))
	buf.WriteString(fmt.Sprintf("Offset: %s\n", t.Format("-0700")))
	buf.WriteString(fmt.Sprintf("    TZ: %s\n", t.Format("MST")))
	buf.WriteString(fmt.Sprintf("  Week: %d\n", wnr))
	fmt.Printf("%s", buf)
}

func main() {

	flag.Parse()

	if len(flag.Args()) > 0 {
		s, err := strconv.ParseInt(flag.Arg(0), 10, 64)
		if err != nil {
			fmt.Printf("epoch timestamp expected: %s\n", err.Error())
			os.Exit(1)
		}
		t = time.Unix(s, 0)
		_, wnr = t.ISOWeek()
	}

	if *verbose {
		showVerbose()
		os.Exit(0)
	}

	showOneline()

}
