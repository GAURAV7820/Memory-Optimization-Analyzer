#!/bin/bash

set -euo pipefail

flex smartmemai.l
gcc lex.yy.c -o smartmemai

./smartmemai
