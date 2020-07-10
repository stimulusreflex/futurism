let dispatchAppearEvent = function (that, entry, observer) {
  if (!window.Futurism) {
    setTimeout(() => dispatchAppearEvent(that, entry, observer), 1)
    return
  }

  const evt = new CustomEvent('futurism:appear', {
    bubbles: true,
    detail: {
      target: entry.target,
      observer
    }
  })
  that.dispatchEvent(evt)
}

export function connectedCallback (that) {
  const options = {}
  that.observer = new IntersectionObserver((entries, observer) => {
    entries.forEach(entry => {
      if (!entry.isIntersecting) return
      dispatchAppearEvent(that, entry, observer)
    })
  }, options)
  that.observer.observe(that)
}
