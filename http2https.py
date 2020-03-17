from http.server import BaseHTTPRequestHandler
from http.server import HTTPServer

class RedirectToHTTPSProxyHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(302)
        # for proxy, absolute URI is used
        self.send_header('Location', self.path.replace('http://', 'https://'))
        self.end_headers()

server_address = ('', 8080)
httpd = HTTPServer(server_address, RedirectToHTTPSProxyHandler)
httpd.serve_forever()
