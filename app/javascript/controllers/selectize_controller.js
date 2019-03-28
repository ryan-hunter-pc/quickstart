/**
 * Thin wrapper around Selectize.js
 * https://github.com/selectize/selectize.js
 */
import { Controller } from "stimulus"

export default class extends Controller {
    static targets = [ ]

    connect() {
        $(this.element).selectize({
            // create: true,
            sortField: 'text',
        })
    }
}
