import { ConnectedCallback } from './futurism_utils'
export default class FuturismElement extends HTMLElement {
  connectedCallback = new ConnectedCallback(this)
}
