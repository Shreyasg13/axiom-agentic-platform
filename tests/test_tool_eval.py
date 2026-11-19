import unittest

from agent.tool_eval import FixtureCase, evaluate
from agent.tool_policy import SimulatedRuntime, ToolRule


class EvaluationTests(unittest.TestCase):
    def test_pinned_fixture_trials_count_policy_errors(self):
        runtime = SimulatedRuntime(
            {"lookup": ToolRule({"index": int})},
            {"lookup": lambda index: index},
            lambda event: None,
            enabled=True,
        )
        result = evaluate(runtime, (
            FixtureCase("unknown", "unregistered", (), "unknown_tool"),
            FixtureCase("malformed", "lookup", (("index", True),), "invalid_arguments"),
            FixtureCase("wrong expectation", "lookup", (("index", 1),), "disabled"),
        ), fixture_version="test-v1", runtime_version="runtime-v1", repeats=2)
        self.assertEqual(len(result.trials), 6)
        self.assertEqual(result.accuracy, 4 / 6)
        self.assertEqual([trial.repeat for trial in result.trials], [0, 0, 0, 1, 1, 1])
