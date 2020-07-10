import { connectedCallback } from './futurism_utils'
export class FuturismElement extends HTMLElement {
  connectedCallback = new connectedCallback(this)
}

customElements.define('futurism-element', FuturismElement)
