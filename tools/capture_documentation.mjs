// Screenshot browser asli dan ekspor laporan PDF. Memerlukan Node 22+ dan Chrome.
import { spawn } from 'node:child_process';
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { createPreviewServer } from './preview.mjs';

const root = path.resolve(fileURLToPath(new URL('..', import.meta.url)));
const output = path.join(root, 'docs/screenshots');
const profile = path.join(root, `build/documentation-chrome-${process.pid}`);
const delay = (ms) => new Promise(resolve => setTimeout(resolve, ms));
await mkdir(output, { recursive: true });
await mkdir(profile, { recursive: true });
const server = createPreviewServer();
await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
const baseUrl = `http://127.0.0.1:${server.address().port}`;
const chrome = spawn(process.env.CHROME_PATH ?? 'C:/Program Files/Google/Chrome/Application/chrome.exe', [
  '--headless=new', '--disable-gpu', '--no-first-run', '--no-default-browser-check',
  '--remote-debugging-port=0', `--user-data-dir=${profile}`, 'about:blank',
], { windowsHide: true, stdio: 'ignore' });
chrome.on('error', error => console.error(error.message));
let socket;
let id = 0;
const pending = new Map();
const paused = [];
let mode = 'loading';
let apiStatus;
const evidence = { capturedAt: new Date().toISOString(), source: 'Flutter web, Chrome headless, viewport 430 x 932', screenshots: [] };

