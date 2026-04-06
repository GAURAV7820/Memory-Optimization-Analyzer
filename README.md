# 🚀 SmartMemAI – Intelligent Compiler-Based Code Analyzer

## 📌 Overview

SmartMemAI is an intelligent code analysis tool that combines **compiler design concepts** with **AI-based insights**.
It analyzes C/C++ code to detect issues such as **unused variables**, **duplicate declarations**, and **memory inefficiencies**, while also providing an AI-driven quality score.

---

## 🎯 Features

* 🔍 **Symbol Table Generation**

  * Tracks variables with name, type, scope, and usage

* ⚠️ **Error & Optimization Detection**

  * Detects unused variables
  * Identifies duplicate declarations
  * Scope-aware analysis

* 💾 **Memory Analysis**

  * Calculates memory before and after optimization
  * Shows memory saved

* 🤖 **AI-Based Code Evaluation**

  * Uses Machine Learning (Random Forest)
  * Classifies variables as:

    * GOOD
    * WARNING (Unused)
    * CRITICAL (Duplicate)
  * Generates overall code quality score

* 🧠 **Scope Handling**

  * Supports nested scopes using `{ }`
  * Correctly handles variable shadowing

---

## 🛠️ Tech Stack

* **Lex/Flex** – Lexical Analysis
* **C** – Core Compiler Logic
* **Python (scikit-learn)** – AI Model
* **Git & GitHub** – Version Control

---

## 📂 Project Structure

```
SmartMemAI/
│
├── smartmemai.l     # Lex analyzer
├── ai_model.py      # AI model for analysis
├── app.py           # (Optional) Web interface
├── input.c          # Input test file
├── report.txt       # Generated output
├── data.txt         # Data for AI model
├── names.txt        # Variable names
```

---

## ⚙️ How to Run

### 🔹 1. Install Dependencies

```bash
sudo apt install flex gcc
pip install numpy scikit-learn
```

---

### 🔹 2. Compile Lex Code

```bash
flex smartmemai.l
gcc lex.yy.c -o analyzer -lfl
```

---

### 🔹 3. Run Analyzer

```bash
./analyzer
```

---

### 🔹 4. View Output

```bash
cat report.txt
```

---

## 🧪 Sample Output

```
--- Symbol Table ---
Name     Type     Used     Line   Scope

--- Optimization Report ---
Unused variable: x
Duplicate variable: y

--- Memory Analysis ---
Memory saved: 16 bytes

--- AI MODEL OUTPUT ---
x: WARNING
y: CRITICAL

Overall Quality: 85/100
```

---

## 🔮 Future Scope

* Syntax error detection (missing `;`, `,`)
* Function-level analysis
* Dead code detection
* Web-based UI improvements
* Support for more programming languages

---

## 👨‍💻 Author

**Gaurav Singh**
Computer Science Engineering (CSE)

---

## ⭐ Contribution

Feel free to fork the repository and improve the project!

---

## 📢 Note

This project demonstrates how **compiler design + AI** can be combined to build intelligent developer tools.
