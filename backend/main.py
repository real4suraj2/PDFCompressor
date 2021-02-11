import os
from flask import Flask, request, send_file
from pdf_compressor import compress

app = Flask(__name__)

@app.route('/upload', methods=['POST'])
def upload_file():
    if request.method == 'POST':
        f = request.files['file']
        print('file', f)
        quality = request.form['quality']
        f.save(os.path.join(os.getcwd(), 'file.pdf'))
        compress('file.pdf', 'compressed.pdf', int(quality))
        return send_file('compressed.pdf', attachment_filename=f.filename)

@app.route('/')
def index():
    return 'Not a frontend API'
