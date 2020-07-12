import consumer from './consumer'
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
  subscription.send({ sgids: events.map(e => e.target.dataset.sgid) })
}, 1)

const subscription = consumer.subscriptions.create('Futurism::Channel', {
  connected () {
    window.Futurism = this
    document.addEventListener('futurism:appear', futureHandler)
  },

  disconnected () {
    window.Futurism = undefined
    document.removeEventListener('futurism:appear', futureHandler)
  },

  received (data) {
    if (data.cableReady) {
      CableReady.perform(data.operations, {
        emitMissingElementWarnings: false
      })
    }
  }
})
