/* global HTMLElement */

import { extendElementWithIntersectionObserver } from './futurism_utils'

export default class FuturismLI extends HTMLLIElement {
  connectedCallback () {
    extendElementWithIntersectionObserver(this)
  }
}
