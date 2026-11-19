import unittest

from agent.tool_policy import SimulatedRuntime, ToolRule


class ToolPolicyTests(unittest.TestCase):
    def test_denials_never_call_fixture_and_audit_omits_payload(self):
        calls, events = [], []
        rules = {"lookup": ToolRule({"index": int})}
        fixtures = {"lookup": lambda index: calls.append(index)}
        off = SimulatedRuntime(rules, fixtures, events.append)
        on = SimulatedRuntime(rules, fixtures, events.append, enabled=True)
        for runtime, tool, args, expected in (
            (off, "lookup", {"index": 3}, "disabled"),
            (on, "secret-path", {}, "unknown_tool"),
            (on, "lookup", {"index": True}, "invalid_arguments"),
            (on, "lookup", {"index": 3, "extra": "secret-path"}, "invalid_arguments"),
        ):
            event, result = runtime.invoke(tool, args)
            self.assertEqual(event.status, expected)
            self.assertIsNone(result)
        self.assertEqual(calls, [])
        self.assertEqual(len({event.trace_id for event in events}), 4)
        self.assertNotIn("secret-path", repr(events))

    def test_fixture_output_and_failure(self):
        runtime = SimulatedRuntime(
            {"lookup": ToolRule({"index": int})},
            {"lookup": lambda index: ["fixture"][index]},
            lambda event: None,
            enabled=True,
        )
        self.assertEqual(runtime.invoke("lookup", {"index": 0})[1], "fixture")
        self.assertEqual(runtime.invoke("lookup", {"index": 1})[0].status, "fixture_failed")
