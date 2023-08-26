import { execSync } from 'node:child_process'
const currentDate = new Date()
const year = currentDate.getFullYear()
const month = currentDate.getMonth() + 1
const day = currentDate.getDate()

const commitMessage = `BUMP: lock: ${year}-${month}-${day}`
execSync( `git commit -i flake.lock -m '${commitMessage}'`)
