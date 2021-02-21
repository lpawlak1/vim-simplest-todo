#!/bin/bash

touch tod.md
./bin/checkFile
cat tod.md > todo.md
rm tod.md
exit 0