#!/bin/sh

# Run the local Neovim test files with isolated temp paths.

set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"

test_tmp_root="${TMPDIR:-/tmp}/nvim-config-tests"
mkdir -p "$test_tmp_root/cache" "$test_tmp_root/state"

test_files=$(find tests -maxdepth 1 -type f -name '*.lua' | sort)

if [ -z "$test_files" ]; then
  echo "No test files found under tests/"
  exit 1
fi

for test_file in $test_files; do
  echo "Running $test_file"
  env NVIM_LOG_FILE="$test_tmp_root/nvim.log" \
    XDG_CACHE_HOME="$test_tmp_root/cache" \
    XDG_STATE_HOME="$test_tmp_root/state" \
    nvim --headless -i NONE -n -u NONE \
    -c "lua local ok, err = pcall(dofile, \"$test_file\"); if not ok then vim.api.nvim_err_writeln(err); vim.cmd('cquit 1') end" \
    -c "qall!"
done

echo "All tests passed"
