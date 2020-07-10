/* global customElements */

import FuturismElement from './futurism_element'
import FuturismTableRow from './futurism_table_row'

customElements.define('futurism-element', FuturismElement)
customElements.define('futurism-table-row', FuturismTableRow, { extends: 'tr' })
