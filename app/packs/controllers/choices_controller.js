/**
 * Thin wrapper around Choices.js
 * https://github.com/jshjohnson/Choices
 */
import { Controller } from "stimulus"
import * as Choices from "choices.js/public/assets/scripts/choices"

export default class extends Controller {
  static targets = [ ]

  connect() {
    const choices = new Choices(this.element, {
      // custom config...
    });
  }
}
