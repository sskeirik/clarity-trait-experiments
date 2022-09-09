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
