/* global HTMLLIElement */

import {
  extendElementWithIntersectionObserver,
  extendElementWithEagerLoading,
  extendElementWithCableReadyUpdatesFor
} from './futurism_utils'

export default class FuturismLI extends HTMLLIElement {
  connectedCallback () {
    extendElementWithIntersectionObserver(this)
    extendElementWithEagerLoading(this)
    extendElementWithCableReadyUpdatesFor(this)
  }
}
