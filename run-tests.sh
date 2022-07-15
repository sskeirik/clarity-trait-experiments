#!/bin/bash

# Test Runner Code
# ================

set -ueo pipefail

DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

deploy_addr=SP8CW062DS1XAZJJXWKSM9EMMDD51BRVFMY8MBX6
sender_addr=ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE
init="[ { \"principal\": \"$sender_addr\", \"amount\": 1000 } ]"
init_file="$DIR/initial-allocations.json"
data_dir="$DIR/vm-state.db"

launch() {
  set +e
  echo ""
  clarity-cli launch "$deploy_addr.$1" "$DIR/contracts/$1.clar" "$data_dir"
  res1=$?
  [[ "$1" == *-fail ]]
  res2=$?
  [[ $res1 -ne $res2 ]] || { echo "error: test $1 failed" ; exit 1 ; }
  set -e
}

conlit() {
  echo "'$deploy_addr.$1"
}

execute() {
  set +e
  echo ""
  pass=$1; shift
  contract=$1; shift
  function=$1; shift
  clarity-cli execute "$data_dir" "$deploy_addr.$contract" "$function" "$sender_addr" "$@"
  res1=$?
  $pass
  res2=$?
  [[ $res1 -eq $res2 ]] || { echo "error: test (contract-call? $contract $function $@) failed" ; exit 1 ; }
  set -e
}

[ -f "$init_file" ] && rm "$init_file"
[ -d "$data_dir"  ] && rm -r "$data_dir"

echo "$init" > "$init_file"
clarity-cli initialize "$init_file" "$data_dir"

# Trait Typing Tests
# ==================
#
# These tests demonstrate which traits the Clarity type checker will accept.

# Can we define an empty trait? Yes.
launch empty-trait

# Can we define traits that use traits in not-yet-deployed contracts? No.
launch no-trait-fail

# Can we define traits in a contract that are circular? No.
launch circular-trait-1-fail
launch circular-trait-2-fail

# Can we define traits that do not return a response type? No.
launch no-response-trait-fail

# Trait Initialization Tests
# ==========================
#
# These tests all initialize contracts that use or implement valid traits.

# We first initialize our database with a few simple contracts
# 0.  We define an empty contract
# 1.  We define a trait math
# 2.  We define a contract that implements trait math
# 3.  We define a contract that implements trait math partially
# 4.  We define a contract that uses a trait math
launch empty
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

# Trait Call Tests
# ================
#
# These tests all call contracts that use or implement traits.

# Can we dynamically call a contract that fully implements a trait? Yes.
execute true use-math-trait add-call $(conlit impl-math-trait) u3 u5

# Can we dynamically call a contract that just implements one function from a trait? Yes.
execute true use-math-trait add-call $(conlit partial-math-trait) u3 u5

# Can we dynamically call a contract that does implement the function call via the trait? No.
execute false use-math-trait add-call $(conlit empty) u3 u5
