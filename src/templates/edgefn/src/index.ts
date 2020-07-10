import get from 'lodash/get';

function changeTestValue(event: Analytics.Event) {
  event.context.test = 2;
  return event;
}

function addValue(event: Analytics.Event) {
  event.context.cats = 'gross';
  return event;
}

function addMyObject(event: Analytics.Event) {
  event.context.myObject = {
    booya: 1,
    picard: '<facepalm>',
  };

  return event;
}

function dropEventWifiEvents(event: Analytics.Event) {
  const wifi: boolean = get(event, 'event.context.network.wifi', false);

  if (wifi) {
    return null;
  }

  return event;
}

const middleware: Analytics.Middleware[] = [
  changeTestValue,
  addMyObject,
  addValue,
  dropEventWifiEvents,
];

export default middleware;
