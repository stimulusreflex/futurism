/* global customElements */

import FuturismElement from './futurism_element'
import FuturismTableRow from './futurism_table_row'
import FuturismDiv from './futurism_div'
import FuturismLI from './futurism_li'

export const initializeElements = () => {
  customElements.define('futurism-element', FuturismElement)
  customElements.define('futurism-table-row', FuturismTableRow, {
    extends: 'tr'
  })
  customElements.define('futurism-div', FuturismDiv, { extends: 'div' })
  customElements.define('futurism-li', FuturismLI, { extends: 'li' })
}
