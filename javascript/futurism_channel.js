import CableReady from 'cable_ready'

const debounceEvents = (callback, delay = 20) => {
  let timeoutId
  let events = []
  return (...args) => {
    clearTimeout(timeoutId)
    events = [...events, ...args]
    timeoutId = setTimeout(() => {
      timeoutId = null
      callback(events)
      events = []
    }, delay)
  }
}

export const createSubscription = consumer => {
  consumer.subscriptions.create('Futurism::Channel', {
    connected () {
      window.Futurism = this
      document.addEventListener(
        'futurism:appear',
        debounceEvents(events => {
          this.send({
            signed_params: events.map(e => e.target.dataset.signedParams)
          })
        })
      )
    },

    received (data) {
      if (data.cableReady) {
        CableReady.perform(data.operations, {
          emitMissingElementWarnings: false
        })
      }
    }
  })
}
