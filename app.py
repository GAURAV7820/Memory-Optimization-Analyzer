from flask import Flask, request
import html
import subprocess

app = Flask(__name__)

def render_page(code, output):
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

    page = page.replace("CODE_VALUE", html.escape(code))
    page = page.replace("OUTPUT", formatted_output)
    return page

@app.route("/", methods=["GET", "POST"])
def index():
    if request.method == "POST":
        code = request.form.get("code", "")

        with open("input.c", "w") as f:
            f.write(code)

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
            output = "Analyzer failed to run.\n\n" + error_details
        else:
            try:
                with open("report.txt") as f:
                    output = f.read()
            except OSError:
                output = "Analyzer ran, but report.txt could not be read."

            if run_output:
                output += "\n\n--- Execution Log ---\n" + run_output

        return render_page(code, output)

    return render_page(
        "",
        "Paste C code on the left and click Analyze to view the report here.",
    )


if __name__ == "__main__":
    app.run(debug=False)
