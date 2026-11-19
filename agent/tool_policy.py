"""Opt-in tool policy for simulated evaluations. No host execution backend."""

from dataclasses import dataclass
from types import MappingProxyType
from typing import Callable, Mapping
from uuid import uuid4


@dataclass(frozen=True)
class ToolRule:
    arguments: Mapping[str, type]

    def __post_init__(self):
        object.__setattr__(self, "arguments", MappingProxyType(dict(self.arguments)))

    def accepts(self, supplied: dict) -> bool:
        return supplied.keys() == self.arguments.keys() and all(
            type(supplied[name]) is expected for name, expected in self.arguments.items()
        )


@dataclass(frozen=True)
class AuditEvent:
    trace_id: str
    status: str


class SimulatedRuntime:
    """Run only registered in-memory fixtures and audit decisions without inputs."""

    def __init__(
        self,
        rules: Mapping[str, ToolRule],
        fixtures: Mapping[str, Callable],
        audit: Callable[[AuditEvent], None],
        *,
        enabled: bool = False,
    ):
        self.rules = MappingProxyType(dict(rules))
        self.fixtures = MappingProxyType(dict(fixtures))
        self.audit = audit
        self.enabled = enabled

    def invoke(self, tool: str, arguments: dict) -> tuple[AuditEvent, object]:
        trace_id = uuid4().hex
        rule = self.rules.get(tool) if type(tool) is str else None
        if not self.enabled:
            status, result = "disabled", None
        elif rule is None or tool not in self.fixtures:
            status, result = "unknown_tool", None
        elif type(arguments) is not dict or not rule.accepts(arguments):
            status, result = "invalid_arguments", None
        else:
            try:
                result = self.fixtures[tool](**arguments)
                status = "ok"
            except Exception:
                status, result = "fixture_failed", None
        event = AuditEvent(trace_id, status)
        self.audit(event)
        return event, result
