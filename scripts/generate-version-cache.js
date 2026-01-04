const { execSync } = require("child_process");
const fs = require("fs");
const path = require("path");

function git(cmd) {
  try {
    return execSync(`git ${cmd}`, { encoding: "utf8" }).trim();
  } catch {
    return null;
  }
}

const hash = git("rev-parse --short HEAD") || "initial";
const msg = git("log -1 --format=%s") || "Initial commit";
const date = git("log -1 --format=%ci") || new Date().toISOString();
const now = new Date().toISOString().replace("T", " ").slice(0, 19);

const cache = {
  version: hash,
  commit: msg,
  date: date,
  cached_at: now,
};

const cachePath = path.join(__dirname, "..", "mods", "ModpackUpdater", "version_cache.json");
fs.mkdirSync(path.dirname(cachePath), { recursive: true });

const oldContent = fs.existsSync(cachePath) ? fs.readFileSync(cachePath, "utf8") : "";
const newContent = JSON.stringify(cache, null, 2) + "\n";

if (oldContent !== newContent) {
  fs.writeFileSync(cachePath, newContent);
  execSync("git add mods/ModpackUpdater/version_cache.json");
  execSync('git commit -m "update version_cache.json"');
  console.log("Created commit with version_cache.json:", cache.version);
} else {
  console.log("version_cache.json unchanged, skipping commit");
}