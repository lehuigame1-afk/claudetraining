// Extracts the inline <script> blocks from index.html into a temp file and
// syntax-checks them with `node --check`. CI helper only; not part of the app.
const fs = require("fs");
const os = require("os");
const path = require("path");
const { execFileSync } = require("child_process");

const html = fs.readFileSync("index.html", "utf8");
const blocks = [...html.matchAll(/<script>([\s\S]*?)<\/script>/g)];
if (!blocks.length) {
  console.error("No inline <script> found in index.html");
  process.exit(1);
}
const out = path.join(os.tmpdir(), "inline.js");
fs.writeFileSync(out, blocks.map((b) => b[1]).join("\n"));
execFileSync(process.execPath, ["--check", out], { stdio: "inherit" });
console.log("Inline script syntax OK (" + blocks.length + " block(s))");
