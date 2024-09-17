import { Controller } from '@hotwired/stimulus'

// Connects to data-controller='chaltron--theme'
export default class extends Controller {
  static targets = ['dark', 'light']

  initialize () {
    this.#applyDarkMode(this.#getUserPreference() === 'true')
  }

  toggle () {
    const isCurrentlyDark = document.documentElement.dataset.bsTheme === 'dark'
    this.#applyDarkMode(!isCurrentlyDark)
    this.#setUserPreference(!isCurrentlyDark)
  }

  #applyDarkMode (isDark) {
    if (isDark) {
      document.documentElement.dataset.bsTheme = 'dark'
      this.lightTarget.classList.add('d-none')
      this.darkTarget.classList.remove('d-none')
    } else {
      document.documentElement.dataset.bsTheme = 'light'
      this.lightTarget.classList.remove('d-none')
      this.darkTarget.classList.add('d-none')
    }
  }

  #getUserPreference () {
    return window.localStorage.getItem('dark-mode')
  }

  #setUserPreference (isDark) {
    window.localStorage.setItem('dark-mode', isDark ? 'true' : 'false')
  }
}
