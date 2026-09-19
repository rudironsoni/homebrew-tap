import assert from 'node:assert/strict'
import { createHash } from 'node:crypto'
import { mkdtempSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { join } from 'node:path'
import { spawnSync } from 'node:child_process'
import test from 'node:test'

const script = new URL('./update-horca-channel.mjs', import.meta.url).pathname

function run(directory, channel, args) {
  const result = spawnSync(process.execPath, [script, ...args], {
    cwd: directory,
    encoding: 'utf8',
    env: { ...process.env, CHANNEL: channel },
  })
  assert.equal(result.status, 0, result.stderr)
}

test('verifies a manifest and renders the beta cask', () => {
  const directory = mkdtempSync(join(tmpdir(), 'horca-tap-test-'))
  const artifacts = join(directory, 'artifacts')
  mkdirSync(artifacts)
  mkdirSync(join(directory, 'Casks'))
  const files = ['horca-macos-arm64.dmg', 'horca-macos-x64.dmg', 'horca-windows-x64-setup.exe']
  const entries = files.map((name) => {
    const content = Buffer.from(name)
    writeFileSync(join(artifacts, name), content)
    return {
      name,
      platform: name.includes('macos') ? 'macos' : 'windows',
      arch: name.includes('arm64') ? 'arm64' : 'x64',
      size: content.length,
      sha256: createHash('sha256').update(content).digest('hex'),
      signed: name.includes('macos'),
      notarized: name.includes('macos'),
    }
  })
  const manifest = {
    schemaVersion: 1,
    channel: 'beta',
    tag: 'v1.4.178-horca-beta.1',
    version: '1.4.178-horca-beta.1',
    sourceSha: 'a'.repeat(40),
    artifacts: entries,
  }
  const manifestPath = join(artifacts, 'horca-release.json')
  writeFileSync(manifestPath, JSON.stringify(manifest))
  writeFileSync(join(artifacts, 'SHA256SUMS'), `${entries.map((item) => `${item.sha256}  ${item.name}`).join('\n')}\n`)

  run(directory, 'beta', ['verify', manifestPath, artifacts])
  run(directory, 'beta', ['render', manifestPath])

  const cask = readFileSync(join(directory, 'Casks', 'horca@beta.rb'), 'utf8')
  assert.match(cask, /version "1\.4\.178-horca-beta\.1"/)
  assert.match(cask, /conflicts_with cask: "horca"/)
  assert.match(cask, /!release\["prerelease"\]/)
  assert.match(
    cask,
    /url "https:\/\/github.com\/rudironsoni\/horca\/releases\/download\/v#\{version\}\/horca-macos-#\{arch\}\.dmg"/
  )
  assert.match(cask, /homepage "https:\/\/github.com\/rudironsoni\/horca"/)
  assert.doesNotMatch(cask, /rudironsoni\/orca/)
})

test('renders the stable cask from rudironsoni/horca', () => {
  const directory = mkdtempSync(join(tmpdir(), 'horca-tap-stable-'))
  const artifacts = join(directory, 'artifacts')
  mkdirSync(artifacts)
  mkdirSync(join(directory, 'Casks'))
  const files = ['horca-macos-arm64.dmg', 'horca-macos-x64.dmg']
  const entries = files.map((name) => {
    const content = Buffer.from(name)
    writeFileSync(join(artifacts, name), content)
    return {
      name,
      platform: 'macos',
      arch: name.includes('arm64') ? 'arm64' : 'x64',
      size: content.length,
      sha256: createHash('sha256').update(content).digest('hex'),
      signed: true,
      notarized: true,
    }
  })
  const manifest = {
    schemaVersion: 1,
    channel: 'stable',
    tag: 'v1.4.205-horca.1',
    version: '1.4.205-horca.1',
    sourceSha: 'b'.repeat(40),
    artifacts: entries,
  }
  const manifestPath = join(artifacts, 'horca-release.json')
  writeFileSync(manifestPath, JSON.stringify(manifest))
  writeFileSync(join(artifacts, 'SHA256SUMS'), `${entries.map((item) => `${item.sha256}  ${item.name}`).join('\n')}\n`)

  run(directory, 'stable', ['verify', manifestPath, artifacts])
  run(directory, 'stable', ['render', manifestPath])

  const cask = readFileSync(join(directory, 'Casks', 'horca.rb'), 'utf8')
  assert.match(cask, /version "1\.4\.205-horca\.1"/)
  assert.match(
    cask,
    /url "https:\/\/github.com\/rudironsoni\/horca\/releases\/download\/v#\{version\}\/horca-macos-#\{arch\}\.dmg"/
  )
  assert.match(cask, /homepage "https:\/\/github.com\/rudironsoni\/horca"/)
  assert.doesNotMatch(cask, /rudironsoni\/orca/)
})

test('release machinery queries rudironsoni/horca and leaves live Casks on orca', () => {
  const scriptSource = readFileSync(new URL('./update-horca-channel.mjs', import.meta.url), 'utf8')
  const workflow = readFileSync(new URL('../.github/workflows/bump-horca-cask.yml', import.meta.url), 'utf8')
  const stableCask = readFileSync(new URL('../Casks/horca.rb', import.meta.url), 'utf8')
  const betaCask = readFileSync(new URL('../Casks/horca@beta.rb', import.meta.url), 'utf8')

  assert.match(scriptSource, /\/repos\/rudironsoni\/horca\/releases\?per_page=100/)
  assert.match(scriptSource, /\/repos\/rudironsoni\/horca\/git\/ref\/tags\//)
  assert.match(scriptSource, /\/repos\/rudironsoni\/horca\/git\/tags\//)
  assert.doesNotMatch(scriptSource, /\/repos\/rudironsoni\/orca\//)
  assert.match(workflow, /gh release download "\$TAG" --repo rudironsoni\/horca --dir artifacts/)
  assert.doesNotMatch(workflow, /--repo rudironsoni\/orca/)
  assert.match(stableCask, /github.com\/rudironsoni\/orca\/releases\/download/)
  assert.match(stableCask, /homepage "https:\/\/github.com\/rudironsoni\/orca"/)
  assert.match(betaCask, /github.com\/rudironsoni\/orca\/releases\/download/)
  assert.match(betaCask, /homepage "https:\/\/github.com\/rudironsoni\/orca"/)
})
