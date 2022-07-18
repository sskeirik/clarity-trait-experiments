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

## Description

The file `run-tests.sh` contains all of the trait experiments with commentary about what is being tested.

The test file is structured as sequence of test sections.
We list each section below with a description.

1.  **Trait Typing Tests**

    These tests demonstrate which traits the Clarity type checker will accept.

1.  **Trait Initialization Tests**

    These tests all initialize contracts that use or implement valid traits.

2.  **Trait Call Tests**

    These tests all call contracts that use or implement traits.
