#!/usr/bin/env python
import json
import subprocess
import sys

data = {}

try:
    result = subprocess.run(
        ["khal", "list", "now", "1d", "--format", "{title} {start-time}"],
        capture_output=True,
        text=True,
        timeout=5
    )
    output = result.stdout
    lines = output.split("\n")
    new_lines = []

    for line in lines:
        if len(line) and line[0].isalpha():
            line = "\n"+line
        new_lines.append(line)

    output = "".join(new_lines).strip()

    if "Today" in output and len(output.split('\n')) >= 3:
        data['text'] = output.split('\n')[1] + ' | ' + output.split('\n')[2]
    else:
        data['text'] = ""

    data['tooltip'] = output if output else "No events"

except subprocess.TimeoutExpired:
    data['text'] = ""
    data['tooltip'] = "khal timeout"
except FileNotFoundError:
    data['text'] = ""
    data['tooltip'] = "khal not found"
except Exception as e:
    data['text'] = ""
    data['tooltip'] = f"Error: {str(e)}"

print(json.dumps(data))
