#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "rich>=13",
# ]
# ///
"""
task_runner.py — Interactive task runner that parses TASKS.md.

Usage:
  uv run scripts/task_runner.py           # interactive TUI
  uv run scripts/task_runner.py --auto    # run tasks with matching scripts
  uv run scripts/task_runner.py --list    # list pending tasks only
  uv run scripts/task_runner.py --done T6 # mark section T6 complete
"""

import argparse
import re
import subprocess
import sys
from pathlib import Path
from typing import NamedTuple

from rich.console import Console
from rich.panel import Panel
from rich.prompt import Confirm, Prompt
from rich.table import Table
from rich import box

ROOT      = Path(__file__).parent.parent
TASKS_MD  = ROOT / "TASKS.md"
SCRIPTS   = ROOT / "scripts"

console = Console()

# ── Data types ────────────────────────────────────────────────────────────────

class Task(NamedTuple):
    section: str
    text:    str
    done:    bool
    line_no: int

# ── Script mapping — task text fragment → script command ─────────────────────

_AUTO_MAP = {
    "HYG":                  "uv run scripts/build_star_catalog.py",
    "bright_stars.json":    "uv run scripts/build_star_catalog.py",
    "star catalog":         "uv run scripts/build_star_catalog.py",
    "APOD":                 "uv run scripts/fetch_apis.py --apod",
    "Horizons":             "uv run scripts/fetch_apis.py --horizons --profile kiliaan",
    "IERS":                 "uv run scripts/fetch_apis.py --iers",
    "delta_t":              "uv run scripts/fetch_apis.py --iers",
    "flutter pub get":      "flutter pub get",
    "flutter build linux":  "flutter build linux --release",
    "build linux":          "flutter build linux --release",
    "penta-mind":           "uv run scripts/penta_mind.py --no-api --profile paulien --query test",
}

# ── Parser ────────────────────────────────────────────────────────────────────

def parse_tasks(path: Path) -> list[Task]:
    tasks = []
    current_section = "General"
    with path.open() as f:
        for i, line in enumerate(f, 1):
            # Section headers
            m_sec = re.match(r"^#{1,3}\s+(T\d+|T\w+)\s*—\s*(.+)", line)
            if m_sec:
                current_section = f"{m_sec.group(1)} — {m_sec.group(2).strip()}"
            elif re.match(r"^#{1,3}\s+", line):
                heading = re.sub(r"^#{1,3}\s+", "", line).strip()
                if heading and not heading.startswith("✅") and not heading.startswith("📋"):
                    current_section = heading

            # Task items
            m_done  = re.match(r"^\s*-\s+\[x\]\s+(.+)", line)
            m_todo  = re.match(r"^\s*-\s+\[ \]\s+(.+)", line)
            if m_todo:
                tasks.append(Task(current_section, m_todo.group(1).strip(), False, i))
            elif m_done:
                tasks.append(Task(current_section, m_done.group(1).strip(), True, i))
    return tasks

def mark_done(path: Path, line_no: int) -> None:
    lines = path.read_text().splitlines(keepends=True)
    if 1 <= line_no <= len(lines):
        lines[line_no - 1] = lines[line_no - 1].replace("- [ ]", "- [x]", 1)
    path.write_text("".join(lines))

def find_auto_command(task_text: str) -> str | None:
    for keyword, cmd in _AUTO_MAP.items():
        if keyword.lower() in task_text.lower():
            return cmd
    return None

# ── Display ───────────────────────────────────────────────────────────────────

def show_tasks(tasks: list[Task], show_done: bool = False) -> None:
    pending = [t for t in tasks if not t.done]
    done    = [t for t in tasks if t.done]

    t = Table(box=box.SIMPLE_HEAVY, header_style="bold magenta",
              title=f"[bold]TASKS.md — {len(pending)} pending, {len(done)} done[/bold]")
    t.add_column("#",       style="dim",            width=4)
    t.add_column("Section", style="cyan",           width=26)
    t.add_column("Task",                            min_width=40)
    t.add_column("Auto?",   style="yellow",         width=8)

    for i, task in enumerate(pending, 1):
        auto = "✓ yes" if find_auto_command(task.text) else "—"
        t.add_row(str(i), task.section[:25], task.text[:70], auto)

    console.print(t)

    if show_done and done:
        console.print(f"\n[dim]✓ {len(done)} completed tasks hidden — pass --show-done to see them.[/dim]")

