import { Controller } from "stimulus"

export default class extends Controller {
    static targets = [ 'bodyWrapper', 'sidebarWrapper', 'pageContentWrapper', 'toggle' ]

    connect() {
        if (this.data.get('show') === 'true' && window.innerWidth > 992) {
            this.showSidebar()
        } else {
            this.hideSidebar()
        }

        setTimeout(() => this.setAsDoneLoading(), 500)
    }

    toggleSidebar(event) {
        event.preventDefault()
        this.bodyWrapperTarget.classList.toggle('toggled')
    }

    showSidebar() {
        this.bodyWrapperTarget.classList.add('toggled')
    }

    hideSidebar() {
        this.bodyWrapperTarget.classList.remove('toggled')
    }

    setAsDoneLoading() {
        this.bodyWrapperTarget.classList.remove('loading')
    }
}
