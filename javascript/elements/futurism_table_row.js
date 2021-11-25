/* global HTMLTableRowElement */

import {
  extendElementWithIntersectionObserver,
  extendElementWithEagerLoading
} from './futurism_utils'

export default class FuturismTableRow extends HTMLTableRowElement {
  connectedCallback () {
    extendElementWithIntersectionObserver(this)
    extendElementWithEagerLoading(this)
  }
}
