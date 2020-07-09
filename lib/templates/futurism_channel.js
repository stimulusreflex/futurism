import consumer from "./consumer";
import CableReady from "cable_ready";

const debounceEvents = (callback, delay = 250) => {
  let timeoutId;
  let events = [];
  return (...args) => {
    clearTimeout(timeoutId);
    events = [...events, ...args];
    timeoutId = setTimeout(() => {
      timeoutId = null;
      callback(events);
      events = [];
    }, delay);
  };
};

consumer.subscriptions.create("FuturismChannel", {
  connected() {
    window.Futurism = this;
    document.addEventListener(
      "futurism:appear",
      debounceEvents(
        (events => {
          this.send({ sgids: events.map(e => e.target.dataset.sgid) });
        }).bind(this)
      )
    );
  },

  received(data) {
    if (data.cableReady) {
      CableReady.perform(data.operations, {
        emitMissingElementWarnings: false
      });
    }
  }
});
