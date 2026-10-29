const assert = require('node:assert/strict');
const {spawnSync} = require('node:child_process');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');

const root = process.env.CHATWOOT_PACKAGE_ROOT || path.resolve(__dirname, '../..');

function filesIn(directory) {
  return fs.readdirSync(directory, {withFileTypes: true}).flatMap(entry => {
    const filename = path.join(directory, entry.name);
    return entry.isDirectory() ? filesIn(filename) : [filename];
  });
}

test('every generated part referenced by the library exists in a clean checkout', () => {
  let count = 0;
  for (const filename of filesIn(path.join(root, 'lib')).filter(f => f.endsWith('.dart'))) {
    const source = fs.readFileSync(filename, 'utf8');
    for (const match of source.matchAll(/^part ['"]([^'"]+\.g\.dart)['"];$/gm)) {
      const part = path.join(path.dirname(filename), match[1]);
      assert.ok(fs.existsSync(part), `Missing generated part: ${part}`);
      count++;
    }
  }
  assert.ok(count > 0, 'Expected to find the SDK model part directives');
});

test('generated library sources are tracked and not gitignored', () => {
  const generated = filesIn(path.join(root, 'lib'))
    .filter(f => f.endsWith('.g.dart')).map(f => path.relative(root, f));
  assert.ok(generated.length > 0);
  const tracked = spawnSync('git', ['ls-files', '--error-unmatch', '--', ...generated],
    {cwd: root, encoding: 'utf8'});
  assert.equal(tracked.status, 0, tracked.stderr);
  const ignored = spawnSync('git', ['check-ignore', '--no-index', '--stdin'],
    {cwd: root, encoding: 'utf8', input: generated.join('\n') + '\n'});
  assert.equal(ignored.status, 1, `Generated sources would be omitted: ${ignored.stdout}${ignored.stderr}`);
});
