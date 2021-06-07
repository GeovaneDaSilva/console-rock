import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [
    'destroyInput', 'contents', 'uploadGallery', 'uploadInput', 'uploadIdInput'
  ]

  connect() {
    if (this.uploadInputTargets.length !== 0) {
      this.configureUpload(
        this.uploadInputTarget, this.uploadGalleryTarget, this.uploadIdInputTarget
      )
    }
  }

  remove() {
    if (window.confirm('Are you sure you want to remove this test?')) {
      this.destroyInputTarget.value = 'true'
      this.contentsTarget.setAttribute('hidden', true)
    }
  }

  configureUpload(uploadInput, uploadGallery, uploadIdInput) {
    uploadInput.addEventListener('uploads:start', function(_ev) {
      uploadGallery.innerHTML = ''
    })

    uploadInput.addEventListener('upload:success', function(ev) {
      uploadIdInput.value = ev.detail.data.id
    })

    uploadInput.addEventListener('upload:removed', function(_ev) {
      uploadIdInput.value = ''
    })

    window.fileUploads(uploadInput, uploadGallery)
    window.uploads()
  }
}
