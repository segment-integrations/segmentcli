import { EdgeFunctionService } from '../types';

export class EdgeFunctionAPI implements EdgeFunctionService {
  public doesSomething() {
    console.log('yay');
  }

  public async upload() {
    console.log("uploads something");
  }
}
