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

class TestSolveGrid(unittest.TestCase):
    def assertGridEqual(self, actual, expected, msg=None):
        """
        Custom assert method to improve grid comparison readability.
        """
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

    def test_simple_addition(self):
        generator = AdditionGenerator(numbers=[1, 2])
        generator.build_grid()
        generator.solve_grid()

        expected_grid = {
            "C|": [" ", " ", " "],
            "1|": [" ", " ", "1"],
            "2|": ["+", " ", "2"],
            "A|": [" ", " ", "3"],
        }

        self.assertGridEqual(generator.solved_grid, expected_grid, "Simple addition failed.")

    def test_addition_with_carry(self):
        generator = AdditionGenerator(numbers=[9, 5])
        generator.build_grid()
        generator.solve_grid()

        expected_grid = {
            "C|": [" ", "1", " "],
            "1|": [" ", " ", "9"],
            "2|": ["+", " ", "5"],
            "A|": [" ", "1", "4"],
        }

        self.assertGridEqual(generator.solved_grid, expected_grid, "Addition with carry failed.")

    def test_decimal_addition(self):
        generator = AdditionGenerator(numbers=[1.2, 3.4])
        generator.build_grid()
        generator.solve_grid()

        expected_grid = {
            "C|": [" ", " ", " ", " ", " "],
            "1|": [" ", " ", "1", ".", "2"],
            "2|": ["+", " ", "3", ".", "4"],
            "A|": [" ", " ", "4", ".", "6"],
        }

        self.assertGridEqual(generator.solved_grid, expected_grid, "Decimal addition failed.")

    def test_decimal_with_carry(self):
        generator = AdditionGenerator(numbers=[9.9, 0.1])
        generator.build_grid()
        generator.solve_grid()

        expected_grid = {
        'C|': [' ', '1', '1', ' ', ' '],
        '1|': [' ', ' ', '9', '.', '9'],
        '2|': ['+', ' ', '0', '.', '1'],
        'A|': [' ', '1', '0', '.', '0']}

        self.assertGridEqual(generator.solved_grid, expected_grid, "Decimal addition with carry failed.")

    def test_multiple_carries(self):
        generator = AdditionGenerator(numbers=[95, 7])
        generator.build_grid()
        generator.solve_grid()

        expected_grid = {
            'C|': [' ', '1', '1', ' '],
            '1|': [' ', ' ', '9', '5'],
            '2|': ['+', ' ', ' ', '7'],
            'A|': [' ', '1', '0', '2']
        }
                    

        self.assertGridEqual(generator.solved_grid, expected_grid, "Multiple carries failed.")

    def test_trailing_zeros(self):
        generator = AdditionGenerator(numbers=[12.300, 45.600])
        generator.build_grid()
        generator.solve_grid()

        expected_grid = {
            "C|": [" ", " ", " ", " ", " ", " "],
            "1|": [" ", " ", "1", "2", ".", "3"],
            "2|": ["+", " ", "4", "5", ".", "6"],
            "A|": [" ", " ", "5", "7", ".", "9"],
        }

        

        self.assertGridEqual(generator.solved_grid, expected_grid, "Trailing zeros failed.")

    def test_large_numbers(self):
        generator = AdditionGenerator(numbers=[123456789, 987654321])
        generator.build_grid()
        generator.solve_grid()

        expected_grid = {
            'C|': [' ', '1', '1', '1', '1', '1', '1', '1', '1', '1', ' '],
            '1|': [' ', ' ', '1', '2', '3', '4', '5', '6', '7', '8', '9'],
            '2|': ['+', ' ', '9', '8', '7', '6', '5', '4', '3', '2', '1'],
            'A|': [' ', '1', '1', '1', '1', '1', '1', '1', '1', '1', '0']}

        self.assertGridEqual(generator.solved_grid, expected_grid, "Large numbers failed.")

    def test_all_zeros(self):
        generator = AdditionGenerator(numbers=[0, 0])
        generator.build_grid()
        generator.solve_grid()

        expected_grid = {
            "C|": [" ", " ", " "],
            "1|": [" ", " ", "0"],
            "2|": ["+", " ", "0"],
            "A|": [" ", " ", "0"],
        }

        self.assertGridEqual(generator.solved_grid, expected_grid, "All zeros failed.")


    def test_three_large_numbers_with_carry(self):
        generator = AdditionGenerator(numbers=[999999, 888888, 777777])
        generator.build_grid()
        generator.solve_grid()

        expected_grid = {
            'C|': [' ', '2', '2', '2', '2', '2', '2', ' '],
            '1|': [' ', ' ', '9', '9', '9', '9', '9', '9'],
            '2|': [' ', ' ', '8', '8', '8', '8', '8', '8'],
            '3|': ['+', ' ', '7', '7', '7', '7', '7', '7'],
            'A|': [' ', '2', '6', '6', '6', '6', '6', '4']
        }

        self.assertGridEqual(generator.solved_grid, expected_grid, "Three large numbers with carry failed.")

    def test_large_numbers_with_decimals_no_carry(self):
        generator = AdditionGenerator(numbers=[123456.789, 98765.4321])
        generator.build_grid()
        generator.solve_grid()

        expected_grid = {
            'C|': [' ', ' ', '1', '1', '1', '1', '1', '1', ' ', '1', '1', ' ', ' '],
            '1|': [' ', ' ', '1', '2', '3', '4', '5', '6', '.', '7', '8', '9', ' '],
            '2|': ['+', ' ', ' ', '9', '8', '7', '6', '5', '.', '4', '3', '2', '1'],
            'A|': [' ', ' ', '2', '2', '2', '2', '2', '2', '.', '2', '2', '1', '1']
            }

        self.assertGridEqual(generator.solved_grid, expected_grid, "Large numbers with decimals (no carry) failed.")

    def test_large_numbers_with_decimals_and_carry(self):
        generator = AdditionGenerator(numbers=[99999.9999, 0.0001])
        generator.build_grid()
        generator.solve_grid()

        expected_grid = {
            'C|': [' ', '1', '1', '1', '1', '1', '1', ' ', '1', '1', '1', ' '],
            '1|': [' ', ' ', '9', '9', '9', '9', '9', '.', '9', '9', '9', '9'],
            '2|': ['+', ' ', ' ', ' ', ' ', ' ', '0', '.', '0', '0', '0', '1'],
            'A|': [' ', '1', '0', '0', '0', '0', '0', '.', '0', '0', '0', '0']
        }

        self.assertGridEqual(generator.solved_grid, expected_grid, "Large numbers with decimals and carry failed.")

if __name__ == "__main__":
    unittest.main(verbosity=2)
