import copy
import numpy as np  
import json
from utils.utils import Utils


class AdditionGenerator:
    
    """
 A class to generate and process structured data for addition problems.

    This class provides a pipeline for generating structured, explainable addition problems.

    JSON / Python Dictionary Pipeline:
        Step 1 (build_grid): 
            Constructs an aligned grid from the input numbers for column-wise addition.

        Step 2 (solve_grid): 
            Solves the grid by performing column-wise addition with carries, 
            and generates a cleaned version of the solved grid.

        Step 3 (parameterize_grid): 
            Generates multiple parameterized versions of the grid 
            (e.g., full, answer-only, operand-only, carry-only).

        Step 4 (step_mapping_grid): 
            Assigns step numbers to each column in the grid to reflect the 
            order of human computation.

        Step 5 (generate_steps_init): 
            Prepares a structured representation of the grid 
            for generating human-readable steps.

        Step 6 (generate_steps): 
            Produces human-readable instructions and feedback for each step 
            of the addition process.

        Step 7 (build_python_output): 
            Combines all processed data into a unified dictionary 
            for use in downstream applications (e.g., Flutter frontend).

        Step 8 (pack_for_json): 
            Serializes the unified dictionary into a JSON-compatible format.

        Step 9 (generate_addition_problems(numbers, output_format) ):
            High-level static method to run the full pipeline and return the output in 
            either Python dict or JSON string format.

    
        
    Static & Helper Methods:

    - validate_inputs():
        Ensures that the input list is valid—contains at least two non-negative ints or floats.

    - grid_cleaner(param_grid):
        Formats a grid by adjusting the '+' symbol placement and trimming leading blanks 
        when appropriate.

    - map_steps_to_positions(param_grid, step_map):
        Maps step numbers to placeholder positions (e.g., 'A3', 'C5') in the parameterized grid.

    - convert_array_to_dict(array, keys):
        Converts a 2D NumPy array into a dictionary keyed by row labels.

    Attributes:
        answer (float | int): The final computed answer from the solved grid.
        num_answer_digits (int | None): The number of answer digits.
        num_operand_rows (int | None): The number of operand rows.
        grid (dict | None): The initial aligned grid created in build_grid().
        has_carry (bool | None): Whether any carry values were needed in the solution.
        has_decimal (bool | None): Whether any input numbers contained a decimal.
        json_output (str | None): JSON-serialized version of the final output dictionary.
        max_dec_digits (int | None): Max number of decimal digits found in any operand.
        max_int_digits (int | None): Max number of integer digits found in any operand.
        grade_level (int | None): Inferred grade level (K=0, 1-5) based on problem complexity and standards.
        num_operand_digits (int | None): Total count of numeric digits across all operands (excluding decimals).
        numbers (list): The original list of input numbers for the addition problem.
        param_grids_carry_exposed (dict | None): Dictionary containing all carry explosed parameterized 
                                                 grid variants and their metadata.
        param_grids_carry_hidden (dict | None): Dictionary containing all carry hidden parameterized 
                                                 grid variants and their metadata.
        problem_nospace (str | None): A string representation of the problem without spaces (e.g., "23+7").
        problem_space (str | None): A human-readable version of the problem with spaces (e.g., "23 + 7").
        problem_structure_id (str | None): SHA-1 hash of string "digits-addends-carry"
        python_output (dict | None): Unified output dictionary assembled for frontend use.
        solved_grid (dict | None): Grid populated with digits and carry values after solving.
        solved_grid_clean (dict | None): Cleaned version of the solved grid used for parameterization.
        step_human (dict | None): Dictionary of human-readable step explanations.
        step_human_init (np.ndarray | None): Grid used to generate human-readable steps.
        step_map (np.ndarray | None): Grid assigning step numbers to columns.

        
    """
    # Initialize the class and its attributes
    def __init__(self, numbers: list):
        """
        Initializes the AdditionGenerator with a list of input numbers.

        Args:
            numbers (list): A list of non-negative integers or floats to be added.

        Initializes:
            - numbers (list): Raw input numbers.
            - num_answer_digits (int | None): Number of answer digits after adding number.
            - num_operand_rows (int | None): The number of operand rows.
            - problem_nospace (str | None): Problem string without spaces (e.g., "23+7").
            - problem_space (str | None): Human-readable problem string with spaces (e.g., "23 + 7").
            - grid (dict | None): Initial aligned grid (set in build_grid).
            - grade_level (int | None): Inferred grade level (K=0, 1-5) based on problem complexity and standards.
            - solved_grid (dict | None): Grid with computed answers and carries (set in solve_grid).
            - solved_grid_clean (dict | None): Cleaned solved grid (set in solve_grid).
            - param_grids_carry_exposed (dict | None): All parameterized variations of the problem (set in parameterize_grid).
            - step_map (np.ndarray | None): Grid with column-based step numbers (set in step_mapping_grid).
            - step_human (dict | None): Human-readable step-by-step breakdowns (set in generate_steps).
            - step_human_init (np.ndarray | None): Intermediate matrix for generating steps (set in generate_steps_init).
            - problem_structure_id (str | None): SHA-1 hash of string "digits-addends-carry"
            - python_output (dict | None): Final output dictionary (set in build_python_output).
            - json_output (str | None): Serialized JSON version of output (set in pack_for_json).
            - max_int_digits (int | None): Maximum number of integer digits in operands.
            - max_dec_digits (int | None): Maximum number of decimal digits in operands.
            - has_decimal (bool | None): Whether any input contains a decimal.
            - has_carry (bool | None): Whether the solution includes any carries.
            - answer (float | int | None): Computed result of the addition problem.
            - num_operand_digits (int | None): Total digit count across all operands.
        """
        # EXISTING
        self.numbers: list = numbers  # Inputs
        self.num_answer_digits: int | None = None 
        self.num_operand_rows: int | None = None
        self.grade_level: int | None = None  # Set in set_grade_level()
        self.problem_nospace: str | None = None # Placeholder for the problem with no spaces.
        self.problem_space: str | None = None # Placeholder for the problem with spaces.
        self.problem_id: str | None = None # Hashed SHA-1 of self.problem_nospace
        self.problem_structure_id: str | None = None # SHA-1 of problem structure (digits-addends-carry)
        self.grid: dict | None = None  # Placeholder for the initial grid.
        self.solved_grid: dict | None = None  # Placeholder for the solved grid.
        self.param_grids_carry_exposed: dict | None = None  # Placeholder for the parameterized grids.
        self.param_grids_carry_hidden: dict | None = None  # Placeholder for the parameterized grids.
        self.step_map: any = None  # Placeholder for the step-to-column mapping.
        self.step_human: list | None = None  # Placeholder for human-readable explanations.
        self.python_output: dict | None = None  # Placeholder for the final unified lookup table.
        self.max_dec_digits: int | None = None # Computed in build_grid().
        self.has_decimal: bool | None = None  # Computed in build_grid().
        self.has_carry: bool | None = None  # Computed in solve_grid().
        self.answer: float | None = None  # Computed in solve_grid().
        self.num_operand_digits: int | None = None # Computed in build_grid().
        self.max_int_digits: int | None = None  # Computed in build_grid().
        self.solved_grid_clean: dict | None = None # Computed in solve_grid().
        self.sub_level_score: int | None = None
        self.digit_count_of_sum()  # Sets self.num_answer_digits immediately
        self.num_operand_rows = len(self.numbers)
        

   
    def digit_count_of_sum(self):
        """
        Computes the number of digits in the sum of the instance's numbers,
        excluding any decimal points, and stores the result in self.num_answer_digits.

        Modifies:
            self.num_answer_digits (int): The number of digits in the summed result,
            excluding any decimal points.

        Returns:
            None
        """
        total = sum(self.numbers)
        self.num_answer_digits = len(str(total).replace('.', ''))

    @staticmethod
    def map_steps_to_positions(param_grid, step_map):
        """
        Maps steps to positions in the parameterized grid.

        Args:
            param_grid (dict): The parameterized grid.
            step_map (numpy.ndarray): The mapping of steps to positions, as a 2D array.

        Returns:
            dict: A dictionary where keys are step numbers and values are lists
                of positions in the grid corresponding to those steps.
        """
        step_to_position = {}

        # Iterate over each key-value pair in param_grid
        for row_index, (row_key, param_list) in enumerate(param_grid.items()):
            for col_index, value in enumerate(param_list):
                # If the value is a letter (A-Z), proceed
                if value.isalpha():
                    # Get the corresponding step from step_map
                    step_number = step_map[row_index, col_index]
                    if step_number != " ":
                        # Store the step number and the position
                        position = f"{row_key}{col_index}"
                        if int(step_number) not in step_to_position:
                            step_to_position[int(step_number)] = []
                        step_to_position[int(step_number)].append(position)

        return step_to_position


    def validate_inputs(self):
        # Check for at least two numbers
        if not self.numbers or len(self.numbers) < 2:
            raise ValueError("Input must contain at least two numbers.")
        
        # Check that all inputs are integers or floats
        if not all(isinstance(num, (int, float)) for num in self.numbers):
            raise ValueError("All inputs must be either integers or floats.")
        
        # Check that all numbers are non-negative
        if not all(num >= 0 for num in self.numbers):
            raise ValueError("All numbers must be non-negative.")
        
    def set_grade_level(self) -> None:
        """
        Determines the grade level (K-5) for the addition problem based on:
            - max_dec_digits: Maximum number of decimal digits in the problem.
            - answer: Final computed sum of the problem.

        Grade levels:
            - 0 = Kindergarten
            - 1 = Grade 1
            - 2 = Grade 2
            - 3 = Grade 3
            - 4 = Grade 4
            - 5 = Grade 5
            - -1 = Unclassified or beyond grade 5
        """
        if self.max_dec_digits == 0 and 0 <= self.answer < 10:
            self.grade_level = 0
        elif self.max_dec_digits == 0 and 10 <= self.answer <= 20:
            self.grade_level = 1
        elif self.max_dec_digits == 0 and 20 < self.answer <= 100:
            self.grade_level = 2
        elif self.max_dec_digits == 0 and 100 < self.answer <= 999:
            self.grade_level = 3
        elif self.max_dec_digits == 2 and self.answer <= 10_000:
            self.grade_level = 4
        elif self.max_dec_digits <= 2 and self.answer <= 100_000:
            self.grade_level = 5
        else:
            self.grade_level = -1


    def calculate_subLevel_score(self) -> int:
        """
        Calculates a sub-level difficulty score based on carry and operand count.

        Returns:
            int: Composite sub-level score.
        """
        carry_score = 1 if self.has_carry else 0
        num_operand_rows_score = max(0, self.num_operand_rows - 2)

        self.sub_level_score = carry_score + num_operand_rows_score



    def calculate_paramLevel_score(self, num_parameters: int, param_type: str) -> int:
        """
        Calculates a parameter-level score based on parameterization characteristics.

        Returns:
            int: Parameter difficulty score.
        """
        match param_type:
            case "full" | "answer":
                return 0
            case "carry":
                return 1
            case "operand":
                return num_parameters + 1
            case _:
                raise ValueError(f"Unknown param_type: {param_type}")



    def grid_cleaner(param_grid):
        """
        Processes a grid structure by performing the following steps:
            - Identifies the highest numbered key.
            - Finds the index of the first non-space character in the highest numbered key's list.
            - Adds a '+' at the index immediately before the first non-space character, if applicable.
            - Pops the first index of each list only if all lists have their first position as empty (' ').

        Modifies:
            - The input dictionary by adding a '+' in the described manner and conditionally removing the first element of each list.

        Args:
            param_grid (dict): The input grid to process.

        Returns:
            dict: The modified dictionary after processing.

        Raises:
            None: Assumes the input structure is valid.
        """

        # Identify the highest numbered key
        numbered_keys = [key for key in param_grid if key[:-1].isdigit()]
        highest_numbered_key = max(numbered_keys, key=lambda k: int(k[:-1]))
        # print(f"Highest numbered key: {highest_numbered_key}")

        # Find the index of the highest key list that is populated with a non-space (excluding '+')
        highest_row = param_grid[highest_numbered_key]

        # Delete the + in the highest_row first
        if '+' in highest_row:
            highest_row[highest_row.index('+')] = ' '

        populated_index = next((i for i, value in enumerate(highest_row) if value.strip() and value != '+'), -1)
        # print(f"Index of first non-space in the highest numbered key: {populated_index}")

        # Add a '+' at index - 1 of the highest numbered key / non-space index
        if populated_index > 0:
            highest_row[populated_index - 1] = '+'

        # Check if all lists have their first position as empty (' ')
        if all(row[0] == ' ' for row in param_grid.values() if row):
            for key in param_grid:
                if param_grid[key]:
                    param_grid[key].pop(0)

        return param_grid


    # Step 0: Build the problem string
    def build_problem(self):
        """
        Creates a human-readable problem string from a list of numbers.

        This method constructs a problem string by joining the input numbers
        with a '+' operator and returns it for display.

        Modifies:
            - self.problem_nospace (str): Sets it to a formatted string representing the problem with no spaces.
            - self.problem_space (str): Sets it to a formatted string representing the problem with spaces.
        Args:
            None: Uses self.numbers to create the problem string.

        Returns:
            None: This method modifies self.problem_nospace and self.problem_space directly.


        Raises:
            ValueError: If the input list (self.numbers) is empty or contains mixed data types.
        """
        # Step 0: Ensure valid inputs
        self.validate_inputs()

        # Convert all numbers to strings for concatenation
        numbers = [str(num) for num in self.numbers]

        # Join the numbers with a '+' operator
        self.problem_nospace = "+".join(numbers)
        self.problem_space = " + ".join(numbers)
        self.problem_id = Utils.generate_sha1(self.problem_nospace)

    # Step 1: Build the grid
    def build_grid(self):
        """
        Creates the initial grid structure for performing addition step-by-step.

        This method ensures that all rows have equal length, decimals are aligned, 
        and the "+" operator is dynamically placed in the last number row. It prepares 
        the grid for further processing in the addition pipeline.

        Modifies:
            - self.grid (dict): Sets it to a dictionary representing the grid with labeled rows:
                - "C|": Carry row, initialized with placeholders.
                - "1|", "2|", ...: Number rows for each input number, with "+" in the last numbered row.
                - "A|": Answer row, initialized with placeholders.

        Args:
            None: Uses self.numbers to create the grid.

        Returns:
            None: This method modifies self.grid directly.

        Raises:
            ValueError: If the input list (self.numbers) is empty, contains fewer than two valid numbers,
                        or includes mixed data types.
        """
        # Step 0: Ensure valid inputs
        self.validate_inputs()

        # Convert all numbers to strings for further processing
        numbers = [str(num) for num in self.numbers]
        
        # Calcualte total operands (minus decimals) 
        self.num_operand_digits = sum(len(num.replace('.', '')) for num in numbers)
    
        # Step 1: Split all numbers into integer and decimal parts
        split_numbers = [num.split('.') if '.' in num else (num, '') for num in numbers]

        # Step 2: Determine maximum decimal and integer lengths
        max_int_len = max(len(num[0]) for num in split_numbers)
        max_dec_len = max(len(num[1]) for num in split_numbers)

        # Set max_int_digits and max_dec_digits
        self.max_int_digits = max_int_len
        self.max_dec_digits = max_dec_len

        # Set has_decimal
        if max_dec_len > 0:
            self.has_decimal = True
        else:
            self.has_decimal = False

        # Step 3: Pad all numbers to align decimals with spaces
        aligned_numbers = [
            (num[0].rjust(max_int_len, ' '), num[1].ljust(max_dec_len, ' '))
            for num in split_numbers
        ]

        # Step 4: Combine integer and decimal parts into full numbers
        full_numbers = [
            int_part + ('.' + dec_part if max_dec_len > 0 else '')
            for int_part, dec_part in aligned_numbers
        ]

        # Step 5: Determine the grid width (includes operator and carry spillover columns)
        grid_width = max(len(num) for num in full_numbers) + 2

        # Step 6: Right-align numbers and ensure consistent length
        aligned_full_numbers = [num.rjust(grid_width - 1, ' ') for num in full_numbers]

        # Step 7: Initialize the grid with dynamic rows for numbers and place "+" in the last row
        self.grid = {
            "C|": [" "] * grid_width,  # Carry Row
            **{
                f"{i + 1}|": ([" "] if i != len(aligned_full_numbers) - 1 else ["+"]) + list(num.ljust(grid_width - 1, ' '))
                for i, num in enumerate(aligned_full_numbers)
            },
            "A|": [" "] * grid_width  # Answer Row
        }


    # Step 2: Solve the grid
    def solve_grid(self):
        """
        Computes column-wise addition with carries and updates the grid with results.

        This method performs addition from right to left across all columns of the number rows,
        dynamically handling carries and preserving decimal alignment. The results are stored in 
        the answer row, and carries are placed in the carry row. Decimal points are preserved 
        in their original positions.

        Preconditions:
            - `self.grid` must be initialized with a valid grid structure created by `build_grid()`.
            - All rows in the grid must have the same width.
            - Decimals must already be aligned, if present.

        Modifies:
            - `self.solved_grid` (dict): Updates the grid with computed carries and answer values.

        Args:
            None

        Returns:
            None

        Raises:
            - ValueError: If `self.grid` is uninitialized or does not meet the expected format.
            - IndexError: If a decimal index is incorrectly calculated due to misaligned rows.

        Notes:
            - The decimal column (if present) is skipped during addition but preserved in the
            answer row.
            - Carries are propagated leftward, skipping the decimal column if necessary.
            - The operator column (first column) is ignored for computations and left blank
            in the answer row.
        """
    
        # Create a deep copy of the grid to preserve the original
        grid_copy = copy.deepcopy(self.grid)
        
        # Extract relevant rows
        carry_row = grid_copy["C|"]
        answer_row = grid_copy["A|"]
        number_rows = {k: v for k, v in grid_copy.items() if k not in {"C|", "A|"}}

        # Precompute the decimal index from the first number row (assumes consistent decimal alignment)
        decimal_index = next(iter(number_rows.values())).index('.') if '.' in next(iter(number_rows.values())) else -1

        # Initialize carry and iterate from right to left
        carry = 0
        for col in range(len(next(iter(number_rows.values()))) - 1, -1, -1):
            # Skip the operator column (Index 0) when reached
            if col == 0:
                answer_row[col] = ' '  # Explicitly leave the operator column blank in the Answer row
                continue

            # Skip the decimal and preserve it in the answer row
            if col == decimal_index:
                answer_row[col] = next(iter(number_rows.values()))[col]  # Preserve the decimal in the answer
                continue

            # Perform addition across all numbered rows
            column_sum = carry
            for row in number_rows.values():
                value = int(row[col]) if row[col] not in [' ', '+'] else 0
                column_sum += value

            # Compute new carry and result digit
            carry = column_sum // 10
            answer_row[col] = str(column_sum % 10)

            # Update carry row with precise placement logic
            if carry > 0:
                next_col = col - 1
                if next_col == decimal_index:  # If the next column is the decimal, skip it
                    next_col -= 1  # Move one additional position to the left

                if next_col >= 0:  # Ensure we're not out of bounds
                    carry_row[next_col] = str(carry)
      


        # Correct the leading column (index 1) to be blank if it doesn't contain a result digit
        if all(row[1] == ' ' for row in number_rows.values()) and carry_row[1] == ' ':
            answer_row[1] = ' '


        space_count = sum(row.count(' ') for row in grid_copy['A|'])
        if space_count == 2:
            grid_copy = {k: (v[:1] + v[2:]) for k, v in grid_copy.items()}

        # If carry row C| has any values, then set self.has_carry = True, else False
        self.has_carry = any(cell not in {' ', ''} for cell in carry_row)

        # Calculate sublevel score (carry, max_operand_rows)
        self.calculate_subLevel_score()

        # Determine the answer using A| and set attribute self.answer as string
        answer_str = ''.join(answer_row).strip()
        self.answer = float(answer_str) if '.' in answer_str else int(answer_str)

        grid_copy_clean = copy.deepcopy(grid_copy)

        # Update the solved grid
        self.solved_grid = grid_copy
        self.solved_grid_clean = AdditionGenerator.grid_cleaner(grid_copy_clean)

        # Calculate structureID
        self.problem_structure_id = Utils.generate_sha1(
            problem_string = f"{self.max_int_digits}-{self.max_dec_digits}-{self.num_operand_rows}-{int(self.has_carry)}",
            size = 4
        )
        





    # Step 4: Parameterize the grid
    def parameterize_grid_exposed_carry(self) -> None:
        """
        Generalized parameterization pipeline for "full", "answer", "carry", and "operand" cases.

        Modifies:
            - self.param_grids_carry_exposed: A dictionary containing parameterized grids and associated metadata.

        Returns:
            None
        """

        # Ensure the solved_grid exists
        if self.solved_grid_clean is None:
            raise ValueError("The solved grid must be initialized before parameterization.")

        # Initialize the param_grids_carry_exposed dictionary
        self.param_grids_carry_exposed = {}  # <1.2.2025 -- brief>

        def get_placeholder(counter):
            """Generate parameter placeholders using uppercase letters."""
            if counter <= 26:  # A-Z
                return chr(64 + counter)
            else:
                raise ValueError("Exceeded available paramater placeholder range!")

        def handle_full():
            """
            Handles the "full" parameterization case by replacing digits across multiple rows.
            """
            param_type = "full"
            rows_to_process = ["C|", "A|"]
            parameter_counter = 0
            param_grid = copy.deepcopy(self.solved_grid_clean)

            for row_key in rows_to_process:
                for idx, cell in enumerate(param_grid[row_key]):
                    if cell not in {" ", "."}:
                        parameter_counter += 1
                        param_grid[row_key][idx] = get_placeholder(parameter_counter)

            # set num_parameters = parameter_counter
            num_parameters = parameter_counter

            # Assign clean_param_grid and steps_to_params
            clean_param_grid = AdditionGenerator.grid_cleaner(copy.deepcopy(param_grid))
            steps_to_params = self.map_steps_to_positions(clean_param_grid, self.step_map)


            # Calculate the param level score
            param_level_score = self.calculate_paramLevel_score(
                num_parameters=num_parameters,
                param_type=param_type
                )

            # Create the ID and populate the param_grids_carry_exposed dictionary
            param_num = "01"
            problem_instance = f"{self.problem_id}_{param_type}_{param_num}_CE"
            self.param_grids_carry_exposed[problem_instance] = {  
                "problem_instance": problem_instance,
                "problem_id": self.problem_id,
                "param_type": "full",
                "param_num": param_num,
                "num_parameters": num_parameters,
                "num_steps": len(steps_to_params),
                "grade_level": self.grade_level,
                "sub_level_score": self.sub_level_score,
                "param_level_score": param_level_score,
                "param_grid": clean_param_grid,
                "steps_to_params": steps_to_params,
                "carry_mode": "exposed"
            }


        # Test and add a docstring
        def handle_single_row(row_key, param_type, start_counter=1):
            original_row = self.solved_grid_clean[row_key]
            digit_positions = [i for i, val in enumerate(original_row) if val.isdigit()]
            counter = start_counter

            for reveal_count in range(len(digit_positions)):  # exclude fully revealed version
                param_grid = copy.deepcopy(self.solved_grid_clean)
                placeholder_counter = 1

                for i, pos in enumerate(digit_positions):
                    if i >= reveal_count:
                        param_grid[row_key][pos] = get_placeholder(placeholder_counter)
                        placeholder_counter += 1

                clean_param_grid = copy.deepcopy(param_grid)
                steps_to_params = self.map_steps_to_positions(clean_param_grid, self.step_map)

                num_parameters = len(digit_positions) - reveal_count
                
                            # Calculate the param level score
                param_level_score = self.calculate_paramLevel_score(
                    num_parameters=num_parameters,
                    param_type=param_type
                )
                param_num = str(counter).zfill(2)
                problem_instance = f"{self.problem_id}_{param_type}_{param_num}_CE"
                self.param_grids_carry_exposed[problem_instance] = {
                    "problem_instance": problem_instance,
                    "problem_id": self.problem_id,
                    "problem_nospace": self.problem_nospace,
                    "problem_space": self.problem_space,
                    "grade_level": self.grade_level,
                    "sub_level_score": self.sub_level_score,
                    "param_level_score": param_level_score,
                    "param_type": param_type,
                    "param_num": param_num,
                    "num_parameters": num_parameters,
                    "num_steps": len(steps_to_params),
                    "param_grid": clean_param_grid,
                    "steps_to_params": steps_to_params,
                    "carry_mode": "exposed"
                }
                
                counter += 1
            
            if param_type == "operand": return counter
        
        def handle_operand_rows(start_counter=1):
            """
            Handles parameterization for all operand rows.
            Uses a shared counter across all operand rows to avoid ID collisions.
            """
            operand_keys = [
                key for key in self.solved_grid_clean
                if key.endswith("|") and key[:-1].isdigit()
            ]

            counter = start_counter
            for operand_key in operand_keys:
                counter = handle_single_row(operand_key, "operand", start_counter=counter)


        # Step 1: Run "full" parameterization
        handle_full()

        # Step 2: Run "answer" parameterization        
        handle_single_row("A|", "answer")

        # Step 3: Run "carry" parameterization
        handle_single_row("C|", "carry")

        # Step 4: Run "operand" parameterization
        handle_operand_rows()


    def parameterize_grid_hidden_carry(self):
        """
        For every param grid that includes a carry row,
        create a carry-hidden variant with reduced fields and a _CH suffix.
        """
        self.param_grids_carry_hidden = {}

        for instance_id, data in self.param_grids_carry_exposed.items():
            
            # Only process if there is a carry row and it's not a carry variation
            if self.has_carry and data["param_type"] != "carry":
                param_grid_copy = copy.deepcopy(data["param_grid"])
                del param_grid_copy["C|"]

                solve_grid_copy = copy.deepcopy(self.solved_grid)
                del solve_grid_copy["C|"]

                step_map_copy = copy.deepcopy(self.step_map)
                step_map_copy = np.delete(step_map_copy, 0, axis=0)  # Remove first row ("C|")

                num_parameters = AdditionGenerator.count_grid_parameters(param_grid_copy)

                clean_param_grid = AdditionGenerator.grid_cleaner(copy.deepcopy(param_grid_copy))

                steps_to_params = self.map_steps_to_positions(clean_param_grid, step_map_copy)


                problem_instance = f"{self.problem_id}_{data['param_type']}_{data['param_num']}_CH"
                self.param_grids_carry_hidden[problem_instance] = {
                    "problem_instance": problem_instance,
                    "problem_id": data["problem_id"],
                    "problem_nospace": self.problem_nospace,
                    "problem_space": self.problem_space,
                    "grade_level": self.grade_level,
                    "sub_level_score": data["sub_level_score"],
                    "param_level_score": data["param_level_score"],
                    "param_type": data["param_type"],
                    "param_num": data["param_num"],
                    "num_parameters": num_parameters,
                    "num_steps": data["num_steps"],
                    "param_grid": param_grid_copy,
                    "steps_to_params": steps_to_params,
                    "solved_grid": solve_grid_copy,
                    "carry_mode": "hidden"
                }

    # Step 4: Create a step mapping grid
    def step_mapping_grid(self):
        """
        Creates a mapping of grid columns to step numbers for tracking.

        This mapping associates each column with a step in the addition process,
        allowing downstream systems to understand the calculation order.

        Modifies:
            - self.step_map: Sets it to the mapping of columns to step numbers.
        """

        # Step 1: Create a deep copy of the solved grid
        solved_grid_copy = copy.deepcopy(self.solved_grid_clean)

        # Step 2: Convert the deep copy into a numpy array with dtype=object
        values = np.array(list(solved_grid_copy.values()), dtype=object)

        # Step 3: Flip the array horizontally
        flipped_values = np.flip(values, axis=1)

        # Step 4: Transpose the array
        transposed_values = flipped_values.T

        # Step 4.5: Remove "+" from transposed_values <### ADDED ###>
        for i in range(transposed_values.shape[0]):
            for j in range(transposed_values.shape[1]):
                if transposed_values[i, j] == "+":
                    transposed_values[i, j] = " "

        # Step 5: Identify rows containing '+' or '.' and store their indexes
        skip_rows = [index for index, row in enumerate(transposed_values) if '.' in row] # <### REMOVED "+" from check ###>

        # Step 6: Iterate over rows and assign step numbers
        row_counter = 1
        for index, row in enumerate(transposed_values):
            if index in skip_rows:
                continue  # Skip rows with '+' or '.'

            # Modify the row to include step numbers
            for i, value in enumerate(row):
                if value != ' ':
                    if row_counter == 1:
                        row[i] = str(row_counter)
                    else:
                        if i == 0 and row[i] != ' ':
                            row[i] = f"{row_counter - 1}"  # Adjust first column step
                        else:
                            row[i] = str(row_counter)
            row_counter += 1

        # Step 7: Transpose back to original orientation
        final_transpose = transposed_values.T

        # Step 8: Flip the array back horizontally
        final_flip = np.flip(final_transpose, axis=1)

        # Step 9: Replace '.' and '+' with spaces
        for row in final_flip:
            for i, value in enumerate(row):
                if value in ['.', '+']:
                    row[i] = ' '

        # Step 10: Store the processed grid in self.step_map
        self.step_map = final_flip


    # Step 5 Map human steps to grid
    def generate_steps_init(self):
        """
        Prepares the grid for step-by-step human readable explanation processing.

        Returns:
            np.array: A properly formatted array where:
            - The last column is the carry row.
            - The second-to-last column is the answer row.
            - All other columns are operands.
        """

        # Ensure the solved grid exists
        if self.solved_grid is None:
            raise ValueError("The solved grid must be initialized before generating steps.")

        # Create a deep copy of the solved grid to prevent modifications
        solved_grid_copy = copy.deepcopy(self.solved_grid)

        # Step 1: Replace '+' and '.' with ' ' in the grid
        for key, values in solved_grid_copy.items():
            solved_grid_copy[key] = [' ' if char in ['+', '.'] else char for char in values]

        # Step 2: Convert the grid dictionary to a NumPy array
        grid_array = np.array([values for values in solved_grid_copy.values()])

        # Ensure all elements are Python-native strings (convert np.str_ to str)
        grid_array = np.array([[str(cell) for cell in row] for row in grid_array])

        # Step 3: Remove empty columns (columns where all values are spaces)
        non_empty_columns = ~np.all(grid_array == ' ', axis=0)
        grid_array = grid_array[:, non_empty_columns]

        # Step 4: Copy the top (carry) row for shifting
        carry_shift = grid_array[0, :]

        # Step 5: Shift all values in the carry row one place to the right, except the last index
        carry_shift = np.roll(carry_shift, 1)
        carry_shift[0] = ' '  # Ensure the first element is empty after the shift

        # Step 6: Append the shifted carry row to the bottom of the grid
        grid_array = np.vstack([grid_array, carry_shift])

        # Step 7: Flip the array horizontally (reverse column order)
        grid_array = np.fliplr(grid_array)

        # Step 8: Transpose the array to prepare it for column-wise processing
        grid_array = grid_array.T

        self.step_human_init = grid_array
        # return grid_array


    # Step 6: Generate human-readable steps
    def generate_steps(self):
        """
        Generates a dictionary representing the step-by-step operations
        for a columnar addition process, using the step mapping grid.

        Modifies:
            - self.step_human: Sets it to a dictionary where each key is the
                            step_number, and the value is a dictionary 
                            containing the step details.

        Raises:
            ValueError: If `self.step_map` is not initialized.

        Notes:
            - Empty spaces in the grid are ignored during processing.
            - The operation and calculation strings adjust dynamically based on the number
            of operands present in the column.
            - Carries are formatted as "No carry is needed" or with specific instructions
            based on the value in the carry column.
        """
        if self.step_map is None:
            raise ValueError("Step map must be initialized before generating steps.")

        step_array = self.step_human_init.copy()

        # Determine the dimensions of the step_map
        num_cols = step_array.shape[1]

        # Split the array into parts
        operands = step_array[:, 0:num_cols - 2]  # All columns except the last two
        answer = step_array[:, num_cols - 2:num_cols - 1]  # Second-to-last column (answer)
        carry = step_array[:, num_cols - 1:num_cols]  # Last column (carry)

        # Process each step and construct dictionaries
        steps = {}
        for i, (operand_row, answer_row, carry_row) in enumerate(zip(operands, answer, carry), start=1):

            # Clean operands (ignore empty spaces)
            cleaned_operands = [str(op) for op in operand_row if op.strip()]
            sum_operands = str(sum(int(num) for num in cleaned_operands))

            # Build the operation and calculation strings
            if len(cleaned_operands) > 1:
                operation = f"Add {' and '.join(map(str, cleaned_operands))}"
                calculation = f"{' + '.join(map(str, cleaned_operands))} = {sum_operands}"
                calculation_log = f"{' + '.join(map(str, cleaned_operands))}"
            elif len(cleaned_operands) == 1:
                operation = f"Add {cleaned_operands[0]} and 0"
                calculation = f"{cleaned_operands[0]} + 0 = {sum_operands}"
                calculation_log = f"{cleaned_operands[0]} + 0"
            else:
                operation = "No operation (empty column)"
                calculation = "No calculation"
                calculation_log = "No calculation"

            # Format carry
            # carry_text = "No carry is needed for this step" if carry_row[0] == ' ' else f"Enter {carry_row[0]} in the carry row for the next column"
            carry_digit = "" if carry_row[0] == ' ' else f"{carry_row[0]}"
            carry_text = "" if carry_row[0] == ' ' else f"Carry: {carry_row[0]}"

            # Format answer
            # answer_text = f"{answer_row[0]}"
            answer_digit = f"{answer_row[0]}"
            answer_text = f"Place: {answer_digit}"

            # Construct full text
            full_text = (f"Step {i}\n"
                        f"Operation: {operation}\n"
                        f"Calculation: {calculation}\n"
                        # f"Answer: {answer_text}\n"
                        f"Answer: {answer_digit}\n"
                        f"Carry: {carry_text}")


            # Feedback differs if there are carry digits involved
            if int(sum_operands) < 10 : # No carry
                feedback = calculation
            else : # carry
                feedback = calculation + "\n" + carry_text + "  |  " + answer_text

            # Create dictionary for the step
            step = {
                "step_number": i,
                "operands": cleaned_operands,
                "sum_operands": sum_operands,
                "calculation": calculation,
                "calculation_log": calculation_log,
                "answer_digit": answer_digit,
                "answer_text": answer_text,
                "carry_digit": carry_digit,
                "carry_text": carry_text,
                "feedback": feedback
                # "Full Text": full_text
            }

            # Add the step to the steps dictionary
            steps[i] = step
            
        # Update the class attribute
        self.step_human = steps


    # Step 7: Build the problem dictionary containing necessary data for Flutter
    def build_python_output(self):
        """
        Builds a dictionary for Flutter/Dart that contains:
            1. The clean solved grid (self.solved_grid_clean)
            2. The parameterized grid (self.param_grid)
            3. Step indices (self.step_map)
            4. Human-readable steps (self.step_human)

        Modifies:
            - self.python_output: A dictionary with all the necessary data.
        """

        # Copy relevant attributes
        solved_grid_copy = copy.deepcopy(self.solved_grid_clean)
        param_grid_carry_exposed_copy = copy.deepcopy(self.param_grids_carry_exposed)
        param_grid_carry_hidden_copy = copy.deepcopy(self.param_grids_carry_hidden)
        step_map_copy = self.convert_array_to_dict(self.step_map, solved_grid_copy.keys())
        step_human_copy = copy.deepcopy(self.step_human)

        # Build the dictionary
        self.python_output = {
            "problem_id": self.problem_id,
            "problem_structure_id": self.problem_structure_id,
            "problem_nospace": self.problem_nospace,
            "problem_space": self.problem_space,
            "answer": self.answer,
            "grade_level": self.grade_level,
            "sub_level_score": self.sub_level_score,
            "param_grid_carry_exposed": param_grid_carry_exposed_copy,
            "param_grid_carry_hidden": param_grid_carry_hidden_copy,
            "step_human": step_human_copy,
            "step_map": step_map_copy,
            "solved_grid": solved_grid_copy,
        }


    # Step 8: Serialize the lookup table for JSON output
    def pack_for_json(self):
        """
        Serializes the lookup table into a JSON-compatible format and stores it in a class attribute.

        Modifies:
            - self.json_output: Stores the serialized JSON representation of the lookup table.

        Raises:
            ValueError: If `lookup_table` is not initialized.
        """
        if self.python_output is None:
            raise ValueError("The lookup table (lookup_table) is not initialized.")

       

        # Serialize the lookup table and store it in a class attribute
        self.json_output = json.dumps(self.python_output, indent=4, ensure_ascii=False)


    def generate_problems(self):
        """
        Orchestrates the entire pipeline for generating structured addition data.

        This method validates the input, processes all steps of the addition pipeline,
        and packages the final data structure for downstream consumption. By default,
        it outputs the data in JSON format.

        Args:
            numbers (list): A list of integers or floats to be added together.
            output_format (str): The desired output format. Options are:
                - "json": Returns the data as a JSON string (default).
                - "python": Returns the data as a Python dictionary.

        Returns:
            str or dict: The packaged data structure in the specified format.

        Raises:
            ValueError: If an invalid output format is provided or if any step fails.

        Notes:
            - This function integrates all methods in the correct order.
            - Users should call this method to generate data for any downstream use case.
        """
        self.validate_inputs()
        self.build_problem()
        self.build_grid()
        self.solve_grid()
        self.set_grade_level()
        self.step_mapping_grid()
        self.parameterize_grid_exposed_carry()
        self.parameterize_grid_hidden_carry()
        self.generate_steps_init()
        self.generate_steps()
        self.build_python_output()
        

    # Helper Function: Convert Array to Dictionary
    @staticmethod
    def convert_array_to_dict(array, keys):
        """
        Converts a numpy array to a dictionary with specified row labels.

        Args:
            array (numpy.ndarray): Input array to convert.
            keys (list): List of keys for the dictionary, one for each row in the array.

        Returns:
            dict: Dictionary with keys mapped to rows from the array.
        """
        if len(array) != len(keys):
            raise ValueError("Number of keys must match the number of rows in the array.")

        # Create the dictionary by mapping keys to rows
        return {key: list(row) for key, row in zip(keys, array)}
    

    @staticmethod
    def count_grid_parameters(grid: dict) -> int:
        """
        Counts the number of parameter placeholders (A–Z) in a grid.

        A parameter is defined as a single-character string between 'A' and 'Z',
        matching how placeholders are generated (chr(64 + counter)).

        Args:
            grid (dict): The grid containing potential parameter placeholders.

        Returns:
            int: Total count of valid placeholder characters (A–Z).
        """
        return sum(
            1 for row in grid.values()
            for cell in row
            if isinstance(cell, str) and len(cell) == 1 and 'A' <= cell <= 'Z'
        )



 