/* global customElements, sessionStorage */

import FuturismElement from './futurism_element'
import FuturismTableRow from './futurism_table_row'
import FuturismLI from './futurism_li'

import { sha256 } from '../utils/crypto'

const polyfillCustomElements = () => {
  const isSafari = /^((?!chrome|android).)*safari/i.test(navigator.userAgent)

  if (customElements) {
    if (isSafari) {
      document.write(
        '<script src="//unpkg.com/@ungap/custom-elements-builtin"><\x2fscript>'
      )
    } else {
      try {
        customElements.define(
          'built-in',
          document.createElement('tr').constructor,
          { extends: 'tr' }
        )
      } catch (_) {
        document.write(
          '<script src="//unpkg.com/@ungap/custom-elements-builtin"><\x2fscript>'
        )
      }
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

const cachePlaceholders = e => {
  sha256(e.detail.element.outerHTML).then(hashedContent => {
    e.detail.element.setAttribute('keep', '')
    sessionStorage.setItem(
      `futurism-${hashedContent}`,
      e.detail.element.outerHTML
    )
    e.target.dataset.futurismHash = hashedContent
  })
}

const restorePlaceholders = e => {
  // we have to opt out of this if the request leading to this is a TF request
  // if the TF request has been promoted to an advance action
  // (data-turbo-action="advance"), this callback will fire inadvertently
  // but the whole page will not be exchanged as in a regular TD visit
  if (window.Futurism.requestedTurboFrame) {
    delete window.Futurism.requestedTurboFrame
    return
  }

  const inNamespace = ([key, _payload]) => key.startsWith('futurism-')
  Object.entries(sessionStorage)
    .filter(inNamespace)
    .forEach(([key, payload]) => {
      const match = /^futurism-(.*)/.exec(key)
      const targetElement = document.querySelector(
        `[data-futurism-hash="${match[1]}"]`
      )

      if (targetElement) {
        targetElement.outerHTML = payload
        sessionStorage.removeItem(key)
      }
    })
}

const storeRequestedTurboFrame = e => {
  const { headers } = e.detail.fetchOptions

  if (!headers['Turbo-Frame'] || headers['X-Sec-Purpose'] === 'prefetch') return

  // we store the frame ID in case the incoming request was referencing one
  window.Futurism.requestedTurboFrame = headers['Turbo-Frame']
}

export const initializeElements = () => {
  polyfillCustomElements()
  document.addEventListener('DOMContentLoaded', defineElements)
  document.addEventListener('turbo:load', defineElements)
  document.addEventListener('turbo:before-cache', restorePlaceholders)
  document.addEventListener('turbolinks:load', defineElements)
  document.addEventListener('turbolinks:before-cache', restorePlaceholders)
  document.addEventListener('cable-ready:after-outer-html', cachePlaceholders)

  document.addEventListener(
    'turbo:before-fetch-request',
    storeRequestedTurboFrame
  )
}
