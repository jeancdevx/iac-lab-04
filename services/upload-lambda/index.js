import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3'
import Busboy from 'busboy'
import { v4 as uuidv4 } from 'uuid'

const s3Client = new S3Client({ region: process.env.AWS_REGION })

const BUCKET_NAME = process.env.S3_BUCKET
const UPLOAD_PREFIX = process.env.UPLOAD_PREFIX || 'uploads'
const MAX_FILE_SIZE = 10 * 1024 * 1024
const ALLOWED_MIME_TYPES = [
  'image/jpeg',
  'image/png',
  'image/gif',
  'image/webp'
]
const ALLOWED_EXTENSIONS = ['.jpg', '.jpeg', '.png', '.gif', '.webp']

function validateFile(filename, mimetype) {
  const ext = filename.toLowerCase().slice(filename.lastIndexOf('.'))

  if (!ALLOWED_EXTENSIONS.includes(ext)) {
    return {
      valid: false,
      error: `Invalid file extension. Allowed: ${ALLOWED_EXTENSIONS.join(', ')}`
    }
  }

  if (!ALLOWED_MIME_TYPES.includes(mimetype)) {
    return {
      valid: false,
      error: `Invalid MIME type. Allowed: ${ALLOWED_MIME_TYPES.join(', ')}`
    }
  }

  return { valid: true }
}

async function handleMultipart(event, body) {
  return new Promise((resolve, reject) => {
    const bb = Busboy({
      headers: event.headers,
      limits: { fileSize: MAX_FILE_SIZE }
    })

    let fileBuffer = Buffer.alloc(0)
    let filename = null
    let mimetype = null
    let fileSize = 0

    bb.on('file', (fieldname, file, info) => {
      filename = info.filename
      mimetype = info.mimeType

      file.on('data', (chunk) => {
        fileBuffer = Buffer.concat([fileBuffer, chunk])
        fileSize += chunk.length

        if (fileSize > MAX_FILE_SIZE) {
          file.destroy()
          reject(new Error('File size exceeds 10 MB limit'))
        }
      })

      file.on('end', () => {})

      file.on('error', reject)
    })

    bb.on('finish', () => {
      resolve({ filename, mimetype, fileBuffer })
    })

    bb.on('error', reject)

    bb.write(body)
    bb.end()
  })
}

async function handleBase64(body) {
  try {
    const data = JSON.parse(body)

    if (!data.filename || !data.data) {
      throw new Error('Missing filename or data field')
    }

    const buffer = Buffer.from(data.data, 'base64')

    if (buffer.length > MAX_FILE_SIZE) {
      throw new Error('File size exceeds 10 MB limit')
    }

    return {
      filename: data.filename,
      mimetype: data.mimetype || 'application/octet-stream',
      fileBuffer: buffer
    }
  } catch (error) {
    throw new Error(`Failed to parse base64: ${error.message}`)
  }
}

async function uploadToS3(filename, fileBuffer, mimetype) {
  const fileId = uuidv4()
  const key = `${UPLOAD_PREFIX}/${fileId}-${filename}`

  const command = new PutObjectCommand({
    Bucket: BUCKET_NAME,
    Key: key,
    Body: fileBuffer,
    ContentType: mimetype,
    Metadata: {
      'original-filename': filename,
      'upload-timestamp': new Date().toISOString()
    }
  })

  await s3Client.send(command)

  return {
    fileId,
    s3Key: key,
    bucket: BUCKET_NAME
  }
}

export const handler = async (event) => {
  console.log('Upload Lambda invoked', {
    path: event.rawPath,
    method: event.requestContext.http.method
  })

  try {
    if (!BUCKET_NAME) {
      return {
        statusCode: 500,
        body: JSON.stringify({
          error: 'S3_BUCKET environment variable not set'
        })
      }
    }

    if (event.requestContext.http.method !== 'POST') {
      return {
        statusCode: 405,
        body: JSON.stringify({ error: 'Method not allowed' })
      }
    }

    let file
    const contentType = event.headers['content-type'] || ''

    if (contentType.includes('multipart/form-data')) {
      const body = event.isBase64Encoded
        ? Buffer.from(event.body, 'base64')
        : event.body
      file = await handleMultipart(event, body)
    } else if (contentType.includes('application/json')) {
      file = await handleBase64(event.body)
    } else {
      return {
        statusCode: 400,
        body: JSON.stringify({
          error:
            'Unsupported content-type. Use multipart/form-data or application/json with base64'
        })
      }
    }

    const validation = validateFile(file.filename, file.mimetype)
    if (!validation.valid) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: validation.error })
      }
    }

    const uploadResult = await uploadToS3(
      file.filename,
      file.fileBuffer,
      file.mimetype
    )

    console.log('File uploaded successfully', uploadResult)

    return {
      statusCode: 201,
      body: JSON.stringify({
        message: 'File uploaded successfully',
        fileId: uploadResult.fileId,
        s3Key: uploadResult.s3Key,
        bucket: uploadResult.bucket
      })
    }
  } catch (error) {
    console.error('Upload error:', error)

    return {
      statusCode: 500,
      body: JSON.stringify({
        error: error.message || 'Internal server error'
      })
    }
  }
}
