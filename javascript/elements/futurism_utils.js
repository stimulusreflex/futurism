/* global IntersectionObserver, CustomEvent, setTimeout */

const dispatchAppearEvent = (entry, observer = null) => {
  if (!window.Futurism?.subscription) {
    return () => {
      setTimeout(() => dispatchAppearEvent(entry, observer)(), 1)
    }
  }

  const target = entry.target ? entry.target : entry

  const evt = new CustomEvent('futurism:appear', {
    bubbles: true,
    detail: {
      target,
      observer
    }
  })

  return () => {
    target.dispatchEvent(evt)
  }
}

// from https://advancedweb.hu/how-to-implement-an-exponential-backoff-retry-strategy-in-javascript/#rejection-based-retrying
const wait = ms => new Promise(resolve => setTimeout(resolve, ms))

const callWithRetry = async (fn, depth = 0) => {
  try {
    return await fn()
  } catch (e) {
    if (depth > 10) {
      throw e
    }
    await wait(1.15 ** depth * 2000)

    return callWithRetry(fn, depth + 1)
  }
}

const observerCallback = (entries, observer) => {
  entries.forEach(async entry => {
    if (!entry.isIntersecting) return

    await callWithRetry(dispatchAppearEvent(entry, observer))
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
    callWithRetry(dispatchAppearEvent(element))
  }
}

export const extendElementWithCableReadyUpdatesFor = (element) => {
  if (element.dataset.updatesFor) {
    if (element.hasAttribute('keep')) {
      if (element.observer) element.observer.disconnect()
    }

    element.addEventListener('cable-ready:after-update', (event) => {
      const evt = new CustomEvent('futurism:appear', {
        bubbles: true,
        detail: {
          target: element,
          observer: null
        }
      })
      document.dispatchEvent(evt)
    });
  }
}
