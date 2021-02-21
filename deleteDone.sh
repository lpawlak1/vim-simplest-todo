#!/bin/bash

touch tod.md
chmod +x bin/deleteDone
./bin/deleteDone
cat tod.md > todo.md
rm tod.md
exit 0