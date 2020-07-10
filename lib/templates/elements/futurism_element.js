/* global customElements, IntersectionObserver, CustomEvent, setTimeout, HTMLElement */

class FuturismElement extends HTMLElement {
  connectedCallback () {
    const options = {}

    this.observer = new IntersectionObserver((entries, observer) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          this.dispatchAppearEvent(entry, observer)
        }
      })
    }, options)

    this.observer.observe(this)
  }

  dispatchAppearEvent (entry, observer) {
    if (window.Futurism) {
      const evt = new CustomEvent('futurism:appear', {
        bubbles: true,
        detail: {
          target: entry.target,
          observer
        }
      })
      this.dispatchEvent(evt)
    } else {
      setTimeout(() => {
        this.dispatchAppearEvent(entry, observer)
      }, 1)
    }
  }
}

customElements.define('futurism-element', FuturismElement)
