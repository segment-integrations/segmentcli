declare namespace Analytics {

  type EventContext = {
    [key: string]: any;

    /** Contains details about the app being tracked */
    app: {
      build: string;
      name: string;
      namespace: string;
      version: string;
      [key: string]: any;
    };

    /** Contains details about the device that generated this event */
    device: {
      id: string;
      manufacturer: string;
      model: string;
      name: string;
      type: string;
      [key: string]: any;
    };
    ip: string;
    library: {
      name: string;
      version: string;
      [key: string]: any;
    };
    locale: string;
    network: {
      cellular: boolean;
      wifi: boolean;
      [key: string]: any;
    };
    os: {
      name: string;
      version: string;
      [key: string]: any;
    };
    screen: {
      height: number;
      width: number;
      [key: string]: any;
    };
    timezone: string;
    traits: any;
  }

  export type JsonMap = {
    [key: string]: any;
  }

  export type EventIntegrations = JsonMap

  export interface CommonFields {
    anonymousId: string;
    userId?: string;
    context: EventContext;
    integrations: EventIntegrations;
    messageId: string;
    timestamp: string;
    type: 'identify' | 'group' | 'track' | 'page' | 'screen' | 'alias';

    [k: string]: any;
  }

  /** An event that gets fired by the Segment Analytics libraries */
  export type Event = IdentifyEvent | GroupEvent | TrackEvent | PageEvent | ScreenEvent | AliasEvent

  export type IdentifyEvent = CommonFields & {
    type: 'identify';
    traits: JsonMap;
    userId: string;
  }

  export type GroupEvent = CommonFields & {
    type: 'group';
    traits: JsonMap;
    groupId: string;
  }

  export type TrackEvent = CommonFields & {
    type: 'track';
    properties: JsonMap;
    event: string;
  }

  export type ScreenEvent = CommonFields & {
    type: 'screen';
    properties: JsonMap;
    name: string;
  }

  export type PageEvent = CommonFields & {
    type: 'page';
    properties: JsonMap;
    name: string;
  }

  export type AliasEvent = CommonFields & {
    type: 'alias';
    previousId: string;
    userId: string;
  }

  /**
   * A function that receives an analytics event and can either modify
   * the event or choose to return `null` to skip sending this event
   * to segment.
   */
  export type Middleware = (event: Event) => Event | null

  /**
   * A function that receives an analytics event and can either modify
   * the event or choose to return `null` to skip sending this event
   * to segment.
   */
  export type SourceMiddlewareList = Middleware[]

  export type DestinationMiddlewareList = {
    [key: string]: Middleware[];
  }

  export type DataBridge = {
    [key: string]: any;
  }
}

declare var dataBridge: Analytics.DataBridge
