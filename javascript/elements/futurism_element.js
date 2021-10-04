/* global HTMLElement */

import {
  extendElementWithIntersectionObserver,
  extendElementWithEagerLoading
} from './futurism_utils'

export default class FuturismElement extends HTMLElement {
  constructor () {
    super()
    const shadowRoot = this.attachShadow({ mode: 'open' })
    shadowRoot.innerHTML = this.template
  }

  connectedCallback () {
    extendElementWithIntersectionObserver(this)
    extendElementWithEagerLoading(this)
  }

  get template () {
    return `
<style>
  :host {
    display: ${
      this.hasAttribute('extends') ? this.getAttribute('extends') : 'block'
    };
  }
</style>
<slot></slot>
`
  }
}
