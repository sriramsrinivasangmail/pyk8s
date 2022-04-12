import os 
import json 
import flask 
import socket

app = flask.Flask(__name__)

def doRender(template,u_path):
    headers = flask.request.headers

    clientip = "--"
    if flask.request.environ.get('HTTP_X_FORWARDED_FOR') is None:
        clientip = (flask.request.environ['REMOTE_ADDR'])
    else:
        clientip = (flask.request.environ['HTTP_X_FORWARDED_FOR']) # if behind a proxy
 
    myhostname = socket.gethostname()

    return flask.render_template(template,zen_url = zen_url,result = headers, path = u_path, qry = flask.request.query_string, postdata=flask.request.form, clientip = clientip, myhostname = myhostname)

@app.route('/', defaults={'u_path': ''})
@app.route('/<path:u_path>',methods = ['POST', 'GET'])
def index(u_path):
    return doRender("index.html",u_path)

@app.route('/admin', defaults={'u_path': ''})
@app.route('/admin<path:u_path>')
def adminpage(u_path):
    return doRender("admin.html",u_path)

@app.route('/logout', defaults={'u_path': ''})
def logout(u_path):
    return doRender("loggedout.html",u_path)

### MAIN
zen_url = os.getenv("zen_url","")
print("zen_url=",zen_url)
app.run(host="0.0.0.0", port=8080)
