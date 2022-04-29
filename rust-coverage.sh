#!/bin/bash

project=${PWD##*/}
echo "Starting coverage of $project"
RUSTFLAGS="-C instrument-coverage" cargo build
echo "Running $project"
read -p "Parameters:" -r parameters
./target/debug/$project  $parameters
$(rustc --print sysroot)/lib/rustlib/x86_64-unknown-linux-gnu/bin/llvm-profdata merge -sparse default.profraw -o default.profdata
# without any demangler
$(rustc --print sysroot)/lib/rustlib/x86_64-unknown-linux-gnu/bin/llvm-cov show target/debug/$project \
    -instr-profile=default.profdata \
    -show-line-counts-or-regions \
    -show-instantiations | less