# ── Interactive mode ──────────────────────────────────────────────────────────

def interactive(tasks: list[Task]) -> None:
    pending = [t for t in tasks if not t.done]
    if not pending:
        console.print("[green]✓ All tasks in TASKS.md are complete![/green]")
        return

    show_tasks(tasks)

    console.print("\n[bold]Options:[/bold]  [cyan]run <#>[/cyan]  [yellow]done <#>[/yellow]  "
                  "[magenta]auto[/magenta]  [dim]quit[/dim]\n")

    while True:
        cmd = Prompt.ask("[bold]task>[/bold]", default="quit")
        if cmd in ("q", "quit", "exit"):
            break

        parts = cmd.strip().split()
        action = parts[0].lower() if parts else ""
        idx    = int(parts[1]) - 1 if len(parts) > 1 and parts[1].isdigit() else None

        if action == "auto":
            run_auto(pending)
        elif action == "run" and idx is not None and 0 <= idx < len(pending):
            run_one(pending[idx])
        elif action == "done" and idx is not None and 0 <= idx < len(pending):
            mark_done(TASKS_MD, pending[idx].line_no)
            console.print(f"[green]✓ Marked done: {pending[idx].text[:60]}[/green]")
            pending.pop(idx)
        elif action == "list":
            show_tasks(tasks)
        else:
            console.print("[dim]Commands: run <#>  done <#>  auto  list  quit[/dim]")

# ── Auto mode ─────────────────────────────────────────────────────────────────

def run_auto(pending: list[Task]) -> None:
    automatable = [(t, find_auto_command(t.text)) for t in pending if find_auto_command(t.text)]
    if not automatable:
        console.print("[yellow]No pending tasks have matching automation scripts.[/yellow]")
        return

    console.print(f"\n[bold cyan]Found {len(automatable)} auto-runnable tasks:[/bold cyan]")
    for task, cmd in automatable:
        console.print(f"  [dim]•[/dim] {task.text[:55]}")
        console.print(f"    [yellow]→ {cmd}[/yellow]")

    if not Confirm.ask("\nRun all of these?"):
        return

    for task, cmd in automatable:
        run_one(task, cmd)

def run_one(task: Task, cmd: str | None = None) -> None:
    cmd = cmd or find_auto_command(task.text)
    if not cmd:
        console.print(f"[red]No automation command for: {task.text[:60]}[/red]")
        return

    console.print(Panel(f"[bold cyan]{task.text}[/bold cyan]\n[yellow]$ {cmd}[/yellow]",
                        title="Running", border_style="cyan"))
    result = subprocess.run(cmd, shell=True, cwd=ROOT)
    if result.returncode == 0:
        if Confirm.ask(f"Mark as done in TASKS.md?", default=True):
            mark_done(TASKS_MD, task.line_no)
            console.print("[green]✓ Marked done[/green]")
    else:
        console.print(f"[red]✗ Command exited with code {result.returncode}[/red]")

# ── CLI ───────────────────────────────────────────────────────────────────────

def main() -> None:
    parser = argparse.ArgumentParser(description="Paulien's Sky task runner")
    parser.add_argument("--list",      action="store_true", help="List pending tasks")
    parser.add_argument("--auto",      action="store_true", help="Run all automatable tasks")
    parser.add_argument("--show-done", action="store_true", help="Include done tasks in listing")
    parser.add_argument("--done",      metavar="SECTION",   help="Mark a section done by prefix")
    args = parser.parse_args()

    if not TASKS_MD.exists():
        console.print(f"[red]TASKS.md not found at {TASKS_MD}[/red]")
        sys.exit(1)

    tasks = parse_tasks(TASKS_MD)

    if args.done:
        prefix = args.done.upper()
        matched = [t for t in tasks if not t.done and t.section.upper().startswith(prefix)]
        for t in matched:
            mark_done(TASKS_MD, t.line_no)
        console.print(f"[green]✓ Marked {len(matched)} tasks done matching '{prefix}'[/green]")
        return

    if args.list:
        show_tasks(tasks, show_done=args.show_done)
        return

    if args.auto:
        pending = [t for t in tasks if not t.done]
        run_auto(pending)
        return

    interactive(tasks)


if __name__ == "__main__":
    main()
