#!/usr/bin/env bash
# Automated tests for Continuum hook scripts
# Run: bash tests/test-hooks.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PASS=0
FAIL=0

# Colors (if terminal supports them)
RED=$(tput setaf 1 2>/dev/null || echo "")
GREEN=$(tput setaf 2 2>/dev/null || echo "")
RESET=$(tput sgr0 2>/dev/null || echo "")

pass() { PASS=$((PASS + 1)); echo "  ${GREEN}PASS${RESET}: $1"; }
fail() { FAIL=$((FAIL + 1)); echo "  ${RED}FAIL${RESET}: $1"; }

setup_project() {
  TMPDIR=$(mktemp -d)
  mkdir -p "$TMPDIR/.lifecycle/plans" "$TMPDIR/.lifecycle/checkpoints"
  cd "$TMPDIR" && git init --quiet
  git -C "$TMPDIR" config user.email "test@test.com"
  git -C "$TMPDIR" config user.name "Test"
  git -C "$TMPDIR" commit --allow-empty -m "init" --quiet
  echo "$TMPDIR"
}

cleanup() {
  rm -rf "$1"
}

# ============================================================
echo "=== track-file-change.sh ==="
# ============================================================

# Clean slate
rm -f ~/.claude/sessions/active-changes.log

echo '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/foo.txt"},"cwd":"/tmp","session_id":"s001"}' \
  | bash "$ROOT_DIR/scripts/track-file-change.sh"

if grep -q "SESSION cwd=/tmp sid=s001" ~/.claude/sessions/active-changes.log 2>/dev/null; then
  pass "creates session header with cwd and sid"
else
  fail "creates session header with cwd and sid"
fi

if grep -q "Edit foo.txt" ~/.claude/sessions/active-changes.log 2>/dev/null; then
  pass "logs Edit with relative file path"
else
  fail "logs Edit with relative file path"
fi

# Second edit appends to same log
echo '{"tool_name":"Write","tool_input":{"file_path":"/tmp/bar.txt"},"cwd":"/tmp","session_id":"s001"}' \
  | bash "$ROOT_DIR/scripts/track-file-change.sh"

LINES=$(wc -l < ~/.claude/sessions/active-changes.log)
if [ "$LINES" -eq 3 ]; then
  pass "appends to existing log (3 lines: header + 2 edits)"
else
  fail "appends to existing log (expected 3 lines, got $LINES)"
fi

# Missing file_path exits silently
echo '{"tool_name":"Edit","tool_input":{},"cwd":"/tmp","session_id":"s001"}' \
  | bash "$ROOT_DIR/scripts/track-file-change.sh"

LINES_AFTER=$(wc -l < ~/.claude/sessions/active-changes.log)
if [ "$LINES_AFTER" -eq 3 ]; then
  pass "ignores events with missing file_path"
else
  fail "ignores events with missing file_path (expected 3 lines, got $LINES_AFTER)"
fi

rm -f ~/.claude/sessions/active-changes.log

# ============================================================
echo ""
echo "=== track-commit.sh ==="
# ============================================================

PROJ=$(setup_project)

# Create a log first (track-commit requires existing log)
echo "# SESSION cwd=$PROJ sid=test started=2026-01-01T00:00:00Z" > ~/.claude/sessions/active-changes.log

# Make a real commit
echo "hello" > "$PROJ/test.txt"
git -C "$PROJ" add test.txt
git -C "$PROJ" commit -m "test commit" --quiet

echo "{\"cwd\":\"$PROJ\"}" | bash "$ROOT_DIR/scripts/track-commit.sh"

if grep -q "COMMIT.*test commit" ~/.claude/sessions/active-changes.log 2>/dev/null; then
  pass "logs commit hash and message"
else
  fail "logs commit hash and message"
fi

rm -f ~/.claude/sessions/active-changes.log
cleanup "$PROJ"

# No log = silent exit
echo '{"cwd":"/tmp"}' | bash "$ROOT_DIR/scripts/track-commit.sh"
pass "exits silently when no active log exists"

# ============================================================
echo ""
echo "=== auto-checkpoint.sh ==="
# ============================================================

PROJ=$(setup_project)

cat > "$PROJ/.lifecycle/plans/auth-progress.md" << 'EOF'
[x] Task 1 — setup JWT library
[x] Task 2 — create auth middleware
[ ] Task 3 — add refresh token endpoint
[ ] Task 4 — integration tests
EOF

echo "{\"cwd\":\"$PROJ\"}" | bash "$ROOT_DIR/scripts/auto-checkpoint.sh"

CKPT="$PROJ/.lifecycle/checkpoints/auth-checkpoint.md"
if [ -f "$CKPT" ]; then
  pass "creates checkpoint file"
else
  fail "creates checkpoint file"
fi

if grep -q "2/4 tasks complete" "$CKPT" 2>/dev/null; then
  pass "reports correct progress (2/4)"
else
  fail "reports correct progress (2/4)"
fi

if grep -q "Task 3 — add refresh token endpoint" "$CKPT" 2>/dev/null; then
  pass "identifies next task"
else
  fail "identifies next task"
fi

ACTIVITY="$PROJ/.lifecycle/activity.md"
if [ -f "$ACTIVITY" ]; then
  pass "creates activity.md"
else
  fail "creates activity.md"
fi

if grep -q "auth — 2/4 tasks" "$ACTIVITY" 2>/dev/null; then
  pass "activity log contains session summary"
else
  fail "activity log contains session summary"
fi

# Run again — should append second entry
sleep 1
echo "{\"cwd\":\"$PROJ\"}" | bash "$ROOT_DIR/scripts/auto-checkpoint.sh"

