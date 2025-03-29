import http.server
import socketserver
import json
import requests

PORT = 8000

class WeatherHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        city = self.path.strip('/').replace('%20', ' ')
        if city:
            api_key = "YOUR_OPENWEATHERMAP_API_KEY"
            url = f"http://api.openweathermap.org/data/2.5/weather?q={city}&appid={api_key}"
            response = requests.get(url)
            weather_data = response.json()
            if weather_data['cod'] == 200:
                weather_info = weather_data['weather'][0]['description']
                self.send_response(200)
                self.send_header('Content-type', 'text/html')
                self.end_headers()
                self.wfile.write(f"Weather in {city}: {weather_info}".encode())
            else:
                self.send_response(404)
                self.end_headers()
                self.wfile.write("City not found.".encode())
        else:
            self.send_response(400)
            self.end_headers()
            self.wfile.write("Please provide a city.".encode())

def run(server_class=http.server.HTTPServer, handler_class=WeatherHandler):
    server_address = ('', PORT)
    httpd = server_class(server_address, handler_class)
    print(f'Starting httpd server on port {PORT}')
    httpd.serve_forever()

if __name__ == '__main__':
    run()
