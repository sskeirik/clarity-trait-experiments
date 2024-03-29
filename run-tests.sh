#!/bin/bash

# Test Runner Code
# ================

set -ueo pipefail

export TIMEFORMAT=">>> %R"

TIME=false
[ $# -eq 1 ] && [ "$1" == 'time' ] && TIME=true

DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

deploy_addr=SP8CW062DS1XAZJJXWKSM9EMMDD51BRVFMY8MBX6
sender_addr=ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE
init="[ { \"principal\": \"$sender_addr\", \"amount\": 1000 } ]"
init_file="$DIR/initial-allocations.json"
data_dir="$DIR/vm-state.db"

timeit() {
  if $TIME; then
    time "$@"
  else
    "$@"
  fi
}

launch() {
  set +e
  echo ""
  pass=$1; shift
  contract=$1; shift
  timeit clarity-cli launch "$deploy_addr.$contract" "$DIR/contracts/$contract.clar" "$data_dir"
  res1=$?
  [[ "$pass" == true ]]
  res2=$?
  [[ $res1 -eq $res2 ]] || { echo "error: test $contract failed" ; exit 1 ; }
  $TIME && echo -e ">>> $pass\\t$contract" 
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
  timeit clarity-cli execute "$data_dir" "$deploy_addr.$contract" "$function" "$sender_addr" "$@"
  res1=$?
  [[ "$pass" == true ]]
  res2=$?
  [[ $res1 -eq $res2 ]] || { echo "error: test (contract-call? $contract $function $@) failed" ; exit 1 ; }
  $TIME && echo -e ">>> $pass\\t($contract $function $@"
  set -e
}

[ -f "$init_file" ] && rm "$init_file"
[ -d "$data_dir"  ] && rm -r "$data_dir"

echo "$init" > "$init_file"
clarity-cli initialize "$init_file" "$data_dir"

# Test Setup
# ==========
#
# We launch some simple contracts that we will use later.
# 0.  We define an empty contract
# 1.  We define a trait math
# 2.  We define a contract that implements trait math
# 3.  We define a contract that implements trait math partially
# 4.  We define a contract that uses a trait math
# 5.  We define a contract that uses a principal argument

launch true empty
launch true math-trait
launch true impl-math-trait
launch true partial-math-trait
launch true use-math-trait
launch true use-principal

# General Tests
# =============
#
# These tests demonstrate some baseline facts about Clarity.

# Can we define functions out-of-order?
launch true out-of-order-call

# Can we define circular methods?
launch false circular-methods

# Can we call undefined (or not-yet-defined) methods?
launch false no-method

# Can a readonly function call a readonly public function?
launch true readonly-call-public

# Trait Typing Tests
# ==================
#
# These tests demonstrate which traits the Clarity type checker will accept.

# Can we define an empty trait?
launch true empty-trait

# Can we re-define a trait with the same type and same name in a different contract?
launch true empty-trait-copy

# Can we define traits that use traits in not-yet-deployed contracts?
launch false no-trait

# Can we define traits in a contract that are circular?
launch false circular-trait-1
launch false circular-trait-2

# Can we define traits that do not return a response type?
launch false no-response-trait

# Can we define traits that occur in a contract out-of-order?
launch true out-of-order-traits

# Can we define a trait with two methods with the same name and different types?
launch true double-trait

# Can we implement a trait with two methods with the same name and different types?
launch false impl-double-trait-both # both   methods
launch false impl-double-trait-1    # first  method
launch true  impl-double-trait-2    # second method

# Can we partially implement a trait with two methods with the same name and different types?
launch true partial-double-trait-1 # first  method type
launch true partial-double-trait-2 # second method type

# Can we use a trait that has two methods with the same name and different types?
launch false use-double-trait           # use full impl    - both   method types
launch false use-partial-double-trait-1 # use partial impl - first  method type
launch true  use-partial-double-trait-2 # use partial impl - second method type

# Can we define a trait with two methods with the same name and the same type?
launch true identical-double-trait

# Can we implement a trait with two methods with the same name and the same type?
launch true impl-identical-double-trait

# Can we implement a trait that returns itself?
launch false selfret-trait

# Can we import a trait from a contract that uses but does not define the trait?
# Does the transitive import use the trait alias or the trait name?
launch false use-math-trait-transitive-alias
launch true  use-math-trait-transitive-name

# we launch a simple trait for testing with one method: do-it
launch true  a-trait

# Can we reference original trait and define trait with the same name in one contract?
launch false use-original-and-define-a-trait

# Can we reference redefined trait and define trait with the same name in one contract?
# Will this redefined trait also overwrite the trait alias?
launch true use-redefined-and-define-a-trait

# Can we use the original trait from a contract that redefines it?
launch false use-a-trait-transitive-original

# Can we use the redefined trait from a contract that redefines it?
launch true use-a-trait-transitive-redefined

# Can we nest traits in other types inside a function parameter type?
launch true nested-trait-1
launch true nested-trait-2
launch true nested-trait-3
launch true nested-trait-4

# Can we call functions with nested trait types by passing a trait parameter?
# Can we call functions with nested trait types where a trait parameter is _not_ passed? E.g. a response.
execute false nested-trait-1 foo "(list 'SP8CW062DS1XAZJJXWKSM9EMMDD51BRVFMY8MBX6.empty 'SP8CW062DS1XAZJJXWKSM9EMMDD51BRVFMY8MBX6.math-trait)"
execute false nested-trait-2 foo "(some 'SP8CW062DS1XAZJJXWKSM9EMMDD51BRVFMY8MBX6.empty)"
execute false nested-trait-3 foo "(ok   'SP8CW062DS1XAZJJXWKSM9EMMDD51BRVFMY8MBX6.empty)"
execute true  nested-trait-3 foo "(err false)"
execute false nested-trait-4 foo "(tuple (empty 'SP8CW062DS1XAZJJXWKSM9EMMDD51BRVFMY8MBX6.empty))"

# Trait Initialization Tests
# ==========================
#
# These tests all initialize contracts that use or implement valid traits.

# Can we use impl-trait on a partial trait implementation?
launch false impl-math-trait-incomplete

# Can we pass a literal where a trait is expected with a full implementation?
launch true trait-literal

# Can we rename a trait with let and pass it to a function?
launch true pass-let-rename-trait

# Can we pass a literal where a trait is expected with a partial implementation?
launch false trait-literal-incomplete

# Can we rename a trait with let and call it?
launch false call-let-rename-trait

# Can we save trait in data-var or data-map?
launch false trait-data-1
launch false trait-data-2

# Can we use a trait exp where a principal type is expected?
# Principal can be expected in var/map/function
launch false upcast-trait-1
launch false upcast-trait-2
launch false upcast-trait-3

# Can we return a trait from a function and use it?
launch true  return-trait

# Can we use a let-renamed trait where a principal type is expected?
# That is, does let-renaming affect the type?
launch false upcast-renamed

# Can we use a principal exp where a trait type is expected?
# Principal can come from constant/var/map/function/keyword
launch false downcast-trait-1
launch false downcast-trait-2
launch false downcast-trait-3
launch false downcast-trait-4
launch false downcast-trait-5

# Can we cast a trait to a different trait with a different signature?
launch false trait-cast

# Can we cast a trait to a different trait with the same signature?
launch false identical-trait-cast

# Can we cast a trait to a renaming of itself?
launch true renamed-trait-cast

# Can we pass a trait to a read-only function?
launch true readonly-use-trait

# Can we pass a trait from a read-only function to a different read-only function?
launch true readonly-pass-trait

# Can we dynamically call a trait in a read-only function?
launch false readonly-call-trait

# Can we call a readonly function in a separate contract from a readonly function?
launch true readonly-static-call

# Can we call a function with traits from a read-only function statically?
launch false readonly-static-call-trait

# Trait Call Tests
# ================
#
# These tests all call contracts that use or implement traits.

# Can we dynamically call a contract that fully implements a trait?
execute true use-math-trait add-call $(conlit impl-math-trait) u3 u5

# Can we dynamically call a contract that just implements one function from a trait?
execute true use-math-trait add-call $(conlit partial-math-trait) u3 u5

# Can we dynamically call a contract that does implement the function call via the trait?
execute false use-math-trait add-call $(conlit empty) u3 u5

# Can we call a contract with takes a principal with a contract identifier that is not bound to a deployed contract?
execute true use-principal use $(conlit made-up)

# Can we call a contract where a function returns a trait?
execute true return-trait add-call-indirect $(conlit impl-math-trait) u3 u5

# Can we call a contract with a fully implemented double method trait?
execute true use-partial-double-trait-2 call-double $(conlit impl-double-trait-2)

# Can we call a contract with a partially implemented double method trait?
execute true use-partial-double-trait-2 call-double $(conlit partial-double-trait-2)

# Trait Recursion Example
# =======================
#
# This example shows how traits can induce the runtime to make a recursive (but terminating) call which is caught by the recursion checker at runtime.

launch  true  simple-trait
launch  true  impl-simple-trait
launch  true  impl-simple-trait-2
execute false simple-trait call-simple $(conlit impl-simple-trait-2)
