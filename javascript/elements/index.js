/* global customElements */

import FuturismElement from './futurism_element'
import FuturismTableRow from './futurism_table_row'
import FuturismLI from './futurism_li'

const polyfillCustomElements = () => {
  if (customElements) {
    try {
      customElements.define(
        'built-in',
        document.createElement('p').constructor,
        { extends: 'p' }
      )
    } catch (_) {
      document.write(
        '<script src="//unpkg.com/@ungap/custom-elements-builtin"><\x2fscript>'
      )
    }
  } else {
    document.write(
      '<script src="//unpkg.com/document-register-element"><\x2fscript>'
    )
  }
}

const defineElements = e => {
  customElements.define('futurism-element', FuturismElement)
  customElements.define('futurism-table-row', FuturismTableRow, {
    extends: 'tr'
  })
  customElements.define('futurism-li', FuturismLI, { extends: 'li' })
}

export const initializeElements = () => {
  document.addEventListener('DOMContentLoaded', defineElements)
  document.addEventListener('turbolinks:load', defineElements)

  polyfillCustomElements()
}
