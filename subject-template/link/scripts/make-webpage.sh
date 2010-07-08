#!/bin/bash
#
# make-webpage.sh creates a webpage summarizing this subject's analysis
# original author: mason simon (mgsimon@princeton.edu)
# this script was provided by NeuroPipe. modify it to suit your needs

set -e  # abort immediately on error

source globals.sh


# header
echo "
<html>
<head>
<title>$SUBJ</title>
</head>
<body>"

# link to QA results
echo "<a href='$QA_DIR/index.html'>QA</a><br/>"

# footer
echo "
</body>
</html>"
