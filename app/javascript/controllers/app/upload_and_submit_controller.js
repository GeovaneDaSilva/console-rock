import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [
    'uploadGallery', 'uploadInput', 'uploadIdInput', 'form'
  ]

  connect() {
    if (this.uploadInputTargets.length !== 0) {
      this.configureUpload(
        this.uploadInputTarget, this.uploadGalleryTarget, this.uploadIdInputTarget
      )
    }
  }

  configureUpload(uploadInput, uploadGallery, uploadIdInput) {
    const form = this.formTarget

    uploadInput.addEventListener('uploads:start', function(_ev) {
      uploadGallery.innerHTML = ''
    })

    uploadInput.addEventListener('upload:success', function(ev) {
      uploadIdInput.value = ev.detail.data.id
      Rails.fire(form, 'submit')
    })

    window.fileUploads(uploadInput, uploadGallery)
    uploads()
  }
}