ENTRY_COUNT=$(grep -c "^- \[" "$ACTIVITY" 2>/dev/null || echo 0)
if [ "$ENTRY_COUNT" -eq 2 ]; then
  pass "activity log appends entries (2 after 2 runs)"
else
  fail "activity log appends entries (expected 2, got $ENTRY_COUNT)"
fi

cleanup "$PROJ"

# No .lifecycle = silent exit
PROJ2=$(mktemp -d)
echo "{\"cwd\":\"$PROJ2\"}" | bash "$ROOT_DIR/scripts/auto-checkpoint.sh"
pass "exits silently without .lifecycle/"
rm -rf "$PROJ2"

# No active progress = silent exit
PROJ3=$(setup_project)
echo "{\"cwd\":\"$PROJ3\"}" | bash "$ROOT_DIR/scripts/auto-checkpoint.sh"
if [ ! -f "$PROJ3/.lifecycle/checkpoints/"*-checkpoint.md 2>/dev/null ]; then
  pass "exits silently without active progress file"
else
  fail "exits silently without active progress file"
fi
cleanup "$PROJ3"

# ============================================================
echo ""
echo "=== detect-active-work.sh ==="
# ============================================================

PROJ=$(setup_project)

cat > "$PROJ/.lifecycle/plans/api-progress.md" << 'EOF'
[x] Task 1 — create endpoints
[ ] Task 2 — add validation
[ ] Task 3 — write tests
EOF

OUTPUT=$(echo "{\"cwd\":\"$PROJ\"}" | bash "$ROOT_DIR/scripts/detect-active-work.sh")

if echo "$OUTPUT" | grep -q "Active work detected"; then
  pass "detects active work"
else
  fail "detects active work"
fi

if echo "$OUTPUT" | grep -q "api — 1/3 tasks done"; then
  pass "shows correct progress"
else
  fail "shows correct progress"
fi

if echo "$OUTPUT" | grep -q "/resume"; then
  pass "prompts user to /resume"
else
  fail "prompts user to /resume"
fi

cleanup "$PROJ"

# No .lifecycle = silent exit
PROJ2=$(mktemp -d)
OUTPUT2=$(echo "{\"cwd\":\"$PROJ2\"}" | bash "$ROOT_DIR/scripts/detect-active-work.sh")
if [ -z "$OUTPUT2" ]; then
  pass "silent exit without .lifecycle/"
else
  fail "silent exit without .lifecycle/ (got output: $OUTPUT2)"
fi
rm -rf "$PROJ2"

# All tasks done = silent exit
PROJ3=$(setup_project)
cat > "$PROJ3/.lifecycle/plans/done-progress.md" << 'EOF'
[x] Task 1 — setup
[x] Task 2 — implement
[x] Task 3 — test
EOF

OUTPUT3=$(echo "{\"cwd\":\"$PROJ3\"}" | bash "$ROOT_DIR/scripts/detect-active-work.sh")
if [ -z "$OUTPUT3" ]; then
  pass "silent exit when all tasks complete"
else
  fail "silent exit when all tasks complete (got output: $OUTPUT3)"
fi
cleanup "$PROJ3"

# ============================================================
echo ""
echo "=== wip-auto-save.sh ==="
# ============================================================

PROJ=$(setup_project)

# Set counter to 9 (next edit triggers save)
echo "9" > "$PROJ/.lifecycle/.wip-counter"

# Create dirty file
echo "unsaved work" > "$PROJ/dirty.txt"
git -C "$PROJ" add "$PROJ/dirty.txt"

echo "{\"cwd\":\"$PROJ\"}" | bash "$ROOT_DIR/scripts/wip-auto-save.sh"

WIP_BRANCHES=$(git -C "$PROJ" branch --list 'wip/*' 2>/dev/null)
if [ -n "$WIP_BRANCHES" ]; then
  pass "creates wip/ branch on 10th edit"
else
  fail "creates wip/ branch on 10th edit"
fi

# Counter should be reset
COUNTER=$(cat "$PROJ/.lifecycle/.wip-counter" 2>/dev/null || echo "missing")
if [ "$COUNTER" = "0" ]; then
  pass "resets counter after save"
else
  fail "resets counter after save (got: $COUNTER)"
fi

cleanup "$PROJ"

# Counter < 10 = no save
PROJ2=$(setup_project)
echo "5" > "$PROJ2/.lifecycle/.wip-counter"
echo "{\"cwd\":\"$PROJ2\"}" | bash "$ROOT_DIR/scripts/wip-auto-save.sh"

COUNTER2=$(cat "$PROJ2/.lifecycle/.wip-counter" 2>/dev/null || echo "missing")
if [ "$COUNTER2" = "6" ]; then
  pass "increments counter without saving (6 < 10)"
else
  fail "increments counter without saving (expected 6, got: $COUNTER2)"
fi
cleanup "$PROJ2"

# No .lifecycle = silent exit
PROJ3=$(mktemp -d)
echo "{\"cwd\":\"$PROJ3\"}" | bash "$ROOT_DIR/scripts/wip-auto-save.sh"
pass "silent exit without .lifecycle/"
rm -rf "$PROJ3"

# ============================================================
echo ""
echo "=== Summary ==="
# ============================================================

TOTAL=$((PASS + FAIL))
echo "$PASS/$TOTAL passed"
if [ "$FAIL" -gt 0 ]; then
  echo "${RED}$FAIL test(s) failed${RESET}"
  exit 1
else
  echo "${GREEN}All tests passed${RESET}"
  exit 0
fi
