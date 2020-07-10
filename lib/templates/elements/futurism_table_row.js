import { connectedCallback } from './futurism_utils'
export class FuturismTableRow extends HTMLTableRowElement {
  connectedCallback = new connectedCallback(this)
}

customElements.define('futurism-table-row', FuturismTableRow, {
  extends: 'tr'
})