try {
  let debugPort;
  for (let attempt = 0; attempt < 80; attempt++) {
    try { debugPort = Number((await readFile(path.join(profile, 'DevToolsActivePort'), 'utf8')).split('\n')[0]); break; }
    catch { await delay(250); }
  }
  if (!debugPort) throw new Error('Chrome tidak siap. Periksa CHROME_PATH.');
  const targets = await (await fetch(`http://127.0.0.1:${debugPort}/json/list`)).json();
  socket = new WebSocket(targets.find(target => target.type === 'page').webSocketDebuggerUrl);
  await new Promise((resolve, reject) => { socket.onopen = resolve; socket.onerror = reject; });
  socket.onmessage = ({ data }) => {
    const message = JSON.parse(data);
    if (message.id) {
      const item = pending.get(message.id);
      if (!item) return;
      pending.delete(message.id);
      clearTimeout(item.timer);
      message.error ? item.reject(new Error(message.error.message)) : item.resolve(message.result);
    }
    if (message.method === 'Fetch.requestPaused') {
      const requestId = message.params.requestId;
      if (mode === 'loading') paused.push(requestId);
      else if (mode === 'error') command('Fetch.failRequest', { requestId, errorReason: 'InternetDisconnected' }).catch(console.error);
      else command('Fetch.continueRequest', { requestId }).catch(console.error);
    }
    if (message.method === 'Network.responseReceived' && message.params.response.url.includes('/v1/forecast')) {
      apiStatus = message.params.response.status;
    }
  };
  function command(method, params = {}) {
    return new Promise((resolve, reject) => {
      const requestId = ++id;
      const timer = setTimeout(() => { pending.delete(requestId); reject(new Error(`CDP timeout: ${method}`)); }, 30000);
      pending.set(requestId, { resolve, reject, timer });
      socket.send(JSON.stringify({ id: requestId, method, params }));
    });
  }
  async function evaluate(expression) {
    const result = await command('Runtime.evaluate', { expression, returnByValue: true });
    if (result.exceptionDetails) throw new Error(JSON.stringify(result.exceptionDetails));
    return result.result.value;
  }
  async function waitForText(text) {
    for (let attempt = 0; attempt < 80; attempt++) {
      await evaluate("document.querySelector('flt-semantics-placeholder')?.click()");
      const found = await evaluate(`document.body.innerText.includes(${JSON.stringify(text)}) || [...document.querySelectorAll('[aria-label]')].some(e => e.getAttribute('aria-label').includes(${JSON.stringify(text)}))`);
      if (found) { await delay(500); return; }
      await delay(250);
    }
    throw new Error(`Tampilan belum siap: ${text}`);
  }
  async function screenshot(filename) {
    const { data } = await command('Page.captureScreenshot', { format: 'png', captureBeyondViewport: false });
    await writeFile(path.join(output, filename), Buffer.from(data, 'base64'));
    evidence.screenshots.push(filename);
    console.log(`Screenshot: ${filename}`);
  }
  async function clickText(text) {
    const point = await evaluate(`(() => {
      const element = [...document.querySelectorAll('[role="button"]')].find(e =>
        ((e.getAttribute('aria-label') || '') + e.textContent).includes(${JSON.stringify(text)}));
      if (!element) return null;
      const rect = element.getBoundingClientRect();
      return { x: rect.x + rect.width / 2, y: rect.y + rect.height / 2 };
    })()`);
    if (!point) throw new Error(`Tombol tidak ditemukan: ${text}`);
    await command('Input.dispatchMouseEvent', { type: 'mousePressed', ...point, button: 'left', clickCount: 1 });
    await command('Input.dispatchMouseEvent', { type: 'mouseReleased', ...point, button: 'left', clickCount: 1 });
  }
  await command('Page.enable');
  if (!process.argv.includes('--pdf-only')) {
  await command('Network.enable');
  await command('Emulation.setDeviceMetricsOverride', { width: 430, height: 932, deviceScaleFactor: 1, mobile: true });
  await command('Fetch.enable', { patterns: [{ urlPattern: '*api.open-meteo.com/v1/forecast*' }] });
  await command('Page.navigate', { url: baseUrl });
  await waitForText('Memuat cuaca Jakarta');
  await screenshot('01-loading.png');
  mode = 'success';
  for (const requestId of paused.splice(0)) await command('Fetch.continueRequest', { requestId });
  await waitForText('CUACA SAAT INI');
  if (apiStatus !== 200) throw new Error(`API cuaca gagal: HTTP ${apiStatus}`);
  evidence.forecastHttpStatus = apiStatus;
  await screenshot('02-cuaca-jakarta.png');
  await clickText('Simpan kota ke favorit');
  await waitForText('Kota favorit');
  await delay(2200);
  await screenshot('06-favorit.png');
  await command('Page.reload', { ignoreCache: true });
  await waitForText('CUACA SAAT INI');
  await waitForText('Kota favorit');
  evidence.favoritesPersistedAfterReload = true;
  await clickText('Hapus dari favorit');
  await delay(2400);
  await command('Input.dispatchMouseEvent', { type: 'mouseWheel', x: 220, y: 720, deltaY: 650, deltaX: 0 });
  await delay(900);
  await screenshot('07-per-jam.png');
  await command('Input.dispatchMouseEvent', { type: 'mouseWheel', x: 220, y: 720, deltaY: 1800, deltaX: 0 });
  await delay(900);
  await screenshot('03-prakiraan.png');
  await clickText('Lihat detail prakiraan');
  await waitForText('Detail prakiraan');
  await screenshot('08-detail-harian.png');
  await command('Page.reload', { ignoreCache: true });
  await waitForText('CUACA SAAT INI');
  const searchButton = await evaluate(`(() => {
    const element = [...document.querySelectorAll('[role="button"]')].find(e =>
      (e.getAttribute('aria-label') ?? e.textContent).includes('Cari kota di Indonesia'));
    if (!element) return { x: 190, y: 220 };
    const rect = element.getBoundingClientRect();
    return { x: rect.x + rect.width / 2, y: rect.y + rect.height / 2 };
  })()`);
  await command('Input.dispatchMouseEvent', { type: 'mousePressed', ...searchButton, button: 'left', clickCount: 1 });
  await command('Input.dispatchMouseEvent', { type: 'mouseReleased', ...searchButton, button: 'left', clickCount: 1 });
  await waitForText('Langit di kotamu');
  await screenshot('04-pencarian.png');
  mode = 'error';
  await command('Page.reload', { ignoreCache: true });
  await waitForText('Cuaca belum dapat dimuat');
  await screenshot('05-error.png');
  await command('Fetch.disable');
  }
  await command('Emulation.clearDeviceMetricsOverride');
  await command('Page.navigate', { url: `${baseUrl}/docs/laporan.html` });
  await delay(1800);
  await command('Emulation.setEmulatedMedia', { media: 'print' });
  await command('Emulation.setDeviceMetricsOverride', { width: 794, height: 1123, deviceScaleFactor: 1, mobile: false });
  const cover = await command('Page.captureScreenshot', { format: 'png', captureBeyondViewport: false });
  await writeFile(path.join(root, 'build/laporan-cover-preview.png'), Buffer.from(cover.data, 'base64'));
  const pdf = await command('Page.printToPDF', { printBackground: true, preferCSSPageSize: true });
  await writeFile(path.join(root, 'docs/Laporan_UTS_LangitKita.pdf'), Buffer.from(pdf.data, 'base64'));
  if (evidence.screenshots.length) {
    await writeFile(path.join(root, 'docs/capture_evidence.json'), JSON.stringify(evidence, null, 2) + '\n');
  }
  console.log('PDF: docs/Laporan_UTS_LangitKita.pdf');
} finally {
  socket?.close();
  chrome.kill();
  server.close();
}
