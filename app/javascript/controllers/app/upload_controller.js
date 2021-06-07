import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [
    'uploadGallery', 'uploadInput', 'uploadIdInput'
  ]

  connect() {
    if (this.uploadInputTargets.length !== 0) {
      this.configureUpload(
        this.uploadInputTarget, this.uploadGalleryTarget, this.uploadIdInputTarget
      )
    }
  }

  configureUpload(uploadInput, uploadGallery, uploadIdInput) {
    uploadInput.addEventListener('uploads:start', function(_ev) {
      uploadGallery.innerHTML = ''
    })

    uploadInput.addEventListener('upload:success', function(ev) {
      uploadIdInput.value = ev.detail.data.id
    })

    window.fileUploads(uploadInput, uploadGallery)
    window.uploads()
  }
}
