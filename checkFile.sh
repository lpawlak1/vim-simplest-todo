#!/bin/bash

touch tod.md
chmod +x bin/checkFile
./bin/checkFile
cat tod.md > todo.md
rm tod.md
exit 0