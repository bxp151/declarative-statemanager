# models/data_model.py

from dataclasses import dataclass

@dataclass
class ProblemMetadata:
    probID: str
    problemStructureID: str
    probText: str
    answer: float
    gradeLevel: int 
    subLevelScore: int    # The sublevel difficulty score based on problem attributes
    stepHuman: str  # Already JSON-encoded upstream
    stepMap: str    # Already JSON-encoded upstream
    solvedGrid: str # Already JSON-encoded upstream


@dataclass
class ProblemInstance:
    probID: str           # Matches probID in ProblemMetadata
    instanceID: str       # probID_paramType_paramNum_CE
    paramType: str        # Type of problem (e.g., "full")
    paramNum: str         # Numbered instance of the parameter variation
    numParameters: int    # Number of parameters to solve for
    paramLevelScore: int  # The parameter difficulty score based on parameterization
    numSteps: int         # Number of steps to solve
    paramGrid: str        # JSON (stringified)
    stepsToParams: str    # JSON (stringified)
    carryMode: str        # set to 'exposed'

@dataclass
class ProblemCarryExposed:
    probID: str           # Matches probID in ProblemMetadata
    instanceID: str       # probID_paramType_paramNum_CE
    paramType: str        # Type of problem (e.g., "full")
    paramNum: str         # Numbered instance of the parameter variation
    numParameters: int    # Number of parameters to solve for
    numSteps: int         # Number of steps to solve
    paramGrid: str        # JSON (stringified)
    stepsToParams: str    # JSON (stringified)
    carryMode: str        # set to 'exposed'

@dataclass
class ProblemCarryHidden:
    probID: str           # Matches probID in ProblemMetadata
    instanceID: str       # probID_paramType_paramNum_CH
    numParameters: int    # Number of parameters to solve for
    numSteps: int         # Number of steps to solve
    paramGrid: str        # JSON (stringified)
    stepsToParams: str    # JSON (stringified)
    carryMode: str        # set to 'hidden'
