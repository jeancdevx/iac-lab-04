import {
  S3Client,
  GetObjectCommand,
  PutObjectCommand
} from '@aws-sdk/client-s3'
import sharp from 'sharp'

const s3 = new S3Client({})
const TARGET_SIZE = 40
const PROCESSED_PREFIX = process.env.PROCESSED_PREFIX || 'processed'

async function streamToBuffer(stream) {
  return new Promise((resolve, reject) => {
    const chunks = []
    stream.on('data', (c) => chunks.push(c))
    stream.on('error', reject)
    stream.on('end', () => resolve(Buffer.concat(chunks)))
  })
}

function makeCircleMask(size) {
  const svg = `<svg width="${size}" height="${size}"><rect x="0" y="0" width="${size}" height="${size}" fill="black" /><circle cx="${size / 2}" cy="${size / 2}" r="${size / 2}" fill="white"/></svg>`
  return Buffer.from(svg)
}

async function processObject(bucket, key) {
  const get = await s3.send(new GetObjectCommand({ Bucket: bucket, Key: key }))
  const body = await streamToBuffer(get.Body)

  const resized = await sharp(body).resize(TARGET_SIZE, TARGET_SIZE).toBuffer()
  const mask = makeCircleMask(TARGET_SIZE)
  const circular = await sharp(resized)
    .composite([{ input: mask, blend: 'dest-in' }])
    .png()
    .toBuffer()

  const baseName = key.split('/').pop()
  const outKey = `${PROCESSED_PREFIX}/${baseName.replace(/\.[^.]+$/, '')}-40x40.png`

  await s3.send(
    new PutObjectCommand({
      Bucket: bucket,
      Key: outKey,
      Body: circular,
      ContentType: 'image/png'
    })
  )

  return outKey
}

export const handler = async (event) => {
  console.log(
    'Crop Lambda invoked, records:',
    event.records ? event.records.length : event.Records.length
  )

  const records = event.Records || event.records || []

  for (const rec of records) {
    try {
      const body = typeof rec.body === 'string' ? JSON.parse(rec.body) : rec

      const s3Records = body.Records || []
      for (const s3rec of s3Records) {
        const bucket = s3rec.s3.bucket.name
        const key = decodeURIComponent(s3rec.s3.object.key.replace(/\+/g, ' '))
        console.log('Processing', bucket, key)
        const outKey = await processObject(bucket, key)
        console.log('Processed ->', outKey)
      }
    } catch (err) {
      console.error('Processing record failed, will rethrow to retry:', err)
      throw err
    }
  }

  return { status: 'ok' }
}
