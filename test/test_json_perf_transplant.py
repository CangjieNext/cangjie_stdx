from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
NATIVE = ROOT / "src/stdx/encoding/json/native.cj"


class JsonPerformanceTransplantTest(unittest.TestCase):
    def test_tree_parser_uses_incremental_containers_not_payload_sized_cache(self):
        source = NATIVE.read_text()

        self.assertIn("const INITIAL_JSON_OBJECT_CAPACITY = 8", source)
        self.assertIn("const INITIAL_JSON_ARRAY_CAPACITY = 8", source)
        self.assertNotIn("var cache: Array<JsonValue>", source)
        self.assertNotIn("size >> 1", source)
        self.assertIn("let obj = JsonObject(INITIAL_JSON_OBJECT_CAPACITY)", source)
        self.assertIn("let arr = JsonArray(INITIAL_JSON_ARRAY_CAPACITY)", source)


if __name__ == "__main__":
    unittest.main()
