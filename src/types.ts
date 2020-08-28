export interface EdgeFunction {
  id: string
  source_id: string
  created_at: string
  created_by: string
  download_url: string
  version: number
}

export interface GenerateUploadURL {
  upload_url: string
}

export interface Config {
  token: string
}

export interface EdgeFunctionService {
  upload(workspaceName: string, sourceName: string, file: string): Promise<EdgeFunction>;
  latest(workspaceName: string, sourceName: string): Promise<EdgeFunction>;
  disable(workspaceName: string, sourceName: string): Promise<EdgeFunction>;
}

export interface ConfigReader {
  fetch(): Promise<Config>

  store(cfg: Config): Promise<void>
}
