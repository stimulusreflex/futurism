/* global customElements */

import FuturismElement from './futurism_element'
import FuturismDiv from './futurism_div'
import FuturismTableRow from './futurism_table_row'
import FuturismLI from './futurism_li'

customElements.define('futurism-element', FuturismElement)
customElements.define('futurism-div', FuturismDiv, { extends: 'div' })
customElements.define('futurism-table-row', FuturismTableRow, { extends: 'tr' })
customElements.define('futurism-li', FuturismLI, { extends: 'li' })
