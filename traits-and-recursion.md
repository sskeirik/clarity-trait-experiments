Clarity Traits and Recursion
============================

Abstract
--------

We want to show that Clarity contracts always terminate, even in the presence of traits bound to contract identifiers by some call transaction to blockchain.
To do this, we show that any chain of Clarity method calls (whether intra- or inter-contract) decrease along several inter-related well-founded orders:

1.  the order on contract knowledge (i.e. contract initialization time) which restricts a contract's ability to make static calls (since contracts cannot call contracts they do not know about);
2.  the order on functions and trait definitions inside a single contract (i.e. trait and function definitions cannot contain mutual recursion/reference);
3.  the order on call flexibility (i.e. the presence of trait-valued parameters which are bound to contract identifiers dynamically supplied at runtime) which restricts a contract's ability to make dynamic calls and potentially call more knowledgable contracts.

The first two orders combine to produce a total, well-founded ordering on all functions and trait definitions across all contracts, which implies that all contracts without traits terminate.
The third order clamps down on potential leaks of knowledge via a combination of dynamic and static calls.

Terminology
-----------

### Notation

With or without subscripts, we generally let:

-   C refer to contracts
-   M refer to methods
-   T refer to traits
-   S refer to sets of traits
-   λ refer to a call

### Traits, Contracts, and Methods

Define a trait as named set of methods signatures.
We define a Clarity contract as tuple containing a set of constants, data variables, data maps, public or private methods, and traits.
We say a method M is in a trait T (resp. not in a trait T) if the specification of T contains (resp. does not contain) M's signature.
Similarly, we say that a method M is in a trait set S={T_1...T_N} if it is in the union U{T_1...T_N}.

### Traits and Types

A trait identifier is a tuple containing a contract name (which defined the trait) and a trait name.
By the semantics of Clarity, the identifier of each trait that a contract defines or imports becomes a new type available to the type system.

Unlike standard types, which may appear in all positions in the AST where types are accepted, the syntax of Clarity only permits trait identifier types to exist in two positions:

1.  as type annotations on formal parameters in method definitions;
2.  as type annotations on formal parameters in method descriptions in traits.

Unlike standard values, values belonging to type trait T can only be consumed in a few ways:

1.  as arguments to contract methods;
2.  as the first argument to the `contract-call?` built-in function.
3.  as the sole argument to the `contract-of?` built-in function.

Since usage (3) is not relevant to recursion, we ignore it.

Unlike other types, there are no precise set of literals of trait type.
A method with trait-typed parameters can be instantiated in two ways:

1.  it can be instantiated by a call transaction argument (more on that below);
2.  it can be instantiated by a contract identifier literal

When a type (2) instantiation occurs, the runtime checks that the contract implements _all_ methods in the trait.
This seems to be due to a desire to avoid inter-procedural analysis, preventing the analyzer from inferring which methods will be called on that trait parameter.

### Method Flexibility

Given a contract C with some method M, we say that M is:

-   _T-flexible_ if any of its formal parameters have type trait T (and _T-inflexible_ otherwise)
-   _{T_1...T_N}-flexible_ if it is T_I-flexible for each T_I in {T_1...T_N}
-   _flexible_ if it is _T-flexible_ for any trait T (and _inflexible_ otherwise)

Note that, by the above definitions, {}-flexibility is equivalent to inflexibility.

### Transaction Lifecycle

A transaction is some data that is (a) submitted to the blockchain to be stored or executed and (b) signed by the submitter's private key.
A call transaction is a transaction that contains:

1.  a contract identifier C
2.  a public method name M
3.  a list of public method arguments V1...VN

When the blockchain receives a call transaction, it responds by:

-  validating that the contract C exists and has a method M which can accept arguments V1...VN and;
-  calling the method M in contract C with arguments V1...VN.

Once this first call is complete, the blockchain:

-   responds to the submitter with the call result
-   updates the state of any contracts that were affected by the call (i.e. commits any contract side-effects).

### External and Internal Calls

The first method call initiated by a call transaction is called an _external_ call.
However, the method M called by an external call may itself call other methods, which may call other methods, etc.
Any call that is not external is called _internal_.

We further subdivide internal calls into two types:

1.  _intra-contract_ internal calls which use the standard syntax `(function-name function-args)`
2.  _inter-contract_ internal calls which use the syntax `(contract-call? contract-name function-name function-args)`

### Dynamic Call Graphs

A dynamic call graph is a rooted, directed multi-graph where:

