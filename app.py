from flask import Flask, request, send_file
import os

app = Flask(__name__)

@app.route("/", methods=["GET", "POST"])
def index():
    if request.method == "POST":
        code = request.form.get("code", "")

        with open("input.c", "w") as f:
            f.write(code)

        os.system("./run.sh")

        try:
            with open("report.txt") as f:
                output = f.read()
        except:
            output = "Error generating report."

        # Inject output into HTML manually
        with open("index.html", "r") as file:
            html = file.read()

        html = html.replace("OUTPUT", output)

        return html

    return send_file("index.html")


if __name__ == "__main__":
    app.run(debug=True)