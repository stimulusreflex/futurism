/* global customElements */

import FuturismElement from './futurism_element'
import FuturismTableRow from './futurism_table_row'
import FuturismLI from './futurism_li'

import { sha256 } from '../utils/crypto'

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
  if (!customElements.get('futurism-element')) {
    customElements.define('futurism-element', FuturismElement)
    customElements.define('futurism-table-row', FuturismTableRow, {
      extends: 'tr'
    })
    customElements.define('futurism-li', FuturismLI, { extends: 'li' })
  }
}

const cleanUp = e => {
  document.querySelector('.count').innerHTML = 'test'
  Object.entries(sessionStorage).forEach(([key, payload]) => {
    const targetElement = document.querySelector(
      `[data-futurism-hash="${key}"]`
    )

    if (targetElement) {
      targetElement.outerHTML = payload
      sessionStorage.removeItem(key)
    }
  })
}

export const initializeElements = () => {
  document.addEventListener('DOMContentLoaded', defineElements)
  document.addEventListener('turbolinks:load', defineElements)
  document.addEventListener('turbolinks:before-cache', cleanUp)
  document.addEventListener('cable-ready:after-outer-html', e => {
    sha256(e.detail.element.outerHTML).then(hashedContent => {
      e.detail.element.setAttribute('keep', '')
      sessionStorage.setItem(hashedContent, e.detail.element.outerHTML)
      e.target.dataset.futurismHash = hashedContent
    })
  })

  polyfillCustomElements()
}
