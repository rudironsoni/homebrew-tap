#!/usr/bin/env node

import { appendFileSync, readFileSync, statSync, writeFileSync } from 'node:fs'
import { createHash } from 'node:crypto'

const stableTag = /^v(\d+)\.(\d+)\.(\d+)-horca\.(\d+)$/
const betaTag = /^v(\d+)\.(\d+)\.(\d+)-horca-beta\.(\d+)$/
const channel = process.env.CHANNEL

if (!['stable', 'beta'].includes(channel)) throw new Error(`Invalid channel: ${channel}`)

const output = (name, value) => appendFileSync(process.env.GITHUB_OUTPUT, `${name}=${value}\n`)
const pattern = channel === 'stable' ? stableTag : betaTag
const token = channel === 'stable' ? 'horca' : 'horca@beta'

function versionTuple(tag) {
  return tag.match(pattern)?.slice(1).map((value) => BigInt(value))
}

function compareTuple(left, right) {
  for (let index = 0; index < left.length; index += 1) {
    if (left[index] !== right[index]) return left[index] > right[index] ? 1 : -1
  }
  return 0
}

async function github(path) {
  const headers = {
    Accept: 'application/vnd.github+json',
    'X-GitHub-Api-Version': '2022-11-28',
  }
  if (process.env.GH_TOKEN) headers.Authorization = `Bearer ${process.env.GH_TOKEN}`
  const response = await fetch(`https://api.github.com${path}`, {
    headers,
  })
  if (!response.ok) throw new Error(`GitHub API ${response.status}: ${path}`)
  return response.json()
}

async function select() {
  const releases = await github('/repos/rudironsoni/orca/releases?per_page=100')
  const requestedTag = process.env.REQUESTED_TAG
  const candidates = releases.filter((release) => {
    if (release.draft || release.prerelease !== (channel === 'beta')) return false
    if (!pattern.test(release.tag_name)) return false
    return !requestedTag || release.tag_name === requestedTag
  })
  candidates.sort((left, right) => compareTuple(versionTuple(right.tag_name), versionTuple(left.tag_name)))
  const release = candidates[0]
  if (!release) {
    if (requestedTag) throw new Error(`Published ${channel} release not found: ${requestedTag}`)
    output('found', 'false')
    return
  }
  const ref = await github(`/repos/rudironsoni/orca/git/ref/tags/${encodeURIComponent(release.tag_name)}`)
  let target = ref.object
  if (target.type === 'tag') target = await github(`/repos/rudironsoni/orca/git/tags/${target.sha}`)
  const sourceSha = target.object?.sha ?? target.sha
  if (!/^[a-f0-9]{40}$/.test(sourceSha)) throw new Error(`Invalid source SHA for ${release.tag_name}`)
  if (process.env.REQUESTED_SHA && sourceSha !== process.env.REQUESTED_SHA) {
    throw new Error(`Release source ${sourceSha} does not match dispatch ${process.env.REQUESTED_SHA}`)
  }
  output('found', 'true')
  output('tag', release.tag_name)
  output('version', release.tag_name.slice(1))
  output('source_sha', sourceSha)
}

function compare() {
  const path = `Casks/${token}.rb`
  let current
  try {
    current = readFileSync(path, 'utf8').match(/^  version "([^"]+)"$/m)?.[1]
  } catch {
    current = undefined
  }
  const next = process.env.VERSION
  if (!pattern.test(`v${next}`)) throw new Error(`Invalid ${channel} version: ${next}`)
  if (current && compareTuple(versionTuple(`v${next}`), versionTuple(`v${current}`)) < 0) {
    throw new Error(`Refusing downgrade from ${current} to ${next}`)
  }
  output('changed', String(current !== next))
}

function digest(path) {
  return createHash('sha256').update(readFileSync(path)).digest('hex')
}

