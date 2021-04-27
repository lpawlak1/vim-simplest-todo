marks = open("marks.md", "r")
out = open("todo.md", "w+")
in_ = open("tod.md", "r")
marks_list= marks.readline().split("|")
done_mark = marks_list[0].strip()
undone_mark = marks_list[1].strip()
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
