/* global HTMLElement */

import { extendElementWithIntersectionObserver } from './futurism_utils'

export default class FuturismElement extends HTMLElement {
  connectedCallback () {
    extendElementWithIntersectionObserver(this)
  }
}
