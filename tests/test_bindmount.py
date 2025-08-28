from __future__ import annotations

import unittest

from tutor import bindmount


class BindmountTests(unittest.TestCase):
    def test_parse_explicit(self) -> None:
        self.assertEqual(
            [("lms", "/path/to/elearning-edx", "/openedx/elearning-edx")],
            bindmount.parse_explicit_mount(
                "lms:/path/to/elearning-edx:/openedx/elearning-edx"
            ),
        )
        self.assertEqual(
            [
                ("lms", "/path/to/elearning-edx", "/openedx/elearning-edx"),
                ("cms", "/path/to/elearning-edx", "/openedx/elearning-edx"),
            ],
            bindmount.parse_explicit_mount(
                "lms,cms:/path/to/elearning-edx:/openedx/elearning-edx"
            ),
        )
        self.assertEqual(
            [
                ("lms", "/path/to/elearning-edx", "/openedx/elearning-edx"),
                ("cms", "/path/to/elearning-edx", "/openedx/elearning-edx"),
            ],
            bindmount.parse_explicit_mount(
                "lms, cms:/path/to/elearning-edx:/openedx/elearning-edx"
            ),
        )
        self.assertEqual(
            [
                ("lms", "/path/to/elearning-edx", "/openedx/elearning-edx"),
                ("lms-worker", "/path/to/elearning-edx", "/openedx/elearning-edx"),
            ],
            bindmount.parse_explicit_mount(
                "lms,lms-worker:/path/to/elearning-edx:/openedx/elearning-edx"
            ),
        )
        self.assertEqual(
            [("lms", "/path/to/elearning-edx", "/openedx/elearning-edx")],
            bindmount.parse_explicit_mount(
                "lms,:/path/to/elearning-edx:/openedx/elearning-edx"
            ),
        )

    def test_parse_implicit(self) -> None:
        # Import module to make sure filter is created
        # pylint: disable=import-outside-toplevel,unused-import
        import tutor.commands.compose

        self.assertEqual(
            [("openedx", "/path/to/elearning-edx", "/openedx/elearning-edx")],
            bindmount.parse_implicit_mount("/path/to/elearning-edx"),
        )
