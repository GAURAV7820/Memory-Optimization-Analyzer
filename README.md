# SmartMemAI - Rule-Based Memory Optimizer for C Code

## Overview

SmartMemAI is a lightweight static analysis project for C programs. It uses Flex-based lexical analysis and rule-based checks to detect memory-related issues such as unused variables, duplicate declarations, and use before initialization. It then estimates memory impact and adds an AI-assisted severity summary.

The project also includes a simple Flask web interface where a user can:
- analyze code
- optimize simple unused declarations
- restore original code after optimization
- download the report
- save the report as PDF through the browser

## Core Features

- Symbol table generation with variable name, type, usage, initialization, and line number
- Rule-based findings:
  - `R1` Unused Variable
  - `R2` Duplicate Declaration
  - `R3` Use Before Initialization
- Memory analysis:
  - memory before optimization
  - memory after optimization
  - estimated removable memory
- AI severity assessment:
  - risk level
  - optimization priority
  - estimated quality score
  - code category
  - priority order
- Assisted optimization for simple unused variable declarations
- Restore original code after optimization

## Tech Stack

- `Flex` for lexical analysis
- `C` for the analyzer logic
- `Python` with `Flask` for the web backend
- `Python` with `scikit-learn` for AI severity scoring
- `HTML/CSS` for the interface

## Project Files

- `smartmemai.l` - main Flex rule-based analyzer
- `ai_model.py` - AI severity assessment module
- `app.py` - Flask backend
- `index.html` - web interface
- `run.sh` - build and run script
- `.gitignore` - ignores generated files

Generated runtime files:
- `input.c`
- `report.txt`
- `data.txt`
- `names.txt`
- `lex.yy.c`
- `smartmemai`

## Working Flow

1. The user enters C code in the web interface.
2. `app.py` stores the code in `input.c`.
3. `run.sh` runs Flex and compiles the analyzer.
4. `smartmemai.l` scans the code and generates the rule-based report.
5. `ai_model.py` appends the AI severity assessment.
6. The final report is shown in the browser.

## How to Run

### Install dependencies

```bash
pip3 install flask numpy scikit-learn
```

Make sure `flex` and `gcc` are installed on your system.

### Run the web app

```bash
python3 -m flask --app app run --host 0.0.0.0 --port 5001
```

Then open:

```text
http://localhost:5001
```

### Run only the analyzer

```bash
./run.sh
cat report.txt
```

## Sample Input

```c
int main() {
    int a;
    int b = 10;
    int c = a + b;
    int d = a + b + c;
    return a;
}
```

## Current Limitations

- It is lexer-based, not a full parser-based compiler
- Automatic optimization only removes simple unused declarations safely
- Complex declarations, arrays, and pointers are not auto-optimized
- The AI module is a severity scorer, not a replacement for the rule engine

## Future Scope

- Undeclared variable detection
- Array usage analysis
- Pointer and dynamic memory analysis
- Parser integration using Yacc/Bison
- More advanced optimization suggestions

## Author

Gaurav Singh
