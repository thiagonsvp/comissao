const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 3030;
const DIR = __dirname;

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.css':  'text/css',
  '.js':   'application/javascript',
  '.png':  'image/png',
  '.jpg':  'image/jpeg',
  '.svg':  'image/svg+xml',
  '.ico':  'image/x-icon',
};

const server = http.createServer((req, res) => {
  let urlPath = decodeURIComponent(req.url.split('?')[0]);
  if (urlPath === '/' || urlPath === '') urlPath = '/Gerenciamento_Financeiro.html';

  const filePath = path.join(DIR, urlPath);
  const ext = path.extname(filePath);
  const contentType = MIME[ext] || 'application/octet-stream';

  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(404, {'Content-Type': 'text/plain'});
      res.end('Arquivo não encontrado: ' + urlPath);
      return;
    }
    res.writeHead(200, {'Content-Type': contentType});
    res.end(data);
  });
});

server.listen(PORT, '127.0.0.1', () => {
  console.log('');
  console.log('✅ Servidor rodando em: http://localhost:' + PORT);
  console.log('   Abrindo no Chrome...');
  console.log('');
  console.log('   Pressione Ctrl+C para parar o servidor.');
});
