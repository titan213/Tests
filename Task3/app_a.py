from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/', methods=['POST'])
def hello_a():
    name = request.json['name']
    response = f'Hello {name}, this is service A'
    return jsonify(response=response)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
