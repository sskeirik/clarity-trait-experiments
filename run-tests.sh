#!/bin/bash

set -ueo pipefail

DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

addr=SP8CW062DS1XAZJJXWKSM9EMMDD51BRVFMY8MBX6
init='[ { "principal": "ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE", "amount": 1000 } ]'
init_file="$DIR/initial-allocations.json"
data_dir="$DIR/vm-state.db"

launch() {
  set +e
  echo ""
  clarity-cli launch "$addr.$1" "$DIR/contracts/$1.clar" "$data_dir"
  res1=$?
  [[ "$1" == *-fail ]]
  res2=$?
  [[ $res1 -ne $res2 ]] || { echo "error: test $1 failed" ; exit 1 ; }
  set -e
}

[ -f "$init_file" ] && rm "$init_file"
[ -d "$data_dir"  ] && rm -r "$data_dir"

echo "$init" > "$init_file"
clarity-cli initialize "$init_file" "$data_dir"

launch math-trait
launch impl-math-trait
launch partial-math-trait
launch use-math-trait

# Can we use impl-trait on a partial trait implementation? No.
launch impl-math-trait-fail

# Can we pass a literal where a trait is expected with a full implementation? Yes.
launch trait-literal

# Can we rename a trait with let and pass it to a function? Yes.
launch pass-let-rename-trait

# Can we pass a literal where a trait is expected with a partial implementation? No.
launch trait-literal-fail

# Can we rename a trait with let and call it? No.
launch call-let-rename-trait-fail

# Can we save trait in data-var or data-map? No.
launch trait-data-1-fail
launch trait-data-2-fail

# Can we use a trait exp where a principal type is expected? No.
# Principal can be expected in var/map/function
launch upcast-trait-1-fail
launch upcast-trait-2-fail
launch upcast-trait-3-fail

# Can we use a let-renamed trait where a principal type is expected?
# That is, does let-renaming affect the type? No.
launch upcast-renamed-fail

# Can we use a principal exp where a trait type is expected? No.
# Principal can come from constant/var/map/function/keyword
launch downcast-trait-1-fail
launch downcast-trait-2-fail
launch downcast-trait-3-fail
launch downcast-trait-4-fail
launch downcast-trait-5-fail

# # Can we define traits that use traits in not-yet-deployed contracts? No.
launch no-trait-fail

# # Can we define traits in a contract that are circular? No.
launch circular-trait-1-fail
launch circular-trait-2-fail
