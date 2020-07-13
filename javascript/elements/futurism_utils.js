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
  // IntersectionObserver takes an options object as a 2nd argument
  // https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API
  // Set rootMargin to make content load right before you reach it
  Object.assign(element, {
    observer: new IntersectionObserver(observerCallback.bind(element), {})
  })

  element.observer.observe(element)
}
