// CommandCode PostToolUse formatter hook.
//
// WHY A HOOK AND NOT A SKILL
// Skills are model-invoked: CommandCode surfaces one when a prompt looks like a
// match, but the model decides. Formatting is not a judgement call - a file that
// was just written should be formatted whether or not anyone remembers to ask.
// PostToolUse fires automatically after every write/edit, which is exactly the
// guarantee wanted, so this is a hook.
//
// WHY NOT AN LSP
// CommandCode has no language-server integration at all. There is no
// documentSymbol, hover or goToDefinition in the product, so the language-server
// half of the Grok setup has nothing to attach to. What ports is the automatic
// formatting, which is the part that did not depend on an LSP.
//
// CONTRACT
// CommandCode pipes one JSON object to stdin and reads one JSON object from
// stdout. Empty stdout on exit 0 means "no opinion" and the tool proceeds. The
// payload differs from Grok's in the places this file reads:
//   Grok      event.toolInput.file_path
//   CommandCode event.tool_input.file_path      (snake_case, plus tool_display_name)
// Both shapes are accepted so one file works under either harness.
//
// Sibling file: format.json holds the extension -> formatter table, so adding a
// language is a config edit rather than a code change.

const fs = require("fs");
const path = require("path");
const { spawnSync } = require("child_process");

const dir = __dirname;
const log = (...parts) =>
	process.stderr.write("commandcode-format: " + parts.join(" ") + "\n");

function readStdin() {
	try {
		return fs.readFileSync(0, "utf8");
	} catch {
		return "";
	}
}

// CommandCode and Grok nest the tool arguments differently, and tools disagree
// on the path key. Cover the shapes seen in the wild rather than guessing.
function extractPath(event) {
	const ti = event.tool_input || event.toolInput || event.input || {};
	let p = ti.file_path || ti.filePath || ti.path || ti.file || "";
	if (!p && Array.isArray(ti.edits) && ti.edits.length) {
		const first = ti.edits[0] || {};
		p = first.file_path || first.filePath || first.path || "";
	}
	return typeof p === "string" ? p : "";
}

// Only writes and edits carry a new file body. A read or a shell command is not
// something to reformat, and running a formatter on those wastes a spawn.
const WRITE_TOOLS = new Set([
	"write",
	"edit",
	"write_file",
	"edit_file",
	"Write",
	"Edit",
]);

function isWriteEvent(event) {
	const display = event.tool_display_name;
	if (typeof display === "string" && display.trim()) {
		return WRITE_TOOLS.has(display.trim().toLowerCase());
	}
	const name = event.tool_name;
	if (typeof name === "string" && name.trim()) {
		return WRITE_TOOLS.has(name.trim().toLowerCase());
	}
	// No tool identity at all: fall through and let the extension check decide,
	// since a path ending in .rs is a reasonable signal on its own.
	return true;
}

function main() {
	let cfg;
	try {
		cfg = JSON.parse(fs.readFileSync(path.join(dir, "format.json"), "utf8"));
	} catch (err) {
		log("format.json unreadable: " + err.message);
		return 0;
	}

	const raw = readStdin();
	if (!raw.trim()) return 0;

	let event;
	try {
		event = JSON.parse(raw);
	} catch {
		return 0;
	}

	// CommandCode names the events PreToolUse / PostToolUse. If this ever fires on
	// a pre-event there is nothing written yet, so leave it alone.
	if (event.hook_event_name && event.hook_event_name !== "PostToolUse") {
		if (process.env.COMMANDCODE_FORMAT_DEBUG === "1") {
			log("skipping event " + event.hook_event_name);
		}
	}

	if (!isWriteEvent(event)) return 0;

	const file = extractPath(event);
	if (!file) return 0;

	const ext = path.extname(file).toLowerCase();
	const wanted = (cfg.extensions || []).map((e) => e.toLowerCase());
	if (!wanted.includes(ext)) return 0;

	if (!fs.existsSync(file)) return 0;

	const steps =
		cfg.commands ||
		(cfg.command ? [{ command: cfg.command, args: cfg.args }] : []);

	// Run from the file's own directory so tools that walk upward for their
	// config (biome.json, eslint.config.*, .rustfmt.toml, pyproject.toml) find it.
	const cwd = path.dirname(file);
	const debug = process.env.COMMANDCODE_FORMAT_DEBUG === "1";

	for (const step of steps) {
		if (!step || !step.command) continue;

		// A step may be scoped to certain extensions, so one config can hold both
		// "biome for .ts" and "eslint for .ts" without one clobbering the other.
		if (
			Array.isArray(step.only) &&
			!step.only.map((e) => e.toLowerCase()).includes(ext)
		) {
			continue;
		}

		const args = (step.args || []).concat([file]);
		const res = spawnSync(step.command, args, {
			cwd,
			stdio: ["ignore", "pipe", "pipe"],
			windowsHide: true,
			// Node 20+ refuses to spawn .cmd/.bat without a shell (CVE-2024-27980),
			// which is exactly what npx and npm-installed shims are on Windows.
			shell: step.shell === true,
		});

		if (res.error) {
			log(step.command + " could not run: " + res.error.message);
			continue;
		}
		if (res.status !== 0) {
			const out = (res.stderr || res.stdout || Buffer.from(""))
				.toString()
				.trim();
			log(
				step.command +
					" exited " +
					res.status +
					(out ? ": " + out.split("\n")[0] : ""),
			);
			continue;
		}
		if (debug)
			log("formatted " + path.basename(file) + " with " + step.command);
	}

	return 0;
}

// A formatter must never be the reason a tool call fails.
try {
	process.exitCode = main();
} catch (err) {
	log("hook error: " + (err && err.message));
	process.exitCode = 0;
}
