/* global HTMLElement */

import {
  extendElementWithIntersectionObserver,
  extendElementWithEagerLoading,
  extendElementWithCableReadyUpdatesFor
} from './futurism_utils'

export default class FuturismElement extends HTMLElement {
  connectedCallback () {
    extendElementWithIntersectionObserver(this)
    extendElementWithEagerLoading(this)
    extendElementWithCableReadyUpdatesFor(this)
  }
}
