import { Controller } from '@hotwired/stimulus'

const LOCAL_STORAGE_KEY_THEME = 'chaltron-theme'
const THEME_VALUE_AUTO = 'auto'
const THEME_VALUE_LIGHT = 'light'
const THEME_VALUE_DARK = 'dark'

// Connects to data-controller='chaltron--theme'
export default class extends Controller {
  static targets = ['dark', 'light', 'auto']

  initialize () {
    this.#setThemeFromLocalStorageOrMediaPreference()
  }

  toggle () {
    const current = this.#currentTheme()
    switch (current) {
      case THEME_VALUE_AUTO:
        window.localStorage.setItem(LOCAL_STORAGE_KEY_THEME, THEME_VALUE_DARK)
        break
      case THEME_VALUE_DARK:
        window.localStorage.setItem(LOCAL_STORAGE_KEY_THEME, THEME_VALUE_LIGHT)
        break
      case THEME_VALUE_LIGHT:
        window.localStorage.removeItem(LOCAL_STORAGE_KEY_THEME)
        break
    }
    this.#setThemeFromLocalStorageOrMediaPreference()
  }

  #currentTheme () {
    switch (window.localStorage.getItem(LOCAL_STORAGE_KEY_THEME)) {
      case THEME_VALUE_LIGHT: return THEME_VALUE_LIGHT
      case THEME_VALUE_DARK: return THEME_VALUE_DARK
      default: return THEME_VALUE_AUTO
    }
  }

  #setThemeFromLocalStorageOrMediaPreference () {
    switch (this.#currentTheme()) {
      case THEME_VALUE_AUTO:
        this.#setThemeAuto()
        break
      case THEME_VALUE_DARK:
        this.#setThemeDark()
        break
      case THEME_VALUE_LIGHT:
        this.#setThemeLight()
        break
    }
  }

  #setThemeAuto () {
    if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
      document.documentElement.dataset.bsTheme = THEME_VALUE_DARK
    } else if (window.matchMedia('(prefers-color-scheme: light)').matches) {
      document.documentElement.dataset.bsTheme = THEME_VALUE_LIGHT
    }
    this.autoTarget.classList.remove('d-none')
    this.lightTarget.classList.add('d-none')
    this.darkTarget.classList.add('d-none')
  }

  #setThemeLight () {
    document.documentElement.dataset.bsTheme = THEME_VALUE_LIGHT
    this.lightTarget.classList.remove('d-none')
    this.darkTarget.classList.add('d-none')
    this.autoTarget.classList.add('d-none')
  }

  #setThemeDark () {
    document.documentElement.dataset.bsTheme = THEME_VALUE_DARK
    this.darkTarget.classList.remove('d-none')
    this.lightTarget.classList.add('d-none')
    this.autoTarget.classList.add('d-none')
  }
}
