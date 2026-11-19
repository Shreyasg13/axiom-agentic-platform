# Agent sandbox and evaluation

The opt-in SimulatedRuntime exercises tool policy using trusted in-memory test
fixtures. It denies unknown tools and rejects unexpected keys and exact-type
mismatches. Audit records contain a trace ID and status only. Fixtures run in
the test process and must be registered by trusted code.

The ACP handler registers no tools and does not use this runtime. The manifest
currently references missing axiom_gladiator_13 build files and project/acp.py.
The checked-in ACP entry point is agent/acp.py.

Host execution, process limits, and filesystem and network isolation require
a separate executor. A Windows subprocess alone provides no confinement.
Validate a pinned container with dropped capabilities, read-only filesystem,
restricted mounts and no network before enabling any real tools. An eBPF
backend requires a compatible Linux host and separate verification.

Run python -B -m unittest discover -s tests. Omit enabled=True to roll back
fixture execution. Existing ACP operation requires no rollout.