function loadManifest(path) {
  const manifest = JSON.parse(readFileSync(path, 'utf8'))
  if (manifest.schemaVersion !== 1 || manifest.channel !== channel || !pattern.test(manifest.tag)) {
    throw new Error('Release manifest does not match the selected channel')
  }
  if (manifest.version !== manifest.tag.slice(1) || !/^[a-f0-9]{40}$/.test(manifest.sourceSha)) {
    throw new Error('Release manifest identity is invalid')
  }
  if (process.env.TAG && manifest.tag !== process.env.TAG) throw new Error('Release manifest tag mismatch')
  if (process.env.SOURCE_SHA && manifest.sourceSha !== process.env.SOURCE_SHA) {
    throw new Error('Release manifest source mismatch')
  }
  return manifest
}

function verify(manifestPath, artifactDirectory) {
  const manifest = loadManifest(manifestPath)
  for (const artifact of manifest.artifacts) {
    const path = `${artifactDirectory}/${artifact.name}`
    if (statSync(path).size !== artifact.size || digest(path) !== artifact.sha256) {
      throw new Error(`Artifact verification failed: ${artifact.name}`)
    }
  }
  const sums = readFileSync(`${artifactDirectory}/SHA256SUMS`, 'utf8').trim().split('\n')
  for (const artifact of manifest.artifacts) {
    if (!sums.includes(`${artifact.sha256}  ${artifact.name}`)) {
      throw new Error(`SHA256SUMS is missing ${artifact.name}`)
    }
  }
}

function render(manifestPath) {
  const manifest = loadManifest(manifestPath)
  const arm = manifest.artifacts.find((item) => item.name === 'horca-macos-arm64.dmg')
  const intel = manifest.artifacts.find((item) => item.name === 'horca-macos-x64.dmg')
  if (!arm?.signed || !arm.notarized || !intel?.signed || !intel.notarized) {
    throw new Error('Homebrew requires signed and notarized macOS artifacts')
  }
  const conflict = channel === 'stable' ? 'horca@beta' : 'horca'
  const livecheck = channel === 'beta'
    ? `\n  livecheck do\n    url :url\n    regex(/^v(\\d+(?:\\.\\d+)+-horca-beta\\.\\d+)$/i)\n    strategy :github_releases do |json, regex|\n      json.filter_map do |release|\n        next if release["draft"] || !release["prerelease"]\n\n        release["tag_name"]&.[](regex, 1)\n      end\n    end\n  end\n`
    : `\n  livecheck do\n    url :url\n    regex(/^v(\\d+(?:\\.\\d+)+-horca\\.\\d+)$/i)\n    strategy :github_latest\n  end\n`
  writeFileSync(`Casks/${token}.rb`, `cask "${token}" do
  arch arm: "arm64", intel: "x64"

  version "${manifest.version}"
  sha256 arm:   "${arm.sha256}",
         intel: "${intel.sha256}"

  url "https://github.com/rudironsoni/orca/releases/download/v#{version}/horca-macos-#{arch}.dmg"
  name "Horca"
  desc "Downstream Orca distribution with additional integrations"
  homepage "https://github.com/rudironsoni/orca"
${livecheck}
  conflicts_with cask: "${conflict}"
  depends_on macos: :big_sur

  app "Horca.app"
  binary "#{appdir}/Horca.app/Contents/Resources/bin/horca"

  zap trash: [
    "~/.horca",
    "~/Library/Application Support/Horca",
    "~/Library/Caches/com.rudironsoni.horca",
    "~/Library/Caches/com.rudironsoni.horca.ShipIt",
    "~/Library/HTTPStorages/com.rudironsoni.horca",
    "~/Library/Preferences/com.rudironsoni.horca.plist",
    "~/Library/Saved Application State/com.rudironsoni.horca.savedState",
  ]
end
`)
}

const [command, ...args] = process.argv.slice(2)
if (command === 'select') await select()
else if (command === 'compare') compare()
else if (command === 'verify') verify(...args)
else if (command === 'render') render(...args)
else throw new Error(`Unknown command: ${command}`)
