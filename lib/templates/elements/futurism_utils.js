/* global IntersectionObserver, CustomEvent, setTimeout */

const dispatchAppearEvent = (entry, observer) => {
  if (!window.Futurism) {
    setTimeout(() => dispatchAppearEvent(entry, observer), 1)
    return
  }

  const evt = new CustomEvent('futurism:appear', {
    bubbles: true,
    detail: {
      target: entry.target,
      observer
    }
  })

  entry.target.dispatchEvent(evt)
}

const observerCallback = (entries, observer) => {
  entries.forEach(entry => {
    if (!entry.isIntersecting) return
    dispatchAppearEvent(entry, observer)
  })
}

export const extendElementWithIntersectionObserver = element => {
  Object.assign(element, {
    observer: new IntersectionObserver(observerCallback.bind(element), {})
  })

  element.observer.observe(element)
}
