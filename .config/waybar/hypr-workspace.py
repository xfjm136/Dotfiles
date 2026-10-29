#!/usr/bin/env python3
"""Feed one Waybar workspace button using Hyprland's event socket."""
import json
import os
from pathlib import Path
import socket
import subprocess
import sys
import time


def emit(number):
    result = subprocess.run(
        ['hyprctl', '-j', 'activeworkspace'],
        check=True, capture_output=True, text=True, timeout=3,
    )
    workspace = json.loads(result.stdout)
    active = str(workspace.get('id')) == number
    print(json.dumps({
        'text': number,
        'tooltip': '工作区 ' + number,
        'class': 'active' if active else 'inactive',
    }, ensure_ascii=False), flush=True)


def main():
    number = sys.argv[1]
    if number not in ('1', '2', '3', '4', '5'):
        sys.exit('Expected workspace number 1–5')
    signature = os.environ.get('HYPRLAND_INSTANCE_SIGNATURE')
    if not signature:
        sys.exit('HYPRLAND_INSTANCE_SIGNATURE is not set')
    address = Path(os.environ.get('XDG_RUNTIME_DIR', '/run/user/' + str(os.getuid()))) / 'hypr' / signature / '.socket2.sock'
    while True:
        try:
            with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as connection:
                connection.connect(str(address))
                emit(number)
                with connection.makefile('r') as events:
                    for line in events:
                        event = line.split('>>', 1)[0]
                        if event in ('workspace', 'workspacev2', 'focusedmon', 'focusedmonv2'):
                            emit(number)
        except (OSError, subprocess.SubprocessError, ValueError) as error:
            print('Workspace status: ' + str(error), file=sys.stderr, flush=True)
        time.sleep(2)


if __name__ == '__main__':
    try:
        main()
    except (BrokenPipeError, KeyboardInterrupt):
        pass
