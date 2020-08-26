import get from 'lodash/get';

function changeTestValue(event: Analytics.Event): Analytics.Event | null {
  event.context.test = 2
  return event
}

function addValue(event: Analytics.Event): Analytics.Event | null {
  event.context.cats = 'gross'
  return event
}

function addDogValue(event: Analytics.Event): Analytics.Event | null {
  event.context.dogs = 'tha bomb'
  return event
}

function addMyObject(event: Analytics.Event): Analytics.Event | null {
  event.context.myObject = {
    booya: 1,
    picard: '<facepalm>',
  }
  return event
}

function dropWifiEvents(event: Analytics.Event): Analytics.Event | null {
  const wifi: boolean = get(event, 'context.network.wifi', false)

  if (wifi) {
    return null
  }
  return event
}

const sourceMiddleware: Analytics.SourceMiddlewareList = [
  changeTestValue,
  addValue,
]

const destinationMiddleware: Analytics.DestinationMiddlewareList = {
  'Segment.io': [
    addMyObject,
    addDogValue,
  ],
  appboy: [
    dropWifiEvents,
  ],
}

export default {
  sourceMiddleware,
  destinationMiddleware,
}
