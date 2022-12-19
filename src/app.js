const http = require('node:http');
const { cacheFolder, watch, api } = require('./cacher');

cacheFolder();
watch();

setTimeout(() => {
  console.dir({ api });
}, 1000);

const receiveBody = async (req) => {
  const buffers = [];
  for await (const chunk of req) buffers.push(chunk);
  const data = Buffer.concat(buffers).toString();

  let result = '';
  try {
    result = JSON.parse(data);
  } catch (e) {}
  return result;
};

const httpError = (res, status, message) => {
  res.statusCode = status;
  res.end(`"${message}"`);
};

const server = http.createServer();

server.on('error', (e) => {
  if (e.code === 'EADDRINUSE' || e.code === 'EADDRNOTAVAIL') {
    setTimeout(() => {
      server.close();
      server.listen(process.env.PORT, process.env.HOST);
    }, 60000);
  }
});

server.on('request', async (req, res) => {
  const url = req.url === '/' ? '/index.html' : req.url;
  const [section, destination] = url.substring(1).split('/');

  if (section === 'index.html') {
    res.statusCode = 200;
    return res.end('<h1>Index</h1>');
  }

  if (section !== 'api') {
    return httpError(res, 404, 'Not found');
  }

  const method = api.get(destination);
  const body = await receiveBody(req);

  try {
    const result = await method(...body);

    if (!result) {
      return httpError(res, 500, 'Server error');
    }

    res.end(JSON.stringify(result));
  } catch (err) {
    console.dir({ err });
    httpError(res, 500, `Server error: ${err.message}`);
  }
});

console.log('-');
// console.log(process.env.HOST, process.env.PORT);
console.log(process.env);
console.log('-');

server.listen(process.env.PORT, process.env.HOST);
