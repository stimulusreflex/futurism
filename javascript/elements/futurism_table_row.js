/* global HTMLTableRowElement */

import {
  extendElementWithIntersectionObserver,
  extendElementWithEagerLoading,
  extendElementWithCableReadyUpdatesFor
} from './futurism_utils'

export default class FuturismTableRow extends HTMLTableRowElement {
  connectedCallback () {
    extendElementWithIntersectionObserver(this)
    extendElementWithEagerLoading(this)
    extendElementWithCableReadyUpdatesFor(this)
  }
}
