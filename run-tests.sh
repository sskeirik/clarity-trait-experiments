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
  pass=$1; shift
  contract=$1; shift
  clarity-cli launch "$deploy_addr.$contract" "$DIR/contracts/$contract.clar" "$data_dir"
  res1=$?
  [[ "$pass" == true ]]
  res2=$?
  [[ $res1 -eq $res2 ]] || { echo "error: test $contract failed" ; exit 1 ; }
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
  [[ "$pass" == true ]]
  res2=$?
  [[ $res1 -eq $res2 ]] || { echo "error: test (contract-call? $contract $function $@) failed" ; exit 1 ; }
  set -e
}

[ -f "$init_file" ] && rm "$init_file"
[ -d "$data_dir"  ] && rm -r "$data_dir"

echo "$init" > "$init_file"
clarity-cli initialize "$init_file" "$data_dir"

# General Tests
# =============
#
# These tests demonstrate some baseline facts about Clarity.

# Can we define functions out-of-order? Yes.
launch true out-of-order-call

# Can we define circular methods? No.
launch false circular-methods

# Can we call undefined (or not-yet-defined) methods? No.
launch false no-method

# Trait Typing Tests
# ==================
#
# These tests demonstrate which traits the Clarity type checker will accept.

# Can we define an empty trait? Yes.
launch true empty-trait

# Can we re-define a trait with the same type and same name in a different contract? Yes.
launch true empty-trait-copy

# Can we define traits that use traits in not-yet-deployed contracts? No.
launch false no-trait

# Can we define traits in a contract that are circular? No.
launch false circular-trait-1
launch false circular-trait-2

# Can we define traits that do not return a response type? No.
launch false no-response-trait

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
launch true empty
launch true math-trait
launch true impl-math-trait
launch true partial-math-trait
launch true use-math-trait

# Can we use impl-trait on a partial trait implementation? No.
launch false impl-math-trait-incomplete

# Can we pass a literal where a trait is expected with a full implementation? Yes.
launch true trait-literal

# Can we rename a trait with let and pass it to a function? Yes.
launch true pass-let-rename-trait

# Can we pass a literal where a trait is expected with a partial implementation? No.
launch false trait-literal-incomplete

# Can we rename a trait with let and call it? No.
launch false call-let-rename-trait

# Can we save trait in data-var or data-map? No.
launch false trait-data-1
launch false trait-data-2

# Can we use a trait exp where a principal type is expected? No.
# Principal can be expected in var/map/function
launch false upcast-trait-1
launch false upcast-trait-2
launch false upcast-trait-3

# Can we use a let-renamed trait where a principal type is expected?
# That is, does let-renaming affect the type? No.
launch false upcast-renamed

# Can we use a principal exp where a trait type is expected? No.
# Principal can come from constant/var/map/function/keyword
launch false downcast-trait-1
launch false downcast-trait-2
launch false downcast-trait-3
launch false downcast-trait-4
launch false downcast-trait-5

# Can we cast a trait to a different trait with a different signature? No.
launch false trait-cast

# Can we cast a trait to a different trait with the same signature? No.
launch false identical-trait-cast

# Can we cast a trait to a renaming of itself? Yes.
launch true renamed-trait-cast

# Can we pass a trait to a read-only function? Yes.
launch true readonly-use-trait

# Can we pass a trait from a read-only function to a different read-only function? Yes.
launch true readonly-pass-trait

# Can a readonly function call a readonly public function? Yes.
launch true readonly-call-public

# Can we dynamically call a trait in a read-only function? No.
launch false readonly-call-trait

# Can we call a readonly function in a separate contract from a readonly function? Yes.
launch true readonly-static-call

# Can we call a function with traits from a read-only function statically? Yes.
launch false readonly-static-call-trait

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
