/* global IntersectionObserver, CustomEvent, setTimeout */

export const extendElementWithIntersectionObserver = element => {
  Object.assign(element, {

    connectedCallback() {
      const options = {}
      this.observer = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
          if (!entry.isIntersecting) return;
          this.dispatchAppearEvent(entry, observer)
        })
      }, options)
      this.observer.observe(this)
    },

    dispatchAppearEvent(entry, observer) {
      if (!window.Futurism) {
        setTimeout(() => this.dispatchAppearEvent(entry, observer), 1)
        return;
      }

      const evt = new CustomEvent('futurism:appear', {
        bubbles: true,
        detail: {
          target: entry.target,
          observer
        }
      });

      this.dispatchEvent(evt)
    }
  });
};
