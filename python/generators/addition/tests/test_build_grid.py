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

class TestAdditionGenerator(unittest.TestCase):
    def assertGridEqual(self, actual, expected, msg=None):
        """
        Custom assert method to improve grid comparison readability.
        """
        # Sort keys for both actual and expected grids
        actual_sorted = {key: actual[key] for key in sorted(actual)}
        expected_sorted = {key: expected[key] for key in sorted(expected)}

        if actual_sorted != expected_sorted:
            diff_msg = (
                f"\nExpected Grid:\n{pformat(expected_sorted)}"
                f"\nActual Grid:\n{pformat(actual_sorted)}"
            )
            if msg:
                diff_msg = f"{msg}\n{diff_msg}"
            self.fail(diff_msg)

    def test_non_numeric_inputs(self):
        generator = AdditionGenerator(numbers=[12.3, "45.6"])
        with self.assertRaises(ValueError) as context:
            generator.build_grid()

        self.assertEqual(
            str(context.exception),
            "All inputs must be either integers or floats.",
            "Non-numeric input did not raise correct ValueError."
        )
    
    def test_basic_valid_input(self):
        generator = AdditionGenerator(numbers=[12.3, 45.6])
        generator.build_grid()

        expected_grid = {
            "C|": [" "] * 6,
            "1|": [" ", " ", "1", "2", ".", "3"],
            "2|": ["+", " ", "4", "5", ".", "6"],
            "A|": [" "] * 6,
        }

        self.assertGridEqual(generator.grid, expected_grid, "Basic valid input failed.")

    def test_fewer_than_two_numbers(self):
        generator = AdditionGenerator(numbers=[5])
        with self.assertRaises(ValueError) as context:
            generator.build_grid()

        self.assertEqual(
            str(context.exception),
            "Input must contain at least two numbers.",
            "Less than two numbers did not raise correct ValueError."
        )

    def test_empty_input(self):
        generator = AdditionGenerator(numbers=[])
        with self.assertRaises(ValueError, msg="Empty input should raise ValueError."):
            generator.build_grid()

    def test_mixed_data_types(self):
        generator = AdditionGenerator(numbers=[12.3, "45.6"])
        with self.assertRaises(ValueError, msg="Mixed data types should raise ValueError."):
            generator.build_grid()

    def test_negative_numbers(self):
        generator = AdditionGenerator(numbers=[-12.3, 45.6])
        with self.assertRaises(ValueError) as context:
            generator.build_grid()

        self.assertEqual(
            str(context.exception),
            "All numbers must be non-negative.",
            "Negative number input did not raise correct ValueError."
        )


    def test_very_large_numbers(self):
        generator = AdditionGenerator(numbers=[123456789, 987654321])
        generator.build_grid()

        expected_grid = {
            'C|': [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
            '1|': [' ', ' ', '1', '2', '3', '4', '5', '6', '7', '8', '9'],
            '2|': ['+', ' ', '9', '8', '7', '6', '5', '4', '3', '2', '1'],
            'A|': [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ']}


        self.assertGridEqual(generator.grid, expected_grid, "Very large numbers failed.")

    def test_long_decimal_places(self):
        generator = AdditionGenerator(numbers=[1.000001, 2.999999])
        generator.build_grid()

        expected_grid = {
            "C|": [" "] * 10,
            "1|": [" ", " ", "1", ".", "0", "0", "0", "0", "0", "1"],
            "2|": ["+", " ", "2", ".", "9", "9", "9", "9", "9", "9"],
            "A|": [" "] * 10,
        }
        

        self.assertGridEqual(generator.grid, expected_grid, "Long decimal places failed.")

    def test_trailing_zeros_in_decimals(self):
        generator = AdditionGenerator(numbers=[12.3000, 45.60])
        generator.build_grid()

        expected_grid = {
            'C|': [' ', ' ', ' ', ' ', ' ', ' '],
            '1|': [' ', ' ', '1', '2', '.', '3'],
            '2|': ['+', ' ', '4', '5', '.', '6'],
            'A|': [' ', ' ', ' ', ' ', ' ', ' ']}

        self.assertGridEqual(generator.grid, expected_grid, "Trailing zeros failed.")

    def test_all_zeros(self):
        generator = AdditionGenerator(numbers=[0, 0])
        generator.build_grid()

        expected_grid = {
            "C|": [" "] * 3,
            "1|": [" ", " ", "0"],
            "2|": ["+", " ", "0"],
            "A|": [" "] * 3,
        }

        self.assertGridEqual(generator.grid, expected_grid, "All zeros failed.")

    def test_edge_alignment_for_decimals(self):
        generator = AdditionGenerator(numbers=[0.1, 99999.9])
        generator.build_grid()

        expected_grid = {
            'C|': [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
            '1|': [' ', ' ', ' ', ' ', ' ', ' ', '0', '.', '1'],
            '2|': ['+', ' ', '9', '9', '9', '9', '9', '.', '9'],
            'A|': [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ']}

        self.assertGridEqual(
            generator.grid, expected_grid, "Edge alignment for decimals failed."
        )

    def test_multiple_numbers(self):
        generator = AdditionGenerator(numbers=[1, 2, 3, 4])
        generator.build_grid()

        expected_grid = {
            "C|": [" "] * 3,
            "1|": [" ", " ", "1"],
            "2|": [" ", " ", "2"],
            "3|": [" ", " ", "3"],
            "4|": ["+", " ", "4"],
            "A|": [" "] * 3,
        }

        self.assertGridEqual(
            generator.grid, expected_grid, "Multiple numbers failed."
        )


if __name__ == "__main__":
    unittest.main(verbosity=2)