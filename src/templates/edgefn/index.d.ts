declare namespace Analytics {

  type EventContext = {

    /** Contains details about the app being tracked */
    app: {
      build: string;
      name: string;
      namespace: string;
      version: string;
    };
    
    /** Contains details about the device that generated this event */
    device: {
      id: string;
      manufacturer: string;
      model: string;
      name: string;
      type: string;
    };
    ip: string;
    library: {
      name: string;
      version: string;
    };
    locale: string;
    network: {
      cellular: boolean;
      wifi: boolean;
    };
    os: {
      name: string;
      version: string;
    };
    screen: {
      height: number;
      width: number;
    };
    timezone: string;
    traits: any;
  }

  /** An event that gets fired by the Segment Analytics libraries */
  export type Event = {
    [key: string]: any;
    anonymousId: string;
    event: string;
    messageId: string;
    originalTimestamp: string;
    type: string;
    userId: string;

    context: EventContext;
    integrations: any;
    properties: any;
  }

  /** 
   * A function that receives an analytics event and can either modify
   * the event or choose to return `null` to skip sending this event
   * to segment.
   */
  export type Middleware = (event: Event) => Promise<Event> | Event |  null
}
