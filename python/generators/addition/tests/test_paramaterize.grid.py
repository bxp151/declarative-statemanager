import unittest
import numpy as np
from pprint import pformat  # For cleaner diff output
import os
import sys

# Get the current script's directory
current_dir = os.path.dirname(os.path.abspath(__file__))

# Navigate one level up
parent_dir = os.path.dirname(current_dir)

# Append the parent directory to sys.path
sys.path.append(parent_dir)
print(sys.path) 

from python.generators.addition.addition_generator import AdditionGenerator  # Adjust this import as needed

class TestParameterizeGrid(unittest.TestCase):
    def assertGridEqual(self, actual, expected, msg=None):
        """
        Custom assert method to improve grid comparison readability.
        """
        if actual != expected:
            diff_msg = (
                f"\nExpected Grid:\n{pformat(expected)}"
                f"\nActual Grid:\n{pformat(actual)}"
            )
            if msg:
                diff_msg = f"{msg}\n{diff_msg}"
            self.fail(diff_msg)

    def test_simple_addition_no_carry(self):
        generator = AdditionGenerator(numbers=[2, 3])
        generator.build_grid()
        generator.solve_grid()
        generator.parameterize_grid()

        expected = {
            "C|": [" ", " ", " "],
            "1|": [" ", " ", "2"],
            "2|": ["+", " ", "3"],
            "A|": [" ", " ", "A"],
        }
        self.assertGridEqual(generator.param_grid, expected, "Simple addition with no carry failed.")

    def test_addition_with_carry(self):
        generator = AdditionGenerator(numbers=[9, 5])
        generator.build_grid()
        generator.solve_grid()
        generator.parameterize_grid()

        expected = {
            "C|": [" ", "C", " "],
            "1|": [" ", " ", "9"],
            "2|": ["+", " ", "5"],
            "A|": [" ", "A", "B"],
        }
        self.assertGridEqual(generator.param_grid, expected, "Addition with carry failed.")

    def test_decimal_addition(self):
        generator = AdditionGenerator(numbers=[1.2, 3.4])
        generator.build_grid()
        generator.solve_grid()
        generator.parameterize_grid()

        expected = {
            "C|": [" ", " ", " ", " ", " "],
            "1|": [" ", " ", "1", ".", "2"],
            "2|": ["+", " ", "3", ".", "4"],
            "A|": [" ", " ", "A", ".", "B"],
        }
        self.assertGridEqual(generator.param_grid, expected, "Decimal addition failed.")

    def test_addition_with_multiple_carries(self):
        generator = AdditionGenerator(numbers=[95, 7])
        generator.build_grid()
        generator.solve_grid()
        generator.parameterize_grid()

        expected = {
            "C|": [" ", "D", "E", " "],
            "1|": [" ", " ", "9", "5"],
            "2|": ["+", " ", " ", "7"],
            "A|": [" ", "A", "B", "C"],
        }
        self.assertGridEqual(generator.param_grid, expected, "Addition with multiple carries failed.")

    def test_large_numbers(self):
        generator = AdditionGenerator(numbers=[123, 456])
        generator.build_grid()
        generator.solve_grid()
        generator.parameterize_grid()

        expected = {
            "C|": [" ", " ", " ", " ", " "],
            "1|": [" ", " ", "1", "2", "3"],
            "2|": ["+", " ", "4", "5", "6"],
            "A|": [" ", " ", "A", "B", "C"],
        }
        self.assertGridEqual(generator.param_grid, expected, "Addition with large numbers failed.")


if __name__ == "__main__":
    unittest.main(verbosity=2)
