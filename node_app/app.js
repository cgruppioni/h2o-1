const http = require('http');
const hostname = '127.0.0.1';
const port = 3000;

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello World\n');
})

server.listen(port, hostname, () => {
  console.log(`Server running at http://${hostname}:${port}/`);
})


// run node_app on CLI 
// make routes route to call to URL and get return "Hello World"
