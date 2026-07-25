#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Validate commit subject lines.

Expected default format:
  feat: commit message
  fix: commit message
  chore: commit message
  Merge branch 'main' into test-2

Commit subjects must not be empty and must have at most 72 characters.

Usage:
  validate-commit-message.sh --message "feat: add login"
  validate-commit-message.sh --file .git/COMMIT_EDITMSG
  validate-commit-message.sh --range "BASE_SHA..HEAD_SHA"
  git log --format=%s BASE_SHA..HEAD_SHA | validate-commit-message.sh

Options:
  -m, --message MESSAGE  Validate one commit subject.
  -f, --file FILE        Validate the first line from a commit message file.
  -r, --range RANGE      Validate commit subjects from a git revision range.
  -h, --help             Show this help.

Environment variables:
  COMMIT_RANGE           Git revision range used when --range is not provided.
USAGE
}

error() {
  printf 'Error: %s\n' "$*" >&2
}

github_escape() {
  local value="$1"
  value="${value//'%'/'%25'}"
  value="${value//$'\r'/'%0D'}"
  value="${value//$'\n'/'%0A'}"
  printf '%s' "$value"
}

require_value() {
  local option="$1"
  local value="${2:-}"

  if [[ -z "$value" ]]; then
    error "$option requires a value."
    usage >&2
    exit 2
  fi
}

require_argument() {
  local option="$1"
  local argument_count="$2"

  if ((argument_count < 2)); then
    error "$option requires a value."
    usage >&2
    exit 2
  fi
}

max_subject_length=72
commit_regex="^(feat|fix|chore): [^[:space:]].*"
merge_commit_regex="^Merge branch '([^']+)' into ([^[:space:]].*)$"
expected_format="feat: commit message, fix: commit message, or chore: commit message"
messages=()
message_file=""
commit_range="${COMMIT_RANGE:-}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -m | --message)
      require_argument "$1" "$#"
      messages+=("$2")
      shift 2
      ;;
    -f | --file)
      require_value "$1" "${2:-}"
      message_file="$2"
      shift 2
      ;;
    -r | --range)
      require_value "$1" "${2:-}"
      commit_range="$2"
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    --)
      shift
      while [[ $# -gt 0 ]]; do
        messages+=("$1")
        shift
      done
      ;;
    *)
      messages+=("$1")
      shift
      ;;
  esac
done

if [[ -n "$message_file" ]]; then
  if [[ ! -f "$message_file" ]]; then
    error "Commit message file not found: $message_file"
    exit 2
  fi

  file_subject=""
  IFS= read -r file_subject <"$message_file" || true
  messages+=("$file_subject")
fi

if [[ -n "$commit_range" ]]; then
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    error "--range requires running inside a git repository."
    exit 2
  fi

  if ! range_subjects="$(git log --format=%s "$commit_range")"; then
    error "Unable to read commits from range: $commit_range"
    exit 2
  fi

  if [[ -n "$range_subjects" ]]; then
    while IFS= read -r subject; do
      messages+=("$subject")
    done <<<"$range_subjects"
  fi
fi

if [[ ${#messages[@]} -eq 0 && ! -t 0 ]]; then
  while IFS= read -r subject; do
    messages+=("$subject")
  done
fi

if [[ ${#messages[@]} -eq 0 ]]; then
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    messages+=("$(git log -1 --format=%s)")
  else
    usage >&2
    exit 2
  fi
fi

failures=0

for subject in "${messages[@]}"; do
  failure_reason=""

  if [[ -z "$subject" ]]; then
    failure_reason="Commit message must not be empty."
  elif ((${#subject} > max_subject_length)); then
    failure_reason="Commit message must have at most ${max_subject_length} characters."
  elif [[ "$subject" =~ $commit_regex || "$subject" =~ $merge_commit_regex ]]; then
    failure_reason=""
  else
    failure_reason="Commit message must start with feat:, fix:, or chore: followed by a non-empty message."
  fi

  if [[ -n "$failure_reason" ]]; then
    if [[ "${GITHUB_ACTIONS:-}" == "true" ]]; then
      printf '::error title=Invalid commit message::%s\n' "$(github_escape "$subject")"
    fi

    printf 'Invalid commit message: "%s"\n' "$subject" >&2
    printf '%s\n' "$failure_reason" >&2
    printf 'Expected format: %s\n' "$expected_format" >&2
    failures=$((failures + 1))
  fi
done

if ((failures > 0)); then
  exit 1
fi

printf 'Validated %d commit message(s).\n' "${#messages[@]}"
