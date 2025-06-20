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

class TestStepMappingGrid(unittest.TestCase):
    def assertGridEqual(self, actual, expected, msg=None):
        """
        Custom assert method to improve grid comparison readability.
        """
        if not np.array_equal(actual, expected):
            diff_msg = (
                f"\nExpected Grid:\n{pformat(expected.tolist())}"
                f"\nActual Grid:\n{pformat(actual.tolist())}"
            )
            if msg:
                diff_msg = f"{msg}\n{diff_msg}"
            self.fail(diff_msg)

    def test_simple_addition_of_two_integers(self):
        generator = AdditionGenerator(numbers=[123, 456])
        generator.build_grid()
        generator.solve_grid()
        generator.step_mapping_grid()

        expected = np.array([
            [' ', ' ', ' ', ' ', ' '],
            [' ', ' ', '3', '2', '1'],
            [' ', ' ', '3', '2', '1'],
            [' ', ' ', '3', '2', '1']], dtype=object)
        self.assertGridEqual(generator.step_map, expected, "Simple addition of two integers without decimals failed.")

    def test_addition_of_two_numbers_with_decimals(self):
        generator = AdditionGenerator(numbers=[123.45, 67.8])
        generator.build_grid()
        generator.solve_grid()
        generator.step_mapping_grid()

        expected = np.array([
            [' ', ' ', ' ', '3', '2', ' ', ' ', ' '],
            [' ', ' ', '5', '4', '3', ' ', '2', '1'],
            [' ', ' ', ' ', '4', '3', ' ', '2', ' '],
            [' ', ' ', '5', '4', '3', ' ', '2', '1']], dtype=object)
        self.assertGridEqual(generator.step_map, expected, "Addition of two numbers with decimals failed.")

    def test_carry_over_at_decimal_point(self):
        generator = AdditionGenerator(numbers=[0.99, 0.01])
        generator.build_grid()
        generator.solve_grid()
        generator.step_mapping_grid()

        expected = np.array([
            [' ', ' ', '2', ' ', '1', ' '],
            [' ', ' ', '3', ' ', '2', '1'],
            [' ', ' ', '3', ' ', '2', '1'],
            [' ', ' ', '3', ' ', '2', '1']], dtype=object)
        self.assertGridEqual(generator.step_map, expected, "Carry over occurs at the decimal point failed.")

    def test_multiple_integer_additions_with_carry_over(self):
        generator = AdditionGenerator(numbers=[999, 1, 1000])
        generator.build_grid()
        generator.solve_grid()
        generator.step_mapping_grid()

        expected = np.array([
            [' ', ' ', '3', '2', '1', ' '],
            [' ', ' ', ' ', '3', '2', '1'],
            [' ', ' ', ' ', ' ', ' ', '1'],
            [' ', ' ', '4', '3', '2', '1'],
            [' ', ' ', '4', '3', '2', '1']], dtype=object)
        self.assertGridEqual(generator.step_map, expected, "Multiple integer additions with carry over failed.")

    def test_addition_of_numbers_with_decimals_only(self):
        generator = AdditionGenerator(numbers=[0.1, 0.2, 0.3])
        generator.build_grid()
        generator.solve_grid()
        generator.step_mapping_grid()

        expected = np.array([
            [' ', ' ', ' ', ' ', ' '],
            [' ', ' ', '2', ' ', '1'],
            [' ', ' ', '2', ' ', '1'],
            [' ', ' ', '2', ' ', '1'],
            [' ', ' ', '2', ' ', '1']], dtype=object)
        self.assertGridEqual(generator.step_map, expected, "Addition of numbers with decimals only failed.")

    def test_addition_of_very_large_integers(self):
        generator = AdditionGenerator(numbers=[999999999, 1])
        generator.build_grid()
        generator.solve_grid()
        generator.step_mapping_grid()

        expected = np.array([
            [' ', '9', '8', '7', '6', '5', '4', '3', '2', '1', ' '],
            [' ', ' ', '9', '8', '7', '6', '5', '4', '3', '2', '1'],
            [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '1'],
            [' ', '10', '9', '8', '7', '6', '5', '4', '3', '2', '1']], dtype=object)
        self.assertGridEqual(generator.step_map, expected, "Addition of very large integers with carry across all digits failed.")

    def test_addition_with_zero(self):
        generator = AdditionGenerator(numbers=[123, 0, 456])
        generator.build_grid()
        generator.solve_grid()
        generator.step_mapping_grid()

        expected = np.array([
            [' ', ' ', ' ', ' ', ' '],
            [' ', ' ', '3', '2', '1'],
            [' ', ' ', ' ', ' ', '1'],
            [' ', ' ', '3', '2', '1'],
            [' ', ' ', '3', '2', '1']], dtype=object)
        self.assertGridEqual(generator.step_map, expected, "Addition where one of the numbers is zero failed.")

    def test_mixed_integer_and_decimal_addition(self):
        generator = AdditionGenerator(numbers=[123.45, 678, 0.123])
        generator.build_grid()
        generator.solve_grid()
        generator.step_mapping_grid()

        expected = np.array([
            [' ', ' ', '5', '4', ' ', ' ', ' ', ' ', ' '],
            [' ', ' ', '6', '5', '4', ' ', '3', '2', ' '],
            [' ', ' ', '6', '5', '4', ' ', ' ', ' ', ' '],
            [' ', ' ', ' ', ' ', '4', ' ', '3', '2', '1'],
            [' ', ' ', '6', '5', '4', ' ', '3', '2', '1']], dtype=object)
        self.assertGridEqual(generator.step_map, expected, "Addition of numbers with mixed integer and decimal parts failed.")

    def test_single_digit_addition_with_carry(self):
        generator = AdditionGenerator(numbers=[5, 9])
        generator.build_grid()
        generator.solve_grid()
        generator.step_mapping_grid()

        expected = np.array([
            [' ', '1', ' '],
            [' ', ' ', '1'],
            [' ', ' ', '1'],
            [' ', '2', '1']], dtype=object)
        self.assertGridEqual(generator.step_map, expected, "Addition of single-digit numbers with carry failed.")

    def test_addition_where_all_numbers_are_zero(self):
        generator = AdditionGenerator(numbers=[0, 0, 0])
        generator.build_grid()
        generator.solve_grid()
        generator.step_mapping_grid()

        expected = np.array([
            [' ', ' ', ' '],
            [' ', ' ', '1'],
            [' ', ' ', '1'],
            [' ', ' ', '1'],
            [' ', ' ', '1']], dtype=object)
        self.assertGridEqual(generator.step_map, expected, "Addition where all numbers are zero failed.")

if __name__ == "__main__":
    unittest.main(verbosity=2)
