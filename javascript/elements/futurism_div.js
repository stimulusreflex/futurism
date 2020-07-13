/* global HTMLElement */

import { extendElementWithIntersectionObserver } from './futurism_utils'

export default class FuturismDiv extends HTMLDivElement {
  connectedCallback () {
    extendElementWithIntersectionObserver(this)
  }
}
