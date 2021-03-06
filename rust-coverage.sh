#!/bin/bash

project=${PWD##*/}

printf '=%.0s' {1..35} ; printf '\n'
echo "~ Starting coverage of $project"
printf '=%.0s' {1..35} ; printf '\n'

RUSTFLAGS="-C instrument-coverage" cargo build

printf '=%.0s' {1..35} ; printf '\n'
echo "~ Running $project"
printf '=%.0s' {1..35} ; printf '\n'

read -p "Enter parameters after: ./target/debug/$project " -r parameters

./target/debug/$project  $parameters


if [ -f default.profraw ]; then
  mv default.profraw ./target/
fi

$(rustc --print sysroot)/lib/rustlib/x86_64-unknown-linux-gnu/bin/llvm-profdata \
  merge -sparse ./target/default.profraw -o ./target/default.profdata

printf '=%.0s' {1..35} ; printf '\n'
echo "~ Generating HTML files for coverage"
printf '=%.0s' {1..35} ; printf '\n'

$(rustc --print sysroot)/lib/rustlib/x86_64-unknown-linux-gnu/bin/llvm-cov show \
  -instr-profile=./target/default.profdata ./target/debug/$project ./src \
  -format html -output-dir ./target/coverage
firefox --new-tab ./target/coverage/index.html 2> /dev/null

# without any demangler
$(rustc --print sysroot)/lib/rustlib/x86_64-unknown-linux-gnu/bin/llvm-cov show target/debug/$project \
    -instr-profile=./target/default.profdata \
    -show-line-counts-or-regions \
    -show-instantiations | less
