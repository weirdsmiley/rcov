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

$(rustc --print sysroot)/lib/rustlib/x86_64-unknown-linux-gnu/bin/llvm-profdata merge -sparse default.profraw -o default.profdata
# without any demangler
$(rustc --print sysroot)/lib/rustlib/x86_64-unknown-linux-gnu/bin/llvm-cov show target/debug/$project \
    -instr-profile=default.profdata \
    -show-line-counts-or-regions \
    -show-instantiations | less
