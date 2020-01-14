import { Controller } from "stimulus"

export default class extends Controller {
    static targets = [ 'screenWrapper', 'sidebarWrapper', 'mainWrapper', 'toggle' ]

    connect() {
        console.log("Sidebar connected")
        if (this.data.get('show') === 'true' && window.innerWidth > 992) {
            this.showSidebar()
        } else {
            this.hideSidebar()
        }

        setTimeout(() => this.setAsDoneLoading(), 500)
    }

    toggleSidebar(event) {
        console.log("Sidebar toggled")
        event.preventDefault()
        this.screenWrapperTarget.classList.toggle('toggled')
    }

    showSidebar() {
        this.screenWrapperTarget.classList.add('toggled')
    }

    hideSidebar() {
        this.screenWrapperTarget.classList.remove('toggled')
    }

    setAsDoneLoading() {
        this.screenWrapperTarget.classList.remove('loading')
    }
}
