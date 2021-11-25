/* global HTMLLIElement */

import {
  extendElementWithIntersectionObserver,
  extendElementWithEagerLoading
} from './futurism_utils'

export default class FuturismLI extends HTMLLIElement {
  connectedCallback () {
    extendElementWithIntersectionObserver(this)
    extendElementWithEagerLoading(this)
  }
}
