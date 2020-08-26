import { ConfigReader, EdgeFunction, EdgeFunctionService, GenerateUploadURL } from '../types'
import fetch from 'node-fetch'
import fs from 'fs'

const BASE_URL = 'https://platform.segmentapis.com'

export class EdgeFunctionAPI implements EdgeFunctionService {
  private configReader: ConfigReader

  constructor(configReader: ConfigReader) {
    this.configReader = configReader
  }

  public async upload(workspaceName: string, sourceName: string, file: string): Promise<EdgeFunction> {
    const token = (await this.configReader.fetch()).token
    const generateUrlResp = await fetch(
      `${ BASE_URL }/v1beta/workspaces/${ workspaceName }/sources/${ sourceName }/edge-functions/upload_url`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${ token }`,
        },
        body: '{}',
      })
    if (generateUrlResp.status === 403) {
      throw new Error(this.badTokenMsg())
    }
    if (generateUrlResp.status !== 200) {
      throw new Error(`error generating upload url, statusCode=${ generateUrlResp.status }`)
    }
    const generateBody: GenerateUploadURL = await generateUrlResp.json()
    const uploadUrl = generateBody.upload_url

    const fileBody = fs.readFileSync(file, 'utf8')
    const uploadResp = await fetch(uploadUrl, {
      method: 'PUT',
      body: fileBody,
    })
    if (uploadResp.status === 403) {
      throw new Error(this.badTokenMsg())
    }
    if (uploadResp.status !== 200) {
      throw new Error(`error uploading javascript bundle errorCode=${ uploadResp.status }`)
    }

    const createResp = await fetch(
      `${ BASE_URL }/v1beta/workspaces/${ workspaceName }/sources/${ sourceName }/edge-functions/`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${ token }`,
          'Content-Type': 'application/json',
        },
        body: `{
          upload_url: "${ uploadUrl }",
        }`,
      })
    if (createResp.status === 403) {
      throw new Error(this.badTokenMsg())
    }
    if (createResp.status !== 200) {
      throw new Error(
        `error creating edge function for workspaces/${ workspaceName }/sources/${ sourceName } and uploadUrl=${ uploadUrl }`,
      )
      // maybe add contact us or look at FAQ
    }
    return await createResp.json()
  }

  public async latest(workspaceName: string, sourceName: string): Promise<EdgeFunction> {
    const token = (await this.configReader.fetch()).token
    const response = await fetch(
      `${ BASE_URL }/v1beta/workspaces/${ workspaceName }/sources/${ sourceName }/edge-functions/latest`,
      {
        headers: {
          Authorization: `Bearer ${ token }`,
        },
      })
    if (response.status === 403) {
      throw new Error(this.badTokenMsg())
    }
    if (response.status !== 200) {
      throw new Error(`error fetching latest edge function, statusCode=${ response.status }`)
    }
    return await response.json()
  }

  private badTokenMsg(): string {
    return 'An error occurred trying to communicate to Segment, please check your auth-token or ensure your workspace has edge-functions enabled'
  }
}
