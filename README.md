# Bash HTML Pretty Printer

A Command Line Interface (CLI) utility built in Bash that functions as an HTML "Pretty Printer". It takes unformatted or minified HTML code as input and generates the same code with correct visual indentation. This project was developed for the "Basic tools and techniques in computer science" course at the University of Bucharest, Department of Computer Science (2025-2026). 

---

## Key Features

*   **Zero External Dependencies:** The solution relies exclusively on standard POSIX system tools like `grep` and `sed`. It avoids complex external libraries or dedicated parsers such as those from Python or Node.js.
*   **High Portability:** Because it uses native shell utilities, the script can run on most Linux distributions or macOS.
*   **Stream Processing Architecture:** The script processes the input file line by line rather than loading the entire file to build a Document Object Model (DOM) tree in memory.
*   **Low Resource Consumption:** The memory footprint remains constant and small, specifically around 18-22 MB, regardless of the HTML file's size.
*   **Fast Execution:** Processing begins immediately without waiting for the entire file to load.

---

## Architecture and Algorithm

The core logic is divided into two main steps: tokenization and indentation calculation.

### 1. Tokenization
*   To handle minified files where multiple tags exist on a single line, reading line by line is insufficient.
*   The script uses the Perl Compatible Regular Expressions (PCRE) engine via the `grep -oP` command to break each line into atomic units, or tokens.
*   The regular expression `<[^>]+>|[^<]+` is used to identify either a complete HTML tag or the text content between tags.
*   The `mapfile` command is combined with `grep` to load these fragments into an array, allowing the script to iterate through each structural element.
*   Each fragment is then cleaned of leading and trailing whitespaces using `sed`.

### 2. Indentation Logic
*   The algorithm uses a single state variable (`indent`) to track the current depth level within the DOM tree.
*   **Opening Tags (e.g., `<div>`):** The tag is printed at the current level, and the `indent` variable is incremented by 1 so the next element is placed further to the right as a child element.
*   **Closing Tags (e.g., `</div>`):** The `indent` variable is decremented by 1 before printing, aligning the closing tag with its parent and visually closing the block.
*   **Text Content:** Printed at the current indentation level without modifying the state variable.
*   Standardized indentation is achieved using 4 spaces per depth level.

### 3. Handling Self-Closing Tags
*   Void elements (self-closing tags) like `<img>`, `<br>`, or `<input>` do not have closing tags.
*   Treating them as regular opening tags would cause the indentation to increase infinitely, creating an "indentation drift".
*   The script checks each extracted tag against a predefined list of self-closing tags.
*   If the tag is found in this list, the `indent` variable is not modified.

---

## Limitations

*   **No Validation:** The script assumes the input is a valid HTML file; it does not repair syntax or validate code errors.
*   **Non-Standard Tags:** Tags that are used as self-closing but are not part of the standard list may affect subsequent indentation.
