# Clarity Trait Experiments

This repo contains a set of experiments to see how traits work.

To run the experiments, you need:

-   the Blockstack Clarity `clarity-cli` command available on your `PATH`
-   to run `bash run-tests.sh`

The file `run-tests.sh` contains all of the trait experiments with commentary about what is being tested.

The test file is structured as sequence of test sections.
We list each section below with a description.

1.  **Trait Typing Tests**

    These tests demonstrate which traits the Clarity type checker will accept.

1.  **Trait Initialization Tests**

    These tests all initialize contracts that use or implement valid traits.

2.  **Trait Call Tests**

    These tests all call contracts that use or implement traits.
