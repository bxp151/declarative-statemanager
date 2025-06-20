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

class TestGenerateSteps(unittest.TestCase):
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

    def test_simple_addition(self):
        generator = AdditionGenerator(numbers=[123, 456])
        generator.build_grid()
        generator.solve_grid()
        generator.step_mapping_grid()
        generator.generate_steps_init()
        generator.generate_steps()

        expected_steps = {
            1: {'step_number': 1,
                'operands': ['3', '6'],
                'operation': 'Add 3 and 6',
                'calculation': '3 + 6 = 9',
                'answer': '9',
                'carry': 'No carry is needed for this step',
                'Full Text': 'Step 1\nOperation: Add 3 and 6\nCalculation: 3 + 6 = 9\nAnswer: 9\nCarry: No carry is needed for this step'},
            2: {'step_number': 2,
                'operands': ['2', '5'],
                'operation': 'Add 2 and 5',
                'calculation': '2 + 5 = 7',
                'answer': '7',
                'carry': 'No carry is needed for this step',
                'Full Text': 'Step 2\nOperation: Add 2 and 5\nCalculation: 2 + 5 = 7\nAnswer: 7\nCarry: No carry is needed for this step'},
            3: {'step_number': 3,
                'operands': ['1', '4'],
                'operation': 'Add 1 and 4',
                'calculation': '1 + 4 = 5',
                'answer': '5',
                'carry': 'No carry is needed for this step',
                'Full Text': 'Step 3\nOperation: Add 1 and 4\nCalculation: 1 + 4 = 5\nAnswer: 5\nCarry: No carry is needed for this step'}}



        self.assertEqual(generator.step_human, expected_steps, "Simple addition test failed.")

    def test_addition_with_carry(self):
        generator = AdditionGenerator(numbers=[95, 7])
        generator.build_grid()
        generator.solve_grid()
        generator.step_mapping_grid()
        generator.generate_steps_init()
        generator.generate_steps()

        expected_steps = {
            1: {'step_number': 1,
                'operands': ['5', '7'],
                'operation': 'Add 5 and 7',
                'calculation': '5 + 7 = 2',
                'answer': '2',
                'carry': 'Enter 1 in the carry row for the next column',
                'Full Text': 'Step 1\nOperation: Add 5 and 7\nCalculation: 5 + 7 = 2\nAnswer: 2\nCarry: Enter 1 in the carry row for the next column'},
            2: {'step_number': 2,
                'operands': ['1', '9'],
                'operation': 'Add 1 and 9',
                'calculation': '1 + 9 = 0',
                'answer': '0',
                'carry': 'Enter 1 in the carry row for the next column',
                'Full Text': 'Step 2\nOperation: Add 1 and 9\nCalculation: 1 + 9 = 0\nAnswer: 0\nCarry: Enter 1 in the carry row for the next column'},
            3: {'step_number': 3,
                'operands': ['1'],
                'operation': 'Add 1 and nothing',
                'calculation': '1 + nothing = 1',
                'answer': '1',
                'carry': 'No carry is needed for this step',
                'Full Text': 'Step 3\nOperation: Add 1 and nothing\nCalculation: 1 + nothing = 1\nAnswer: 1\nCarry: No carry is needed for this step'}}


        self.assertEqual(generator.step_human, expected_steps, "Addition with carry test failed.")

    def test_decimal_addition(self):
        generator = AdditionGenerator(numbers=[123.4, 5.6])
        generator.build_grid()
        generator.solve_grid()
        generator.step_mapping_grid()
        generator.generate_steps_init()
        generator.generate_steps()

        expected_steps = {
            1: {'step_number': 1,
                'operands': ['4', '6'],
                'operation': 'Add 4 and 6',
                'calculation': '4 + 6 = 0',
                'answer': '0',
                'carry': 'Enter 1 in the carry row for the next column',
                'Full Text': 'Step 1\nOperation: Add 4 and 6\nCalculation: 4 + 6 = 0\nAnswer: 0\nCarry: Enter 1 in the carry row for the next column'},
            2: {'step_number': 2,
                'operands': ['1', '3', '5'],
                'operation': 'Add 1 and 3 and 5',
                'calculation': '1 + 3 + 5 = 9',
                'answer': '9',
                'carry': 'No carry is needed for this step',
                'Full Text': 'Step 2\nOperation: Add 1 and 3 and 5\nCalculation: 1 + 3 + 5 = 9\nAnswer: 9\nCarry: No carry is needed for this step'},
            3: {'step_number': 3,
                'operands': ['2'],
                'operation': 'Add 2 and nothing',
                'calculation': '2 + nothing = 2',
                'answer': '2',
                'carry': 'No carry is needed for this step',
                'Full Text': 'Step 3\nOperation: Add 2 and nothing\nCalculation: 2 + nothing = 2\nAnswer: 2\nCarry: No carry is needed for this step'},
            4: {'step_number': 4,
                'operands': ['1'],
                'operation': 'Add 1 and nothing',
                'calculation': '1 + nothing = 1',
                'answer': '1',
                'carry': 'No carry is needed for this step',
                'Full Text': 'Step 4\nOperation: Add 1 and nothing\nCalculation: 1 + nothing = 1\nAnswer: 1\nCarry: No carry is needed for this step'}}


        self.assertEqual(generator.step_human, expected_steps, "Decimal addition test failed.")

if __name__ == "__main__":
    unittest.main(verbosity=2)
