/* global CustomEvent, setTimeout */

import CableReady from 'cable_ready'

let subscription
let active
let queue = []

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
  subscription = consumer.subscriptions.create('Futurism::Channel', {
    connected () {
      active = true
      queue.forEach(payload => subscription.send(payload))
      queue = []
    },

    disconnected () {
      active = false
    },

    received (data) {
      if (data.cableReady) {
        CableReady.perform(data.operations, {
          emitMissingElementWarnings: false
        })

        document.dispatchEvent(
          new CustomEvent('futurism:appeared', {
            bubbles: true,
            cancelable: true
          })
        )
      }
    }
  })
}

document.addEventListener(
  'futurism:appear',
  debounceEvents(events => {
    const payload = {
      signed_params: events.map(e => e.target.dataset.signedParams),
      sgids: events.map(e => e.target.dataset.sgid),
      signed_controllers: events.map(e => e.target.dataset.signedController),
      urls: events.map(_ => window.location.href),
      broadcast_each: events.map(e => e.target.dataset.broadcastEach)
    }
    active ? subscription.send(payload) : queue.push(payload)
  })
)
