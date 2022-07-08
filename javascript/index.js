import { createSubscription } from './futurism_channel'
import { initializeElements } from './elements'

function initialize (consumer) {
  initializeElements()
  createSubscription(consumer)
}

export { createSubscription, initializeElements, initialize }
