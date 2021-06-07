App.DeviceHunts = {
  all: function all() {
    [].forEach.call(document.querySelectorAll('[data-cable-device-hunt]'), function (el) {
      App.DeviceHunts.subscribe(el);
    });
  },
  subscribe: function subscribe(el) {
    var huntId = el.getAttribute('data-cable-device-hunt');
    var deviceId = el.getAttribute('data-cable-device-hunt-device');
    var revision = el.getAttribute('data-cable-device-hunt-revision');
    var config = {
      channel: 'DeviceHuntChannel',
      id: huntId,
      device_id: deviceId
    };

    if (revision != undefined) {
      config['revision'] = revision;
    }

    return App.cable.subscriptions.create(config, {
      received: function received(data) {
        el.innerHTML = data;
        App.timeAgo.all();
      }
    });
  }
};
