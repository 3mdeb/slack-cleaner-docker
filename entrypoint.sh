#!/bin/bash -x

function error {
    echo "$1"
    exit 1
}

function errorCheck {
    code=$?
    if [ $code -ne 0 ]; then
	error "$1"
    fi
}

function usage {
    echo "Usage:"
    echo "SLACK_TOKEN=<SECRET_TOKEN> ${0} BEFORE_DATE"
    echo "Example: SLACK_TOKEN=<SECRET_TOKEN> ${0} 20180530"
}

BEFORE_DATE="${1}"
readonly EXPECTED_SUCCESS_STRING="0 file(s) cleaned."

[ -z "$SLACK_TOKEN" ] && usage && error "\"SLACK_TOKEN\" is not set"
[ $# -ne 1 ] && usage && error "Invalid number of arguments"
[ -z "BEFORE_DATE" ] && usage && error "\"BEFORE_DATE\" not given"

# date sanity checks
YEAR=${BEFORE_DATE:0:4}
# #0 to strip leading 0's
MONTH=${BEFORE_DATE:4:2}
MONTH=${MONTH#0}
DAY=${BEFORE_DATE:6:2}
DAY=${DAY#0}

echo "Provided date: year: $YEAR month: $MONTH day: $DAY"

[ $YEAR -gt 2050 ] && error "Year: \"$YEAR\" greater than 2050"
[ $YEAR -lt 2010 ] && error "Year: \"$YEAR\" less than 2010"
[ $MONTH -gt 12 ] && error "Month: \"$MONTH\" greater than 12"
[ $DAY -gt 31 ] && error "Day: \"$DAY\" greater than 31"

# Backup all files to the current working directory. It creates offset.txt file
# to avoid duplicate downloads later.
python slack-downloader.py
errorCheck "Backup failed"

# sometimes we need one more iteration of cleaning to actually delete all the
# files we want
for i in {1..5}
do
    echo "Cleaning iteration: #$i"
    # FIXME: Any variation of this check (=~, = *string*, case *strin*) works
    # for me manually but not in this script in container.
    OUTPUT_STRING=$(slack-cleaner --token $SLACK_TOKEN --file --user '*' --before $BEFORE_DATE --perform 2>&1)
    OUTPUT_STRING="$(echo $OUTPUT_STRING | xargs)"
    if echo "$OUTPUT_STRING" | grep "$EXPECTED_SUCCESS_STRING"; then
        echo "Desired files deleted successfully"
        exit 0
    fi
done

echo "Some files remain not removed after 5 cleaning iterations"
