/* global customElements, IntersectionObserver, CustomEvent, setTimeout, HTMLTableRowElement */

import { ConnectedCallback } from './futurism_utils'

export default class FuturismTableRow extends HTMLTableRowElement {
  connectedCallback = new ConnectedCallback(this)
}