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

class TestGenerateStepsInit(unittest.TestCase):
    def assertArrayEqual(self, actual, expected, msg=None):
        """
        Custom assert method for comparing NumPy arrays.
        Provides detailed output on mismatched rows or columns.
        """
        # Ensure both arrays are Python-native strings
        actual = np.array([[str(cell) for cell in row] for row in actual])
        expected = np.array([[str(cell) for cell in row] for row in expected])

        if not np.array_equal(actual, expected):
            diff_msg = f"\nExpected Array:\n{pformat(expected.tolist())}\nActual Array:\n{pformat(actual.tolist())}"
            if msg:
                diff_msg = f"{msg}\n{diff_msg}"
            self.fail(diff_msg)

    def test_simple_addition(self):
        generator = AdditionGenerator(numbers=[5, 3])
        generator.build_grid()
        generator.solve_grid()
        generator.generate_steps_init()  # No return value, just call it
        result = generator.step_human_init  # Access the updated attribute

        expected = np.array([[' ', '5', '3', '8', ' ']])
        self.assertArrayEqual(result, expected, "Simple addition failed.")

    def test_addition_with_carry(self):
        generator = AdditionGenerator(numbers=[95, 7])
        generator.build_grid()
        generator.solve_grid()
        generator.generate_steps_init()
        result = generator.step_human_init

        expected = np.array([
            [' ', '5', '7', '2', '1'],
            ['1', '9', ' ', '0', '1'],
            ['1', ' ', ' ', '1', ' ']
        ])
        self.assertArrayEqual(result, expected, "Addition with carry failed.")

    def test_decimal_addition(self):
        generator = AdditionGenerator(numbers=[123.4, 5.6])
        generator.build_grid()
        generator.solve_grid()
        generator.generate_steps_init()
        result = generator.step_human_init

        expected = np.array([
            [' ', '4', '6', '0', '1'],
            ['1', '3', '5', '9', ' '],
            [' ', '2', ' ', '2', ' '],
            [' ', '1', ' ', '1', ' ']
        ])
        self.assertArrayEqual(result, expected, "Decimal addition failed.")

    def test_edge_case_zeros(self):
        generator = AdditionGenerator(numbers=[0, 0])
        generator.build_grid()
        generator.solve_grid()
        generator.generate_steps_init()
        result = generator.step_human_init

        expected = np.array([[' ', '0', '0', '0', ' ']])
        self.assertArrayEqual(result, expected, "Edge case with all zeros failed.")

    def test_trailing_decimals(self):
        generator = AdditionGenerator(numbers=[1.01, 0.99])
        generator.build_grid()
        generator.solve_grid()
        generator.generate_steps_init()
        result = generator.step_human_init

        expected = np.array([
            [' ', '1', '9', '0', '1'],
            ['1', '0', '9', '0', '1'],
            ['1', '1', '0', '2', ' ']
        ])
        self.assertArrayEqual(result, expected, "Trailing decimals failed.")

    def test_multiple_numbers(self):
        generator = AdditionGenerator(numbers=[123, 456, 789])
        generator.build_grid()
        generator.solve_grid()
        generator.generate_steps_init()
        result = generator.step_human_init

        expected = np.array([
            [' ', '3', '6', '9', '8', '1'],
            ['1', '2', '5', '8', '6', '1'],
            ['1', '1', '4', '7', '3', '1'],
            ['1', ' ', ' ', ' ', '1', ' ']
        ])
        self.assertArrayEqual(result, expected, "Multiple numbers failed.")

    def test_decimal_alignment(self):
        generator = AdditionGenerator(numbers=[12.34, 56.78, 90.12])
        generator.build_grid()
        generator.solve_grid()
        generator.generate_steps_init()
        result = generator.step_human_init

        expected = np.array([
            [' ', '4', '8', '2', '4', '1'],
            ['1', '3', '7', '1', '2', '1'],
            ['1', '2', '6', '0', '9', ' '],
            [' ', '1', '5', '9', '5', '1'],
            ['1', ' ', ' ', ' ', '1', ' ']
        ])
        self.assertArrayEqual(result, expected, "Decimal alignment failed.")


if __name__ == "__main__":
    unittest.main(verbosity=2)
