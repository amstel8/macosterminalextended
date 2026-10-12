"""Exercise actual ZLE selection in a PTY without changing the user's clipboard."""
import os
from pathlib import Path
import pty
import select
import shlex
import subprocess
import tempfile
import time

root = Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix="extended-terminal-zle-") as directory:
    state = Path(directory) / "state"
    master, slave = pty.openpty()
    env = dict(os.environ, TERM="xterm-256color", TERM_PROGRAM="Apple_Terminal", ET_TEST_STATE=str(state))
    child = subprocess.Popen(["/bin/zsh", "-f"], stdin=slave, stdout=slave, stderr=slave, env=env)
    os.close(slave)

    def drain(duration=0.2):
        until = time.monotonic() + duration
        while time.monotonic() < until:
            if select.select([master], [], [], 0.02)[0]:
                os.read(master, 65536)

    def snapshot(keys, expected_cursor, expected_mark=None, expected_active=None):
        state.unlink(missing_ok=True)
        os.write(master, keys + b"\x1b[99~")
        until = time.monotonic() + 3
        while time.monotonic() < until:
            drain(0.03)
            if state.exists():
                fields = state.read_text().rstrip("\n").split("|", 3)
                if len(fields) == 4:
                    cursor, mark, active = map(int, fields[:3])
                    assert cursor == expected_cursor, (keys, fields)
                    assert expected_mark is None or mark == expected_mark, (keys, fields)
                    assert expected_active is None or active == expected_active, (keys, fields)
                    assert fields[3] == "alpha beta gamma", fields
                    return
        raise AssertionError("ZLE snapshot timed out")

    try:
        drain()
        source = shlex.quote(str(root / "Resources/extended-terminal.zsh"))
        setup = (
            "PS1='ET> '; source " + source + "; "
            "function extended-terminal::enabled() { [[ $1 != copyEnabled ]]; }; "
            "function et-test-snapshot() { print -r -- \"$CURSOR|$MARK|$REGION_ACTIVE|$BUFFER\" > \"$ET_TEST_STATE\"; }; "
            "zle -N et-test-snapshot; "
            "for m in emacs viins shift-select; do bindkey -M $m $'\\e[99~' et-test-snapshot; done\n"
        )
        os.write(master, setup.encode())
        drain(0.5)
        os.write(master, b"alpha beta gamma")
        drain()
        snapshot(b"\x1b[1;4D", 11, 16, 1)
        snapshot(b"\x1b[1;4D", 6, 16, 1)
        snapshot(b"\x1b[1;6D", 0, 16, 1)
        snapshot(b"\x1b[1;4C", 6, 16, 1)
        snapshot(b"\x1b[1;6C", 16, 16, 1)
        snapshot(b"\x01", 0, expected_active=0)
        snapshot(b"\x05", 16, expected_active=0)
        print("ZLE integration: word selection, extension, shrinkage, line edges and deselection passed")
    finally:
        child.terminate()
        try:
            child.wait(timeout=1)
        except subprocess.TimeoutExpired:
            child.kill()
            child.wait(timeout=3)
        os.close(master)
