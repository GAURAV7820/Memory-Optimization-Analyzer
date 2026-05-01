from io import BytesIO

from flask import Flask, request, send_file
import html
import re
import subprocess

app = Flask(__name__)

SIMPLE_DECLARATION_RE = re.compile(
    r"^\s*(int|float|char|double|long)\s+([A-Za-z_][A-Za-z0-9_]*)\s*(=\s*[^;]+)?;\s*$"
)
UNUSED_VARIABLE_RE = re.compile(r"Unused variable:\s+([A-Za-z_][A-Za-z0-9_]*)\s+\(line\s+(\d+)\)")


def run_analyzer(code):
    with open("input.c", "w") as file:
        file.write(code)

    try:
        completed = subprocess.run(
            ["./run.sh"],
            check=True,
            capture_output=True,
            text=True,
        )
        run_output = completed.stdout.strip()
    except subprocess.CalledProcessError as exc:
        error_details = exc.stderr.strip() or exc.stdout.strip() or "Unknown execution error."
        return code, "Analyzer failed to run.\n\n" + error_details

    try:
        with open("report.txt") as file:
            output = file.read()
    except OSError:
        output = "Analyzer ran, but report.txt could not be read."

    if run_output:
        output += "\n\n--- Execution Log ---\n" + run_output

    return code, output


def read_report_text():
    try:
        with open("report.txt") as file:
            return file.read()
    except OSError:
        return "Report is not available yet."


def optimize_code(code, report_text):
    unused_entries = []
    for line in report_text.splitlines():
        match = UNUSED_VARIABLE_RE.search(line)
        if match:
            unused_entries.append((match.group(1), int(match.group(2))))

    if not unused_entries:
        return code, "No simple unused declarations were found for automatic optimization."

    lines = code.splitlines()
    removed = []
    skipped = []

    for name, line_no in unused_entries:
        idx = line_no - 1
        if idx < 0 or idx >= len(lines):
            skipped.append(name)
            continue

        line_text = lines[idx]
        match = SIMPLE_DECLARATION_RE.match(line_text)
        if not match or match.group(2) != name:
            skipped.append(name)
            continue

        lines[idx] = ""
        removed.append(name)

    optimized_code = "\n".join(line for line in lines if line.strip() != "")

    if not removed:
        return code, "Unused variables were detected, but no safe simple declarations could be removed automatically."

    message = "Auto optimization applied.\n"
    message += "Removed declarations: " + ", ".join(removed)
    if skipped:
        message += "\nSkipped declarations: " + ", ".join(skipped)

    return optimized_code, message

def render_page(code, output, original_code=""):
    with open("index.html", "r") as file:
        page = file.read()

    formatted_lines = []
    for line in output.splitlines():
        escaped_line = html.escape(line)
        if escaped_line.startswith("• "):
            escaped_line = (
                '<div class="report-line">'
                '<span class="bullet-dot"></span>'
                f"{escaped_line[2:]}"
                '</div>'
            )
        else:
            escaped_line = f'<div class="report-line">{escaped_line}</div>'
        formatted_lines.append(escaped_line)

    formatted_output = "".join(formatted_lines)

    page = page.replace("ORIGINAL_CODE_VALUE", html.escape(original_code))
    page = page.replace("CODE_VALUE", html.escape(code))
    page = page.replace("OUTPUT", formatted_output)
    if original_code:
        restore_button = '<button type="submit" name="action" value="restore" class="secondary-button">Restore Original</button>'
    else:
        restore_button = ""
    page = page.replace("RESTORE_BUTTON", restore_button)
    return page

@app.route("/", methods=["GET", "POST"])
def index():
    if request.method == "POST":
        code = request.form.get("code", "")
        action = request.form.get("action", "analyze")
        original_code = request.form.get("original_code", "")

        if action == "restore":
            restored_code = original_code or code
            restored_code, output = run_analyzer(restored_code)
            output = "Original code restored.\n\n" + output
            return render_page(restored_code, output)

        code, output = run_analyzer(code)

        if action == "optimize" and not output.startswith("Analyzer failed to run."):
            optimized_code, optimize_message = optimize_code(code, output)
            if optimized_code != code:
                code, output = run_analyzer(optimized_code)
                output = optimize_message + "\n\n" + output
                return render_page(code, output, original_code=request.form.get("code", ""))
            else:
                output = optimize_message + "\n\n" + output

        return render_page(code, output)

    return render_page(
        "",
        "Paste C code on the left and click Analyze to view the report here.",
    )


@app.route("/download-report", methods=["POST"])
def download_report():
    code = request.form.get("code", "")
    _, report_text = run_analyzer(code)
    report_file = BytesIO(report_text.encode("utf-8"))

    return send_file(
        report_file,
        as_attachment=True,
        download_name="smartmemai_report.txt",
        mimetype="text/plain",
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)
