import os
from pathlib import Path
from python.generators.addition.addition_generator import AdditionGenerator
import json

# Get the path of the current Python file
current_file = Path(__file__)

# Get the directory containing this
current_dir = current_file.parent

# Navigate to the data directory
os.chdir(current_dir) #ensure we are in the current directory
os.chdir("../../flutter/assets/data") 
data_path = os.getcwd()

# Generate a problem
problem_list = [99, 1]
problem = AdditionGenerator.generate_addition_problems(problem_list)

# Save the JSON data to the file
file_path = os.path.join(data_path, "add_99_and_1.json")

with open(file_path, "w", encoding="utf-8") as json_file:
    json_file.write(problem)

print(f"JSON data saved to {file_path}")
