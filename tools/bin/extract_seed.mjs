// Extracts the prototype's sample catalogue (jarina-mobile/js/01-data.js) into
// JSON seed files used by the Fake* repositories, and writes the country flag
// SVGs (the prototype's flag files lack the stars it draws at runtime).
//
// Usage: node tools/bin/extract_seed.mjs [prototypeDir] [outDir]
import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';

const root = path.resolve(import.meta.dirname, '../..');
const protoDir = path.resolve(process.argv[2] ?? path.join(root, '../jarina-mobile'));
const outDir = path.resolve(process.argv[3] ?? path.join(root, 'apps/mobile/assets/seed'));

const src = fs.readFileSync(path.join(protoDir, 'js/01-data.js'), 'utf8');
const exportNames = ['FLAG_ART', 'STOCKS', 'COINS', 'ABOUT', 'RECIPIENTS', 'ME', 'COUNTRIES', 'CNAME', 'REGIONS', 'REGION_WORD', 'LANGS', 'BILLS', 'CURS', 'FX'];
const ctx = {};
vm.createContext(ctx);
// `const` bindings are not exposed on the context object, so collect them explicitly.
vm.runInContext(src + `\n;globalThis.__out = { ${exportNames.join(', ')} };`, ctx);
const d = ctx.__out;

const write = (name, data) => {
  fs.writeFileSync(path.join(outDir, name), JSON.stringify(data, null, 2) + '\n');
  console.log(`  ${name}`);
};
fs.mkdirSync(outDir, { recursive: true });
console.log(`Seed → ${path.relative(process.cwd(), outDir)}`);

// Badge colours and monograms come from the prototype's own helpers in
// 02-app.js (lines defining COIN_GLYPH … stockMono), so badges match exactly.
const app = fs.readFileSync(path.join(protoDir, 'js/02-app.js'), 'utf8').split('\n');
const start = app.findIndex((l) => l.startsWith('const COIN_GLYPH'));
const end = app.findIndex((l) => l.startsWith('const stockMono'));
const badgeCtx = {};
vm.createContext(badgeCtx);
vm.runInContext(
  app.slice(start, end + 1).join('\n') + '\n;globalThis.__b = { COIN_GLYPH, mixHex, stockCol, stockMono };',
  badgeCtx,
);
const badge = badgeCtx.__b;
const badgeFor = (a) => a.type === 'crypto'
  ? { color: a.fg, ring: a.bg, ink: '#FFFFFF', label: badge.COIN_GLYPH[a.id] ?? a.id[0] }
  : (() => {
      const k = badge.stockCol(a);
      return { color: k.c, ring: badge.mixHex(k.c, '#FFFFFF', 0.84), ink: k.t, label: badge.stockMono(a) };
    })();

const assets = [...d.STOCKS, ...d.COINS].map(({ seed, bg, fg, ...a }) => ({
  ...a,
  badge: badgeFor({ ...a, bg, fg }),
  // Prices stay as strings so they are parsed into Decimal, never double.
  price: String(a.price),
  about: d.ABOUT[a.id] ?? null,
}));
write('assets.json', assets);
write('recipients.json', d.RECIPIENTS);
write('me.json', d.ME);
write('countries.json', d.COUNTRIES.map((c) => ({
  ...c,
  regionWord: d.REGION_WORD[c.iso],
  regions: d.REGIONS[c.iso] ?? [],
})));
write('country_names.json', d.CNAME);
write('languages.json', Object.fromEntries(Object.entries(d.LANGS).map(([k, [en, native]]) => [k, { en, native }])));
write('bills.json', d.BILLS);
write('fx.json', Object.fromEntries(d.CURS.map((c) => [c, {
  symbol: d.FX[c].sym.trim(),
  decimals: d.FX[c].d,
  perNgn: String(d.FX[c].r),
}])));

const flagDir = path.join(root, 'packages/jarina_ui/assets/flags');
for (const [iso, art] of Object.entries(d.FLAG_ART)) {
  fs.writeFileSync(
    path.join(flagDir, `${iso.toLowerCase()}.svg`),
    `<svg xmlns="http://www.w3.org/2000/svg" width="60" height="40" viewBox="0 0 30 20">${art}</svg>\n`,
  );
}
console.log(`Flags → ${path.relative(process.cwd(), flagDir)} (${Object.keys(d.FLAG_ART).length})`);
