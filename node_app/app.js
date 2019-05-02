// const chokidar = require('chokidar');

const http = require('http');
const hostname = '127.0.0.1';
const port = 3000;

// chokidar.watch('.', {ignored: /(^|[\/\\])\../}).on('all', (event, path) => {
//   console.log("iasdasdas");
//   console.log(event, path);
// });

const server = http.createServer((request, response) => {
  const { method, url, headers } = request;

  let body = [];

  request.on('error', (err) => {
    console.error(err.stack);
  }).on('data', (chunk) => {
    body.push(chunk);
  }).on('end', () => {
    body = Buffer.concat(body).toString();
  });

  console.log('asda9998798798798799');

  response.statusCode = 200;
  response.setHeader('Content-Type', 'text/plain');
  // response.end(body);
  response.end('LKAJSDFLKJASDFLKJASDFKLJ');
})

server.listen(port, hostname, () => {
  // call vue here? how to pull logic?
  console.log(`Server running at http://${hostname}:${port}/`);
})


// run node_app on CLI 
// make routes route to call to URL and get return "Hello World"
