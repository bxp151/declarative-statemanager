import hashlib
from generators.addition.addition_generator import AdditionGenerator
from models.data_model import ProblemMetadata, ProblemInstance
from services.problem_metadata_dao import ProblemMetadataDAO
from itertools import combinations_with_replacement, product
from services.problem_instance_dao import ProblemInstanceDAO
from utils.utils import Utils
from services.database_view_service import DatabaseViewService
from services.database_table_service import DatabaseTableService

class ProblemGenerator:
    """
    Generates math problems from a predefined list or through permutations, 
    converts them to string format, hashes them for uniqueness, and inserts 
    them into the database if they don’t already exist.

    Attributes:
        problems_initial (list): List of lists - input problems (e.g., [[1, 2], [3, 4]]).
        problem_type (str): Operator used to join numbers (e.g., "+", "-", "×", "÷").
        max_digits (int | None): Optional max digits per operand.
        max_rows (int | None): Optional max number of operands per problem.
        max_sets (int | None): Optional limit on the total number of problems to generate.
        problems_final (dict): Dictionary of filtered problems ready for generation and insertion.
        problems_final_split (list): Batches of problems for step-wise generation and insertion.

    Execution Flow:
        1. Call generate_problems_final() to filter out existing problems and prepare new ones.
        2. Call split_problems_final_into_batches() to divide problems into smaller chunks for processing.
        3. Call process_all_batches() to run the generator, build problem data, and insert into the database.
    """

    # Initialize the class and its attributes
    def __init__(self, 
                 problems_initial: list | None = None, 
                 problem_type: str = "",
                 max_operand_row_digits: int = 1,
                 operand_row_count: int = 2
                 ):
        
        self.max_operand_row_digits = max_operand_row_digits
        self.operand_row_count = operand_row_count
        
        if problems_initial is None:
            self.problems_initial = self.generate_problem_permutations()
        else:
            self.problems_initial = problems_initial
            
        self.problem_type = problem_type
        self.problems_final: dict = {}
        self.problems_final_split: list = []


    
    def generate_problems_final(self):
        """
        Converts each problem list in problems_initial into a string, 
        hashes it, and adds it to problems_final if it doesn't already exist in the database.

        Populates:
            self.problems_final (dict): Maps problem strings to their ID and metadata.
        """
        for item in self.problems_initial:
            problem_string = self.list_to_problem_string(item)
            problem_sha = Utils.generate_sha1(problem_string)
            # check if it's in metadata table
            if not ProblemMetadataDAO.is_hash_in_db(problem_sha):
                self.problems_final[problem_string] = {
                    'probList': item,
                    'probID': problem_sha,
                    'probText': problem_string
                }   
            else: pass


    def split_problems_final_into_batches(self, batch_size: int = 50):
        """
        Converts problems_final into a list of dictionaries, each containing up to batch_size items.

        Stores the result in self.problems_final_split.
        """
        items = list(self.problems_final.items())
        batches = []

        # range(stop, start, step)
        for i in range(0, len(items), batch_size):
            chunk = items[i:i + batch_size]
            batches.append(dict(chunk))

        self.problems_final_split = batches


    def process_all_batches(self):
        """
        Processes each batch of problems stored in self.problems_final_split.

        Iterates over each batch and then each problem within the batch, calling
        generate_problems_and_insert() to generate problem data and persist it to the database.

        This method should be called after split_problems_final().
        """
        for batch in self.problems_final_split:
            for key, value in batch.items():
                single_item = {key: value}
                self.generate_problems_and_insert(single_item)



    # process single item from batch
    def generate_problems_and_insert(self, single_item: dict): 
        """
        Runs the generator for each problem in self.problems_final, builds the necessary 
        metadata and instance objects, and inserts them into the database using a DAO.

        This method should be called after generate_final_problem_dict().
        """

        match self.problem_type:
            case "+":
                generator = AdditionGenerator
            case "-":
                return
            case "x":
                return
            case "/":
                return
            case _:
                return

        # OUTER 
        for _, value in single_item.items():
            prob_list = value["probList"]
            generator_instance = generator(prob_list)
            generator_instance.generate_problems()
            python_output = generator_instance.python_output
        

        # Call method to build ProblemMetadata row and call DAO
        self.build_and_upsert_metadata_row(python_output)

        # Store all problem instances
        param_grid_carry_exposed = python_output['param_grid_carry_exposed']
        for _, problem_instance in param_grid_carry_exposed.items():
            self.build_and_insert_problem_instance_row(problem_instance)

        param_grid_carry_hidden = python_output['param_grid_carry_hidden']
        for _, problem_instance in param_grid_carry_hidden.items():
            self.build_and_insert_problem_instance_row(problem_instance)


    @staticmethod
    def build_and_insert_problem_instance_row(problem_instance: dict) -> None:
        
        # Build carry exposed row
        problem_instance_row = ProblemInstance(
            probID = problem_instance['problem_id'],
            instanceID = problem_instance['problem_instance'],
            paramType = problem_instance['param_type'],  
            paramNum = problem_instance['param_num'],  
            numParameters = problem_instance['num_parameters'],
            paramLevelScore = problem_instance['param_level_score'],
            numSteps = problem_instance['num_steps'],  
            paramGrid = problem_instance['param_grid'],  
            stepsToParams =problem_instance['steps_to_params'],
            carryMode = problem_instance['carry_mode']
        )

        # Upsert row
        ProblemInstanceDAO.serialize_and_call_upsert(problem_instance_row)

    
    @staticmethod
    def build_and_upsert_metadata_row(python_output: dict) -> None:
        '''
        Builds and upserts the metadata row 
        '''

        # build
        problem_metadata_row = ProblemMetadata(
            probID = python_output['problem_id'],
            problemStructureID = python_output['problem_structure_id'],
            probText = python_output['problem_space'],
            answer = python_output['answer'],
            gradeLevel = python_output['grade_level'],
            subLevelScore = python_output['sub_level_score'],
            stepHuman = python_output['step_human'],
            stepMap = python_output['step_map'],
            solvedGrid = python_output['solved_grid']
        )

        # Upsert row
        ProblemMetadataDAO.serialize_and_call_upsert(problem_metadata_row)

    
    def list_to_problem_string(self, original_problem: list) -> str:
        """
        Converts a list of operands into a single string using the class-defined operator.

        Args:
            original_problem (list): List of numbers to be joined.

        Returns:
            str: A human-readable problem string (e.g., "2+3+4").
        """
        problem_string = self.problem_type.join(str(n) for n in original_problem)
        return problem_string


    def generate_problem_permutations(self) -> list:
        """
        Generates all possible math problems (as lists of integers) where each operand:
            - Has between 1 and `max_operand_row_digits` digits
            - Follows a non-increasing digit-length pattern (e.g., [3,2,1] is allowed; [1,3] is not)
        
        Parameters:
            max_operand_row_digits (int): Maximum number of digits allowed per operand (must be ≥ 1)
            operand_row_count (int): Number of operand rows in each problem (must be ≥ 2)

        Returns:
            list[list[int]]: List of all valid problems, each represented as a list of integers
                            (e.g., [[9, 8], [10, 1], [85, 42]])
        """
        if self.max_operand_row_digits < 1:
            raise ValueError("max_operand_row_digits must be ≥ 1")
        if self.operand_row_count < 2:
            raise ValueError("operand_row_count must be ≥ 2")

        # Step 1: Generate all allowed digit-length patterns using non-increasing combinations
        digit_length_patterns = list(combinations_with_replacement(
            range(1, self.max_operand_row_digits + 1), self.operand_row_count
        ))
        digit_length_patterns = [sorted(p, reverse=True) for p in digit_length_patterns]

        # Step 2: For each digit-length pattern, generate number ranges and all permutations
        all_problems = []
        for pattern in digit_length_patterns:
            digit_ranges = [
                list(range(10**(d-1), 10**d)) if d > 1 else list(range(0, 10))
                for d in pattern
            ]
            for combination in product(*digit_ranges):
                all_problems.append(list(combination))  # convert from tuple to list

        return all_problems

    def write_problems_to_file(self, filename: str = "problems_output.txt") -> None:
        """
        Writes a list of operand problems to a local text file for easier inspection.

        Each problem will be written on a new line as a list (e.g., [34, 9]).

        Args:
            problems (list): A list of problems, where each problem is a list of integers.
            filename (str): Name of the file to write to.
        """
        with open(filename, "w") as f:
            for prob in self.problems_initial:
                f.write(str(prob) + "\n")


    @staticmethod
    def build_problem_views() -> None:
        """
        Creates the required SQL views after problem data has been generated and inserted.
        """
        DatabaseViewService.build_problem_view()
        DatabaseViewService.build_problem_by_overall_level_view()
    
    @staticmethod
    def build_problem_shuffle_index_table() -> None:
        DatabaseTableService.build_problem_shuffle_index_table()

        