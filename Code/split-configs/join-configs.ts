const { writeFileSync, readdirSync } = require('node:fs')

function getPartialConfig(
  dir: string,
  isArray = true,
  fts = ['json'],
  excludedFilenames = ['package.json', 'package-lock.json'],
) {
  const configs: KeyBinding[] | Record<string, any> = isArray ? [] : {}

  const filenames = readdirSync(dir).filter((filename: string) => {
    const ft = filename.split('.').slice(-1)[0]
    return !excludedFilenames.includes(filename) && fts.includes(ft)
  })

  process.stdout.write(
    `Found ${filenames.length} valid files: ${filenames.join(', ')}\n`,
  )

  for (const filename of filenames) {
    process.stdout.write(`Processing file: ${filename}\n`)
    const partialConfigs = require(`${dir}/${filename}`)

    if (Array.isArray(configs)) {
      configs.push(...partialConfigs)
      continue
    }

    for (const key in partialConfigs) {
      if (key in configs && Array.isArray(configs[key])) {
        configs[key].push(...partialConfigs[key])
        continue
      }

      configs[key] = partialConfigs[key]
    }
  }

  process.stdout.write('Got partial config files done\n')
  return configs
}

type KeyBinding = {
  key: string
  command: string
  when: string
}

function removeDuplicatedConfigs(configs: KeyBinding[]) {
  process.stdout.write('Removing dupplicated configs\n')
  const originalConfigCount = configs.length
  let removeCount = 0

  for (let i = 0; i < configs.length; i++) {
    const { key, command, when } = configs[i]

    for (const oldConfig of configs.slice(0, i)) {
      const { key: _key, command: _command, when: _when } = oldConfig

      if (key === _key && command === _command && when === _when) {
        process.stdout.write(`Dupplicated config: ${command} ${when}\n`)
        configs.splice(i, 1)
        i--
        removeCount++
        break
      }
    }
  }

  process.stdout.write(
    `Removed ${removeCount}/${originalConfigCount} configs\n`,
  )
}

function gatherVsCodeConfig(opts: {
  configPath: string
  partialDir: string
  isArray?: boolean
  fts?: string[]
  excludedFilenames?: string[]
}) {
  const { configPath, partialDir, isArray, fts, excludedFilenames } = opts
  const configs = getPartialConfig(partialDir, isArray, fts, excludedFilenames)
  isArray && Array.isArray(configs) && removeDuplicatedConfigs(configs)
  writeFileSync(configPath, JSON.stringify(configs, null, '\t'))

  process.stdout.write(
    `Wrote ${Array.isArray(configs) ? configs.length : 1} configs to ${configPath}\n`,
  )
}

export function formatPath(rawPath: string | undefined) {
  const { HOME } = process.env

  if (!rawPath) {
    throw new Error('Path not found')
  }

  if (!HOME) {
    throw new Error('HOME environment variable not found')
  }

  return rawPath.replace(/^~/, HOME)
}

export function joinConfigs(input: {
  keybindingsPath: string
  settingsPath: string
  keybindingsPartialPath: string
  settingsPartialPath: string
  excludedFilenames?: string[]
}) {
  const {
    keybindingsPath,
    keybindingsPartialPath,
    settingsPath,
    settingsPartialPath,
    excludedFilenames,
  } = input

  gatherVsCodeConfig({
    configPath: keybindingsPath,
    partialDir: keybindingsPartialPath,
    excludedFilenames,
  })

  gatherVsCodeConfig({
    configPath: settingsPath,
    partialDir: settingsPartialPath,
    isArray: false,
    excludedFilenames,
  })
}
