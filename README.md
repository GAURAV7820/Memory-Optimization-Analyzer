# 🧠 SmartMemAI – Memory Optimization Analyzer for C Programs

SmartMemAI is a **rule-based static analysis tool** for C programs that detects memory inefficiencies such as unused variables, duplicate declarations, and improper initialization.

It combines **Lex (Flex)** for parsing with **Python-based AI insights** to generate a structured and detailed optimization report.

---

## 🚀 Features

* 🔍 Detects **unused variables**
* ⚠️ Identifies **duplicate declarations**
* 🚫 Flags **use before initialization**
* 📊 Provides **memory usage analysis (before vs after optimization)**
* 🤖 Integrates with a Python model for additional insights
* 📄 Generates a structured **analysis report**
* 🔄 Supports **code optimization and reversible transformations**

---

## 🛠️ Tech Stack

* **C** – Core analysis logic
* **Lex / Flex** – Tokenization & parsing
* **Python** – AI model integration
* **Flask** *(optional)* – Web interface

---

## 📂 Project Structure

```
CD-PBL/
│
├── lexer.l              # Lex file (core analyzer)
├── input.c              # Input C program
├── report.txt           # Generated analysis report
├── data.txt             # Features for AI model
├── names.txt            # Variable names
├── ai_model.py          # Python-based model
├── app.py               # Flask UI (optional)
└── README.md
```

---

## ⚙️ How It Works

### 1. Lexical Analysis

Parses the input C code and identifies:

* Variables
* Scope
* Usage patterns

### 2. Rule-Based Detection

Applies predefined rules:

* **R1:** Unused Variable
* **R2:** Duplicate Declaration
* **R3:** Use Before Initialization

### 3. Memory Analysis

Computes:

* Memory before optimization
* Memory after optimization
* Memory saved

### 4. AI Integration

Sends extracted features to a Python model for additional classification and insights.

---

## ▶️ How to Run

### 🔹 Step 1: Compile

```bash
flex lexer.l
gcc lex.yy.c -o analyzer
```

### 🔹 Step 2: Execute

```bash
./analyzer
```

### 🔹 Step 3: View Report

```
report.txt
```

---

### 🔹 (Optional) Run Web Interface

```bash
python3 app.py
```

Open in browser:

```
http://127.0.0.1:5000
```

---

## 📊 Sample Output

```
--- Optimization Report ---
Unused variable: unused1
Duplicate variable: d
Used before initialization: unused2

--- Memory Analysis ---
Memory before: 16 bytes
Memory after: 8 bytes
Memory saved: 8 bytes
```

---

## 🔄 Code Optimization & Reversibility

SmartMemAI can also **generate optimized code** by removing unnecessary variables and redundancies.
It supports **reversing the optimization** to restore the original version when needed.

---

### ✨ Optimization Capabilities

* Removes **unused variables**
* Eliminates **duplicate declarations**
* Keeps only **necessary variables**
* Preserves program correctness

---

### 🔁 Reverse Optimization

* Restores original code from optimized version
* Useful for:

  * Debugging
  * Comparison
  * Learning/analysis

> ⚠️ Reverse functionality is implemented using stored analysis metadata.

---

## 🧪 Example

### 🔹 Original Code

```c
#include <stdio.h>

int main() {
    int a;
    int b;
    int c;

    a = 10;
    b = a + 5;

    int d;
    int d;   // duplicate

    int unused1;
    int unused2;

    int e = b + 2;

    printf("%d %d %d\n", a, b, e);
    return 0;
}
```

---

### 🔹 Optimized Code

```c
#include <stdio.h>

int main() {
    int a;
    int b;

    a = 10;
    b = a + 5;

    int d;

    int e = b + 2;

    printf("%d %d %d\n", a, b, e);
    return 0;
}
```

---

### 🔹 Restored Code

```c
#include <stdio.h>

int main() {
    int a;
    int b;
    int c;

    a = 10;
    b = a + 5;

    int d;
    int d;

    int unused1;
    int unused2;

    int e = b + 2;

    printf("%d %d %d\n", a, b, e);
    return 0;
}
```

---

## 🎯 Key Concepts

* Lexical Analysis
* Symbol Table Management
* Static Code Analysis
* Memory Optimization
* Rule-Based Systems
* Basic AI Integration

---

## 🧠 Challenges Faced

* Correct **variable usage tracking**
* Preventing **state leakage between tokens**
* Distinguishing **declaration vs usage**
* Handling **function calls (e.g., printf) safely**

---

## 📌 Future Improvements

* Full parser integration (**YACC/Bison**)
* Support for complex expressions
* Advanced AI-based suggestions
* Improved UI/visualization
* Multi-language support

---

## 👨‍💻 Author

**Gaurav Singh**
Computer Science Engineering Student

---
