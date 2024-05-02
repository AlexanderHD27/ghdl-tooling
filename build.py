#!/usr/bin/python3
from jsonschema import validate
from typing import TextIO
import subprocess
import argparse
import os
import json
import time
import sys

COLOR_RED='\033[0;31m'
COLOR_YELLOW='\033[1;33m'
COLOR_GREEN='\033[0;32m'
COLOR_BLUE='\033[0;34m'
COLOR_NC='\033[0m'

CONFIG_SCHEMA = {
    "type": "object",
    "required": ["targets"],
    "properties": {
        "targets": {
            "type": "object",
            "patternProperties": {
                ".{1,}": {
                    "type": "object",
                    "required": ["src", "exec", "ieee", "std"],
                    "properties": {
                        "src": {
                            "type": "array",
                            "items": { "type": "string" }
                        },
                        "ieee": {"type": "string"},
                        "std": {"type": "string"},
                        "exec": {
                            "type": "array",
                            "items": {
                                "type": "object",
                                "required": ["name", "top"],
                                "properties": {
                                    "name": {"type": "string"},
                                    "top": {"type": "string"},
                                    "stop-time": {"type": "string"},
                                    "arch": {"type": "string"},
                                    "args": {"type": "array", "items": {"type": "string"}}
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

parser = argparse.ArgumentParser(
    prog='build',
    description='Builds & Runs GHDL Files',
    epilog='')

parser.add_argument('target') 
parser.add_argument('config_file') 
args = parser.parse_args()

TARGET = args.target

with open(args.config_file) as f:
    config = json.loads(f.read())

validate(config, CONFIG_SCHEMA)

#subparsers = parser.add_subparsers(help="sub-command help")

def split_files_and_folders(paths: list[str], basedir: str) -> tuple[list[str], list[str]]:
    basedir = os.path.abspath(basedir)
    dirs = []
    files = []
    not_found = []

    for p in paths:
        p = os.path.join(basedir, p)

        if os.path.isdir(p):
            dirs.append(p)
        elif os.path.isfile(p):
            files.append(p)
        else:
            not_found.append(p)

    return (dirs, files, not_found)

def create_dir_if_not_exits(dir: str):
    dir = os.path.abspath(dir)
    if not os.path.isdir(dir):
        os.mkdir(dir)


def stringify_time(duration_ns: int):
    suffix = "ns"

    INTERVALS = [
        (3600 * 10**9, "h"),
        (60 * 10**9, "min"),
        (10**9, "s"),
        (10**6, "ms"),
        (10**3, "µs"),
    ]

    for i in INTERVALS:
        if duration_ns > i[0]:
            suffix = i[1]
            duration_ns /= i[0]
            break

    return "{:3.03f} {}".format(duration_ns,suffix.ljust(3))


GHDL = "ghdl"

def print_log(files: list[TextIO], prefix: str, *args: list[any], color: str = "", end="\n", flush=True):
    components: list[str] = []

    for i in args:
        if type(i) is str:
            components.append(i)
        else:
            components.append(str(i))

    s = f"[{prefix}] " + " ".join(components)

    for i in files:
        if (i == sys.stdout or i == sys.stderr) and color != "":
            s = color + s + COLOR_NC
            pass

        i.write(s + end)
        if flush:
            i.flush()
    

def ghdl_analyze(out_dir: str, analyze_path: list[str], std: str, ieee: str) -> bool:
    create_dir_if_not_exits(out_dir)

    analyze_dirs, analyze_files, not_found = split_files_and_folders(analyze_path, ".")

    print_log([sys.stdout], "ANALYZE", "Files for Analysis:")
    
    for i in analyze_files:
        print_log([sys.stdout], "ANALYZE", " - " + i)
    
    for i in analyze_dirs:
        print_log([sys.stdout], "ANALYZE", " - " + i)
        for j in os.listdir(i): 
            print_log([sys.stdout], "ANALYZE", "    - " + j)

    if len(not_found) > 0:
        print_log([sys.stdout], "ANALYZE", "")
        print_log([sys.stdout], "ANALYZE", "Missing Files/Folders", color=COLOR_RED)
        for i in not_found:
            print_log([sys.stdout], "ANALYZE", " - " + i)
        exit(-1)

    print_log([sys.stdout], "ANALYZE", "")

    analyze_dirs = list(map(lambda p: f"-P{p}", analyze_dirs))

    command = [GHDL, "-a", f"--workdir={out_dir}", f"--std={std}", f"--ieee={ieee}"] + analyze_dirs + analyze_files

    print("[ANALYZE]", " ".join(command))

    with subprocess.Popen(command) as proc:
        return_code = proc.wait()
        print(f"[ANALYZE] Exit code: {return_code}")

    return return_code == 0

def ghdl_elaborate(name: str, out_dir: str, work_dir: str, top: str, arch: str, std: str, ieee: str) -> str:
    create_dir_if_not_exits(out_dir)

    out_file_name = top
    if len(arch) > 0:
        out_file_name += "-" + arch
    out_file_name += ".out"

    out_file = os.path.join(os.path.abspath(out_dir), out_file_name)
    work_dir = os.path.abspath(work_dir)

    command = [
        GHDL, "-e", 
        "-o", f"{out_file}", f"--workdir={work_dir}",  
        f"--std={std}", f"--ieee={ieee}", top
    ] 
    if arch != "":
        command += [arch]

    print(f"[ELABORATE {name}] Unit: {out_file_name}")
    print(f"[ELABORATE {name}]", " ".join(command))

    with subprocess.Popen(command) as proc:
        return_code = proc.wait()
        print(f"[ELABORATE {name}] Exit code: {return_code}")

    if return_code:
        return ""
    else:
        return out_file

def ghdl_run(name: str, out_dir: str, file: str, args: list[str], stop_time: str) -> tuple[int, int, bool]:

    log_dir = os.path.abspath(os.path.join(out_dir, 'log'))
    create_dir_if_not_exits(log_dir)

    command = [
        file,
        f"--wave={os.path.join(log_dir, name + '.ghw')}",
        f"--vcd={os.path.join(log_dir, name + '.vcd')}",
        #f"--vcd=outfile.vcd",
        f"--fst={os.path.join(log_dir, name + '.fst')}",
    ]

    if stop_time != "":
        command += [f"--stop-time={stop_time}"]
    
    command += args

    with open(os.path.join(log_dir, name + ".log"), "w") as log_file:
        print_log([log_file, sys.stdout],
            f"RUN {name}", ' '.join(command))
        print_log([log_file, sys.stdout], f"RUN {name}", f"")

        error_count = 0
        warning_count = 0
        note_count = 0

        t0 = time.time_ns()
        try:
            with subprocess.Popen(command, shell=False, stdout=subprocess.PIPE) as proc:
                while line := proc.stdout.readline():
                    error_inline = (b"error" in line) or (b"failed" in line)
                    warning_inline = b"warning" in line
                    note_inline = b"note" in line

                    if error_inline:
                        color = COLOR_RED
                    elif warning_inline:
                        color = COLOR_YELLOW
                    else:
                        color = ""

                    print_log([log_file, sys.stdout],
                        f"RUN {name}", line.decode("utf-8")[:-1], color=color)
                    
                    error_count += 1 if error_inline else 0
                    warning_count += 1 if warning_inline else 0
                    note_count += 1 if note_inline else 0

                
                return_code = proc.wait()
        except KeyboardInterrupt:
            print_log([log_file, sys.stdout], f"RUN {name}", f"Terminated by Ctrl+C", color=COLOR_RED)
            error_count += 1
            return_code = -255
        t1 = time.time_ns()
                    
        print_log([log_file, sys.stdout], f"RUN {name}", f"")
        print_log([log_file, sys.stdout], f"RUN {name}", f"Exit code: {return_code}")
        print_log([log_file, sys.stdout], f"RUN {name}", f"({error_count} errors, {warning_count} warnings, {note_count} notes)")
        print_log([log_file, sys.stdout], f"RUN {name}", f"after {stringify_time(t1-t0)}")


    return return_code, t1-t0, (error_count == 0) and (warning_count == 0) and (return_code == 0)


target = config["targets"].get(TARGET)
name = TARGET

if target is None:
    print(f"Target '{TARGET}' does not exists!", file=sys.stderr)
    exit(1)

WORK_DIR = os.path.join("out", name)

# Analyze all
print()
print("Analysis (1/3)")
print()
if not ghdl_analyze(WORK_DIR, analyze_path=target["src"], std=target["std"], ieee=target["ieee"]):
    exit(1)

exec_state = {}

# Elaborate everything
print()
print("Elaboration (3/3)")
print()

for e in target["exec"]:
    file = ghdl_elaborate(e["name"], out_dir=os.path.join(WORK_DIR, "bin"), work_dir=WORK_DIR, top=e["top"], arch=e.get("arch") or "", std=target["std"], ieee=target["ieee"])
    if not file:
        exit()
    e["file"] = file

# Execute all
print()
print("Simulation (2/3)")
print()

for e in target["exec"]:
    code, t, error = ghdl_run(
        e["name"], 
        WORK_DIR, 
        e["file"], 
        e.get("args") or [], 
        e.get("stop-time") or ""
    )
    e["exit_code"] = code
    e["time"] = t
    e["error"] = error
    print()


# Find max name length
    
name_padding = max(max(map(lambda e: len(e["name"]), target["exec"])), 4)

print("Exec Summary:")
print()
print( " S | " + "name"[:name_padding].ljust(name_padding) + " | exit | exec time")
print("---+-" + "-"*name_padding + "-+------+-" + "-"*11)

for i in target["exec"]:
    res_symbol = (COLOR_GREEN + "✓" if i["error"] else COLOR_RED + "✖") + COLOR_NC
    print(" " + res_symbol + " | "
          + i["name"].ljust(name_padding) + " | "
          + str(i["exit_code"]).rjust(4) + " | " 
          + stringify_time(i["time"]).rjust(11))

print()