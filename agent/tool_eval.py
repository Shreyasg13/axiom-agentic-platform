"""Repeatable evaluation of trusted tool fixtures."""

from dataclasses import dataclass
from time import perf_counter_ns
from uuid import uuid4

from agent.tool_policy import SimulatedRuntime


@dataclass(frozen=True)
class FixtureCase:
    name: str
    tool: str
    arguments: tuple[tuple[str, str | int | float | bool | None], ...]
    expected_status: str


@dataclass(frozen=True)
class Trial:
    case: str
    repeat: int
    status: str
    correct: bool
    latency_ns: int


@dataclass(frozen=True)
class Evaluation:
    run_id: str
    fixture_version: str
    runtime_version: str
    trials: tuple[Trial, ...]

    @property
    def accuracy(self) -> float:
        return sum(trial.correct for trial in self.trials) / len(self.trials)


def evaluate(
    runtime: SimulatedRuntime,
    cases: tuple[FixtureCase, ...],
    *,
    fixture_version: str,
    runtime_version: str,
    repeats: int,
) -> Evaluation:
    if not cases or not fixture_version or not runtime_version:
        raise ValueError("cases and version identifiers are required")
    if len({case.name for case in cases}) != len(cases):
        raise ValueError("case identifiers must be unique")
    if type(repeats) is not int or not 1 <= repeats <= 100:
        raise ValueError("repeats must be an integer between 1 and 100")
    trials = []
    for repeat in range(repeats):
        for case in cases:
            started = perf_counter_ns()
            decision, _ = runtime.invoke(case.tool, dict(case.arguments))
            trials.append(Trial(
                case.name, repeat, decision.status,
                decision.status == case.expected_status, perf_counter_ns() - started,
            ))
    return Evaluation(uuid4().hex, fixture_version, runtime_version, tuple(trials))
