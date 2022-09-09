# Clarity Trait Experiments

This repo contains a set of experiments to see how traits work.

To run the experiments, you need to install the prerequisites first.

## Prerequisites

1.  Install `clarity-cli` by either installing a [Stacks release package](https://github.com/stacks-network/stacks-blockchain/releases/) or by building from source by:

    -   Installing the rust tools including cargo from either your package manager or [rustup](https://rustup.rs/).
    -   Cloning the [stacks-blockchain repo](https://github.com/stacks-network/stacks-blockchain) with git
    -   In the root of the stacks blockchain repo archive, running `cargo build` which should put the `clarity-cli` binary in the `target/debug` folder.

2.  Add `clarity-cli` to your `PATH`

## Usage

Then to run the tests, you should do:

```bash
bash run-tests.sh
```

To run and time the tests, you can do:

```bash
bash time-tests.sh
```

All tests are listed with times given upto millisecond precision.

## Description

The file `run-tests.sh` contains all of the trait experiments with commentary about what is being tested.

The test file is structured as sequence of test sections.
We list each section below with a description.

1.  **Test Setup**

    This section initializes some simple contracts that we will use later.

2.  **General Tests**

    This section contains some simple tests for sanity checking purposes.

3.  **Trait Typing Tests**

    These tests demonstrate which traits the Clarity type checker will accept.

4.  **Trait Initialization Tests**

    These tests all initialize contracts that use or implement valid traits.

5.  **Trait Call Tests**

    These tests all call contracts that use or implement traits.

6.  **Trait Recursion Example**

    This example shows how traits can induce the runtime to make a recursive (but terminating) call which is caught by the recursion checker at runtime.

## Adding New Tests

To add new tests, several steps need to be performed:

1.  (optional) Add a new clarity source file to the contracts folder; it should have a `.clar` extension.
2.  Add your test case into the `run-tests.sh` file somewhere _after_ the line which contains the command:

    ```sh
    clarity-cli initialize "$init_file" "$data_dir"
    ```

    See the section [Test Case Format](#test-case-format) below for details.

**NOTE:** Depending on where you add your test case, the result may be different, e.g., if the test case interacts with other contracts in some way.

## Test Case Format

Each test case has one of the following forms:

-   Tests which initialize a contract have the form:

    ```
    launch <true|false> <contract-name-without-extension>
    ```

    where the boolean argument indicates whether the contract _should_ initialize successfully.

    Here is an example from the current test suite:

    ```sh
    launch true empty
    ```

    This indicates that, the empty contract should initialize successfully.

-   Tests which call contracts have the form:

    ```
    execute <true|false> <contract-name-without-extension> <function-name> <function-arguments>
    ```

    where the boolean argument indicates whether the contract call _should_ complete successfully.

    Here is an example from the current test suite:

    ```sh
    execute true nested-trait-3 foo "(err false)"
    ```

    This says that when calling the contract `nested-trait-3` at function `foo` with the argument `(err false)`, the contract call will succeed.

    **NOTE:** An `execute true contract-name ...` test will always fail if it occurs before a corresponding `launch true contract-name`.

**NOTE:** Due to the current test harness structure, it is _not_ possible to initialize a contract file twice, i.e., the following pattern _cannot_ appear in the `run-tests.sh` file:

```
launch true contract-name
...
...
launch true contract-name
```

To get around this, you can copy the existing contract into a fresh file and then initialize that contract, e.g.,

```
launch true contract-name
...
...
launch true contract-name-copy
```
