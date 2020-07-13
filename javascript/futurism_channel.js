import CableReady from 'cable_ready'

const debounceEvents = (callback, delay = 250) => {
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

const futureHandler = debounceEvents(events => {
  this.send({ sgids: events.map(e => e.target.dataset.sgid) })
}, 1)

export const createSubscription = consumer => {
  consumer.subscriptions.create('Futurism::Channel', {
    connected () {
      window.Futurism = this
      document.addEventListener('futurism:appear', futureHandler.bind(this))
    },

    disconnected () {
      window.Futurism = undefined
      document.removeEventListener('futurism:appear', futureHandler.bind(this))
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
