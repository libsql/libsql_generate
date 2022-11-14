from flask import Flask, request
from flask_cors import CORS
import subprocess

app = Flask(__name__)
CORS(app)

@app.route('/generate', methods = ['POST'])
def generate():
    src = request.form['src']
    blob = request.form['blob']
    if len(src) > 4096:
        return "Max source code size is 4096 bytes"
    print(src)
    with open("libsql-target/input.rs", "w+", encoding = "utf-8") as f:
        f.write(src);
    if blob == "yes":
        result = subprocess.run(['./generate.sh', 'yes'], capture_output=True)
    else:
        result = subprocess.run(['./generate.sh', 'no'], capture_output=True)
    if result.returncode == 0:
        return result.stdout.decode("utf-8")
    else:
        return result.stderr.decode("utf-8")
