# from flask import Flask
# app = Flask(__name__)

# @app.route("/")
# def hello():
#     return "Hello London"

# if __name__ == "__main__":
#     app.run(host="0.0.0.0", port=8080)



# Metrics APP
from flask import Flask
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)
REQUESTS = Counter('http_requests_total', 'Total HTTP requests')

@app.route('/')
def home():
    REQUESTS.inc()
    return "Hello from Python!"

@app.route('/metrics')
def metrics():
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)

