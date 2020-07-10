/* global HTMLTableRowElement */

import { extendElementWithIntersectionObserver } from './futurism_utils'

export default class FuturismTableRow extends HTMLTableRowElement {
  constructor() {
    super()
    extendElementWithIntersectionObserver(this)
  }

  connectedCallback()  { 
    this.connectedCallback() 
  }
}