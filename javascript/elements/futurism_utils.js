/* global IntersectionObserver, CustomEvent, setTimeout */

const dispatchAppearEvent = (entry, observer = null) => {
  if (!window.Futurism) {
    setTimeout(() => dispatchAppearEvent(entry, observer), 1)
    return
  }

  const target = entry.target ? entry.target : entry

  const evt = new CustomEvent('futurism:appear', {
    bubbles: true,
    detail: {
      target,
      observer
    }
  })

  target.dispatchEvent(evt)
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

  if (!element.hasAttribute('keep')) {
    element.observer.observe(element)
  }
}

export const extendElementWithEagerLoading = element => {
  if (element.dataset.eager === 'true') {
    if (element.observer) element.observer.disconnect()
    dispatchAppearEvent(element)
  }
}
