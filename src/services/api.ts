import { EdgeFunctionService } from '../types';
import s3 from 'aws-sdk/clients/s3';
import fs from 'fs';

export class EdgeFunctionAPI implements EdgeFunctionService {
  public doesSomething() {
    console.log('yay');
  }

  public async upload(file: string): Promise<void> {
    const client = new s3();

    const params = {
      Body: fs.createReadStream(file),
      Bucket: 'edgefn',
      Key: 'real-bundle.js',
      ACL: 'public-read',
    };

    const result = await client.putObject(params).promise();

    console.log(result);
  }
}
