import { Controller } from 'stimulus'
import { Cable } from '../../lib/cable'
import pluralize from 'pluralize'

export default class extends Controller {
  static targets = [
    'deviceCount', 'devicesLabel', 'detections', 'detectionsLabel', 'iconWrapper',
    'instancesLabel', 'instancesCount'
  ];

  connect() {
    const appId = this.data.get('app-id')
    const scopeAccountId = this.data.get('scope-account-id')

    this.subscription = Cable.subscriptions.create(
      {
        channel: 'AppsChannel',
        app_id: appId,
        scope_account_id: scopeAccountId
      },
      {
        received: (data) => this.updateCards(JSON.parse(data)),
        refresh: function() { this.perform('refresh') }
      }
    )
    if(parseInt(this.data.get('show-app'))) {
      this.scope.element.querySelector("a[data-target*='#config']").click();
    }
    this.refreshTimer = setTimeout(() => { this.subscription.refresh() }, 1000)
  }

  disconnect() {
    if (this.refreshTimer) {
      clearTimeout(this.refreshTimer)
    }

    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }

  updateCards(parsedEvent) {
    if (this.refreshTimer) {
      clearTimeout(this.refreshTimer)
    }
    this.refreshTimer = setTimeout(() => { this.subscription.refresh() }, 1000 * 60 * 3)

    if (this.hasDeviceCountTarget) {
      this.deviceCountTarget.innerText =
        `${parseFloat(parsedEvent.reporting_devices).toLocaleString()} of ${parseFloat(parsedEvent.total_devices).toLocaleString()}`
    }

    if (this.hasInstancesLabelTarget) {
      this.instancesLabelTarget.innerText = pluralize(
        this.instancesLabelTarget.innerText, parsedEvent.total_instances
      )
    }

    if (this.hasInstancesCountTarget) {
      this.instancesCountTarget.innerText = parseFloat(parsedEvent.total_instances).toLocaleString()
    }

    this.detectionsTarget.innerText = parseFloat(parsedEvent.detection_count).toLocaleString()

    if (this.detectionsLabelTarget) {
      this.detectionsLabelTarget.innerText = pluralize(
        this.detectionsLabelTarget.innerText, parsedEvent.detection_count
      )
    }

    this.iconWrapperTarget.classList.remove('no-detections', 'detections')
    this.element.classList.remove('disabled')

    if (parsedEvent.enabled) {
      if (parsedEvent.detection_count > 0) {
        this.iconWrapperTarget.classList.add('detections')
      } else {
        this.iconWrapperTarget.classList.add('no-detections')
      }
    } else {
      this.element.classList.add('disabled')
    }
  }
}
