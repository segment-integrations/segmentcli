function changeTestValue(event: Analytics.Event) {
  event.test = 2;
  return event;
}

function addValue(event: Analytics.Event) {
  event.cats = 'gross';
  return event;
}

function addMyObject(event: Analytics.Event) {
  event.myObject = {
    booya: 1,
    picard: '<facepalm>',
  };

  return event;
}

// TODO: comment about null
function dropEvent(event: Analytics.Event) {
  const wifi: boolean = false;
  if (wifi) {
    return event;
  }

  return null;
}

const middleware: Analytics.Middleware[] = [
  changeTestValue,
  addMyObject,
  addValue,
  dropEvent,
];

export default middleware;
