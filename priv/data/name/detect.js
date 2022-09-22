const fs = require('fs')

const files = [
  'place.txt',
  'sector.txt',
  'firstname/female.txt',
  'firstname/male.txt',
  'foundation/cardanic.txt',
  'foundation/myrmeziriannic.txt',
  'foundation/stelloliberalism.txt',
  'foundation/syn.txt',
  'foundation/tetrarchic.txt'
]

// use a list like this one: https://github.com/snguyenthanh/better_profanity/blob/master/better_profanity/profanity_wordlist.txt
const wordlist = 'profanity_wordlist.txt'

const read = (file) => fs
  .readFileSync(file)
  .toString()
  .split('\n')
  .map(line => line.trim().toLowerCase())
  .filter(Boolean)

const banned = read(wordlist)

files.forEach((file) => {
  const detected = read(file)
    .filter((word) => banned.includes(word))

  if (detected.length) {
    console.log(`Detected in "${file}":\n${detected.join('\n')}`)
    console.log()
  }
})
