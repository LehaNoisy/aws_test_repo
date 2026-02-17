from flask import Flask

app = Flask(__name__)


@app.route('/')
def index():
    return "Hello from cqw6k7di!"


@app.route('/health')
def health():
    return 'ok', 200


if __name__ == '__main__':
    import os
    app.run(host='0.0.0.0', port=8000)
