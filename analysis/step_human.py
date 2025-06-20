# "step_human": {
#         "1": {
#             "step_number": 1,
#             "operands": [
#                 "9",
#                 "1"
#             ],
#             "operation": "Add 9 and 1",
#             "calculation": "9 + 1 = 0",
#             "answer": "0",
#             "carry": "Enter 1 in the carry row for the next column",
#             "Full Text": "Step 1\nOperation: Add 9 and 1\nCalculation: 9 + 1 = 0\nAnswer: 0\nCarry: Enter 1 in the carry row for the next column"

#             "operation": "Add 9 and 1",
#             "calculation": "9 + 1 = 0",
#             "answer_digit": "0",
#             "carry_digit": "1",
#             "carry_text": "Carry the 1",
#             "answer_text": "Place the 0"
#             "Full Text": "Step 1\nOperation: Add 9 and 1\nCalculation: 9 + 1 = 0\nAnswer: 0\nCarry: Enter 1 in the carry row for the next column"


# feedback = calculation
# feedback = calculation + " | " + carry_text + ". " + answer_text

# 9 + 1 = 10 | Carry the 1 and place the 0.
# Split feedback into 2 parts
#   1. 9 + 1 = 10
#   2. Carry the 1 and place the 0
# 
# Rename answer to answer_digit
# Rename carry to carry_digit and only keep the digit
# Add total: 10 (true add of operands)

# First part feedback
#   1. Use list comprehension on operands to create o1 + o2 + ... oN = total
# Second part feedback
#   2. Carry the carry_digit and place the answer_digit

