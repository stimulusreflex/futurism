/* global HTMLElement */

import { extendElementWithIntersectionObserver } from './futurism_utils'

export default class FuturismElement extends HTMLElement {
  constructor() {
    super()
    extendElementWithIntersectionObserver(this)
  }

  connectedCallback()  { 
    this.connectedCallback() 
  }
}
