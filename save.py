marks = open("marks.md", "r")
out = open("todo.md", "w+")
in_ = open("tod.md", "r")
undone_mark = marks.readline().strip()
done_mark = marks.readline().strip()
marks.close()
for line in in_.readlines():
    if undone_mark in line:
        out.write("0\n")
        out.write(line[line.find("]")+1:])
    elif done_mark in line:
        out.write("1\n")
        out.write(line[line.find("]")+1:])
in_.close()
out.close()
