const { writeFileSync, readdirSync, statSync } = require("node:fs");
const { join } = require("node:path");

// Add type declaration for better performance analysis
declare const process: {
	stdout: { write: (str: string) => void };
	env: Record<string, string | undefined>;
};

function getPartialConfigRecursive(
	dir: string,
	isArray = true,
	fts = ["json"],
	excludedFilenames = ["package.json", "package-lock.json"],
): KeyBinding[] | Record<string, any> {
	const configs: KeyBinding[] | Record<string, any> = isArray ? [] : {};

	function processDirectory(currentDir: string, depth = 0) {
		const indent = "  ".repeat(depth);

		try {
			const items = readdirSync(currentDir);

			for (const item of items) {
				const itemPath = join(currentDir, item);
				const stat = statSync(itemPath);

				if (stat.isDirectory()) {
					process.stdout.write(`${indent}📁 Processing directory: ${item}\n`);
					processDirectory(itemPath, depth + 1);
				} else if (stat.isFile()) {
					const ft = item.split(".").slice(-1)[0];
					if (!excludedFilenames.includes(item) && fts.includes(ft)) {
						process.stdout.write(`${indent}📄 Processing file: ${item}\n`);

						try {
							const partialConfigs = require(itemPath);

							// Skip empty arrays
							if (
								isArray &&
								Array.isArray(partialConfigs) &&
								partialConfigs.length === 0
							) {
								process.stdout.write(
									`${indent}⏭️ Skipping empty file: ${item}\n`,
								);
								continue;
							}

							if (Array.isArray(configs)) {
								configs.push(...partialConfigs);
								process.stdout.write(
									`${indent}✅ Loaded ${partialConfigs.length} keybindings from ${item}\n`,
								);
							} else {
								// Handle object merging for settings
								for (const key in partialConfigs) {
									if (key in configs && Array.isArray(configs[key])) {
										configs[key].push(...partialConfigs[key]);
									} else {
										configs[key] = partialConfigs[key];
									}
								}
								process.stdout.write(
									`${indent}✅ Merged settings from ${item}\n`,
								);
							}
						} catch (error) {
							process.stdout.write(
								`${indent}❌ Error reading file ${item}: ${error.message}\n`,
							);
							throw error;
						}
					}
				}
			}
		} catch (error) {
			process.stdout.write(
				`${indent}❌ Error reading directory ${currentDir}: ${error.message}\n`,
			);
			throw error;
		}
	}

	process.stdout.write(`🚀 Starting recursive processing of: ${dir}\n`);
	processDirectory(dir);
	process.stdout.write(
		`✨ Recursive processing complete. Total items: ${Array.isArray(configs) ? configs.length : Object.keys(configs).length}\n`,
	);

	return configs;
}

// Legacy function for backward compatibility
function getPartialConfig(
	dir: string,
	isArray = true,
	fts = ["json"],
	excludedFilenames = ["package.json", "package-lock.json"],
) {
	// Use the new recursive function
	return getPartialConfigRecursive(dir, isArray, fts, excludedFilenames);
}

type KeyBinding = {
	key: string;
	command: string;
	when: string;
};

function removeDuplicatedConfigs(configs: KeyBinding[]) {
	process.stdout.write("Removing dupplicated configs\n");
	const originalConfigCount = configs.length;
	let removeCount = 0;

	for (let i = 0; i < configs.length; i++) {
		const { key, command, when } = configs[i];

		for (const oldConfig of configs.slice(0, i)) {
			const { key: _key, command: _command, when: _when } = oldConfig;

			if (key === _key && command === _command && when === _when) {
				process.stdout.write(`Dupplicated config: ${command} ${when}\n`);
				configs.splice(i, 1);
				i--;
				removeCount++;
				break;
			}
		}
	}

	process.stdout.write(
		`Removed ${removeCount}/${originalConfigCount} configs\n`,
	);
}

function gatherVsCodeConfig(opts: {
	configPath: string;
	partialDir: string;
	isArray?: boolean;
	fts?: string[];
	excludedFilenames?: string[];
}) {
	const { configPath, partialDir, isArray, fts, excludedFilenames } = opts;
	const configs = getPartialConfig(partialDir, isArray, fts, excludedFilenames);
	isArray && Array.isArray(configs) && removeDuplicatedConfigs(configs);
	writeFileSync(configPath, JSON.stringify(configs, null, "\t"));

	process.stdout.write(
		`Wrote ${Array.isArray(configs) ? configs.length : 1} configs to ${configPath}\n`,
	);
}

export function formatPath(rawPath: string | undefined) {
	const { HOME } = process.env;

	if (!rawPath) {
		throw new Error("Path not found");
	}

	if (!HOME) {
		throw new Error("HOME environment variable not found");
	}

	return rawPath.replace(/^~/, HOME);
}

export function joinConfigs(input: {
	keybindingsPath: string;
	settingsPath: string;
	keybindingsPartialPath: string;
	settingsPartialPath: string;
	excludedFilenames?: string[];
}) {
	const {
		keybindingsPath,
		keybindingsPartialPath,
		settingsPath,
		settingsPartialPath,
		excludedFilenames,
	} = input;

	gatherVsCodeConfig({
		configPath: keybindingsPath,
		partialDir: keybindingsPartialPath,
		excludedFilenames,
	});

	gatherVsCodeConfig({
		configPath: settingsPath,
		partialDir: settingsPartialPath,
		isArray: false,
		excludedFilenames,
	});
}
