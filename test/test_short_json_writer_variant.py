#!/usr/bin/env python3
"""Structural contract for the currently selected short JSON writer variant."""

import pathlib
import unittest


SOURCE = pathlib.Path(__file__).parents[1] / "src/stdx/encoding/json/write_buffer.cj"


def append_escape_small_block() -> str:
    text = SOURCE.read_text()
    start = text.index("func appendEscapeSmall")
    end = text.index("    func appendEscapeNative", start)
    return text[start:end]


class ShortJsonWriterVariantTest(unittest.TestCase):
    def test_span_variant_copies_maximal_normal_runs(self):
        block = append_escape_small_block()
        self.assertIn("var normalStart", block)
        self.assertIn("data.copyTo(_buffer, normalStart, _size, i - normalStart)", block)


if __name__ == "__main__":
    unittest.main(verbosity=2)
