// Server lokal untuk meninjau hasil `flutter build web` tanpa package Node.
import http from 'node:http';
import { readFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(fileURLToPath(new URL('..', import.meta.url)));
const types = { '.html': 'text/html', '.js': 'text/javascript', '.json': 'application/json',
  '.wasm': 'application/wasm', '.png': 'image/png', '.svg': 'image/svg+xml',
  '.ttf': 'font/ttf', '.woff2': 'font/woff2', '.pdf': 'application/pdf' };

export function createPreviewServer() {
  return http.createServer(async (request, response) => {
    try {
      const url = new URL(request.url, 'http://localhost');
      const requested = decodeURIComponent(url.pathname);
      const base = requested.startsWith('/docs/') ? root : path.join(root, 'build/web');
      const filename = path.resolve(base, '.' + (requested === '/' ? '/index.html' : requested));
      if (!filename.startsWith(base + path.sep)) {
        response.writeHead(403).end();
        return;
      }
      const content = await readFile(filename);
      response.writeHead(200, { 'Content-Type': types[path.extname(filename)] ?? 'application/octet-stream',
        'Cache-Control': 'no-store' });
      response.end(content);
    } catch {
      if (!response.headersSent) response.writeHead(404);
      response.end();
    }
  });
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const port = Number(process.env.PORT ?? 8787);
  createPreviewServer().listen(port, '127.0.0.1', () => {
    console.log(`LangitKita: http://127.0.0.1:${port}`);
  });
}
