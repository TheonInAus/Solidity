/* eslint-disable no-console */

import { unixfs } from '@helia/unixfs'
import { createHelia } from 'helia'

const helia = await createHelia()

const fs = unixfs(helia)

const encoder = new TextEncoder()

const cid = await fs.addBytes(encoder.encode('Quality CHECK'), {
  onProgress: (evt) => {
    console.info('add event', evt.type, evt.detail)
  }
})

console.log('Added file:', cid.toString())

const decoder = new TextDecoder()
let text = ''

for await (const chunk of fs.cat(cid, {
  onProgress: (evt) => {
    console.info('cat event', evt.type, evt.detail)
  }
})) {
  text += decoder.decode(chunk, {
    stream: true
  })
}

console.log('Added file contents:', text)