-   nodes are pairs of contract identifiers and methods;
-   directed edges are method calls annotated with call properties.

Note that multiple edges may exist from method M_1 to M_2 if M_1 calls M_2 multiple times.

The graph root is a special start node which we can understand as a universal contract that:

1.  has knowledge of all contracts that exist at the time of the call (see contract knowledge);
2.  has a universal method which is T-flexible for all traits T.

It contains only one outgoing edge, the external call that initiated the blockchain contract execution.
All other edges are internal calls, by definition.

The set of call properties includes:

1.  the call order: a natural number
2.  the call parent: an optional natural number
3.  the call arguments: a list of values
4.  the call flexibility: a set of pairs of traits and natural numbers
5.  the call dynamicity: either dynamic or static

We explore these properties below.

#### Call Order

The start edge has call order 0.
For each subsequent call, the call order is incremented by 1.

#### Call Parent

For internal calls, the call parent is the order of the call which induced the current call
For external calls, the call parent is undefined.

#### Call Arguments

The call arguments are just the values passed from the caller to the callee.

#### Call Flexibility

Call flexibility is a recursive property that is defined over the dynamic call graph structure.
By definition, the external call (i.e. the start edge has order 0) is {(I_1,T_1)... (I_K,T_K)}-flexible if the external call is to a method such that:

-   each index I_J selects formal parameter that has a trait T type for an arbitrary T;
-   index I_J has trait T_J type.

Observe the trait projection of call flexibility is always a subset of the flexibility of the method M which it calls.
We now define flexibility of internal calls (i.e. calls with order N > 0) recursively.
All internal calls have the form:

```
                        --------------------                         --------------------
-- S_P-flexible λ_P --> | S_1-flexible M_1 | -- S_C-flexible λ_C ->  | S_2-flexible M_2 |
                        --------------------                         --------------------
```

That is, an S_P-flexible parent call λ_P to S_1-flexible method M_1 induces an S_C-flexible child call λ_C to S_2-flexible method M_2.
To determine the flexibility S_C, we examine how each formal parameter in M_2 was bound by call λ_C:

-   _dynamically_, i.e., to a trait T_J typed formal parameter at index I_J from M_1
-   _statically_, i.e., to a contract identifier literal which exists on-chain and which fully implements T

The _origin_ of a dynamic binding is the pair of parameter index and trait of the parameter that the caller method used in the binding.

Then flexibility S_C is defined as:

-   the subset of M_2 parameter index and trait pairs (I_J, T_J) which are bound dynamically in λ_C;
-   whose origin is contained in S_P

We say a {}-flexible call λ is _inflexible_ and (I,T)-flexible whenever it is S-flexible with (I,T) in S.

#### Dynamic and Static Calls

We further subdivide calls into static and dynamic.
We further subdivide dynamic into apparent dynamic and true dynamic classes.
The callee of static calls is determined at contract analysis time while the callee of dynamic calls is not.

All internal intra-contract calls are defined to be _static_.
All external contract calls are defined to be _static_ but this choice is arbitrary.

We say an internal inter-contract call λ is _static_ whenever the first argument to `contract-call?` is a contract identifier.
We say λ is _true dynamic_ whenever:

1.  the first argument to `contract-call?` is instantiated with parameter I_J with type trait T from the calling method M; and
2.  the parent call is (I_J, T)-flexible.

Finally, we say λ is _apparent dynamic_ whenever condition (2) above fails to hold.

The callee of a static call is always known at contract initialization time.
However, the callee of a dynamic call depends on the arguments passed to the calling method.
Apparent dynamic calls are statically determinable via interprocedural analysis while true dynamic calls are only known at runtime.

### Dynamic Call Chains

A dynamic call chain is a non-empty sequence of dynamic call graph edges where the parent of each non-initial call is equal to its predecessor in the chain.

We define a cycle to be a dynamic call chain that starts and ends on the same node.

We say a call λ_1 is an ancestor of call λ_2 if there is a call chain in the call graph from λ_1 to λ_2.
For simplicity, we say that a call is always an ancestor of itself.

Lemma: _Call Flexibility Never Increases_.
Suppose λ_1 and λ_2 refer to S_1 and S_2 flexible calls and that λ_1 is a predecessor of λ_2 in a call chain.
Then S_1 is a superset of S_2.

Proof: By straightforward induction on call chain length.

### Contract Knowledge

Clarity contract analysis uses a knowledge relation to ensure all definitions are well-founded and prevent unwanted recursion.
The knowledge relation is between two contract identifiers.
We say C knows C' whenever:

-   C is equal to C' or;
-   C' was initialized before C was initialized.

Lemma: _Static Inter-contract Calls Decrease Knowledge_.
Suppose λ_1 is a static inter-contract call originating from contract C_1 and going to C_2.
Then the knowledge of C_1 is a strict superset of C_2.

Proof: By a straightforward induction on contract initialization time.

Lemma: _Static Knowledge Never Increases_.
Suppose λ_1 and λ_2 refer to calls originating from contract C_1 and C_2 respectively and that λ_1 is a predecessor of λ_2 in a chain of static (inter- or intra-contract) calls.
Then the knowledge of C_1 is a superset of C_2.

Proof: By straightforward induction on call chain length.

Lemma: _Dynamic Knowledge Never Increases_.
Suppose λ_1 and λ_2 refer to calls originating from contract C_1 and C_2 respectively and that λ_1 is a predecessor of λ_2 in a chain of calls.
Let C_M1 ... C_MN be the contract identifiers bound to trait-valued parameters in call λ_1.
Then the knowledge of U{C_M1,...,C_MN} U C_1 is a superset of C_2.

Proof: FIXME

### Circularity

We say a list of traits T_1, T_2, ..., T_N is _circular_ if and only if:

-   for each I with 0 < I < N, T_I contains a method M_I which is T_{I+1}-flexible
-   T_N contains a method M_N which is T_1-flexible

Similarly, we say a list of methods M_1, M_2, ..., M_N is _circular_ if and only if:

-   for each I with 0 < I < N, method M_I has a static, internal call to M_{I+1}
-   M_N contains a static, internal call to M_1

By abuse of notation, we say any trait T or method M which is a member of a circular list is also called _circular_.

The semantics of Clarity forbids circular traits and methods by two mechanisms:

1.  a contract C cannot refer to any trait or method from an unknown contract (no inter-contract circularity);
2.  a contract C is forbidden from containing a set of methods or traits which forms a circular list (no intra-contract circularity).

### Call Requirements

Internal calls have certain validity requirements.
Among these requirements are:

1.  **Knowledge**

    We say that an internal call from contract C and method M to contract C' and method M' is invalid if C' is unknown to C.
    For true dynamic calls, the runtime must check at call time that contract exists.
    For apparent dynamic calls, the runtime checks that the contract exists at contract initialization time.

    This knowledge relation prevents contracts from referring to contracts that do not exist yet.

2.  **Inter-Contract Call Distinctness**

    An internal inter-contract call originating from C is invalid if the target contract is also C.

Traits and Call Graph Cycles
----------------------------

By the semantics of Clarity, inflexible methods cannot have cycles in their call graph.
If they did that would directly imply that there is a circular chain of methods, which the semantics forbids.
Similarly, the semantics forbids inflexible calls (and therefore inflexible methods) from making flexible or true dynamic calls.

The question remains: can dynamic calls induce a cycle in the call graph or are all Clarity call graphs actually directed acyclic graphs (DAGs)?

Theorem: Clarity call graphs cannot contain cycles

Proof (By contradiction):

Assume there exists a call graph G with start edge λ_B that contains a cycle K rooted at method M.
Thus, M has at least 2 incoming edges:

-   λ_K0 is the incoming edge forming begins the cycle (i.e. the edge in the chain with the lowest order)
-   λ_KN is the edge which completes the cycle

where there exists a call chain λ_K0, ..., λ_KN with call flexibilities S_K0, ..., S_KN respectively.
Without loss of generality, assume that no method occurs in the chain three times and that only M occurs twice (since any cycle of the prior two forms must contain a smaller cycle).

We first make some observations:

1.  K _must_ contain at least one true dynamic call.
    If K only contained static calls, then the methods called in K would be circular, which violates the Clarity semantics.
    If K only contained apparent dynamic calls or static calls, then at least one apparent dynamic call would be of one of the following forms:

    -   a `contract-call?` to its itself which violates the inter-contract call distinctness requirement;
    -   a `contract-call?` to which violates the knowledge requirement --- FIXME: Make this clearer.

2.  λ_B is an S_B-flexible call, λ_K0 is an S_K0-flexible call, S_B is a superset of S_K0, and S_K0 is non-empty.
    This follows because all calls are ancestors of λ_B and call flexibility never increases.

3.  S_K0 is a superset of S_KN.
    This follows because λ_K0 is an ancestor of λ_KN.

FIXME: Finish this proof.
