#!/usr/bin/env python
import json
import subprocess

data = {}
output = subprocess.check_output("khal list now 1d --format '{title} {start-time}'", shell=True).decode("utf-8")
lines = output.split("\n")
new_lines = []

for line in lines:
    if len(line) and line[0].isalpha():
        line = "\n"+line
    new_lines.append(line)

output = "".join(new_lines).strip()

if "Today" in output:
    data['text'] = " " + output.split('\n')[1] + ' | ' + output.split('\n')[2]
else:
    data['text'] = " "

data['tooltip'] = output
print(json.dumps(data))
