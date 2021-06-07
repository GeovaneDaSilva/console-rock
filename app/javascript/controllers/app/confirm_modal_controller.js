import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['modal', 'loading', 'delete']

  close(e) {
    this.closeModal();
    e.preventDefault();
  }

  show(e) {
    let data = e.srcElement.dataset;
    $(data.target + " .modal-body").html(data.message);
    $(data.target).modal('show');
    if(data.formMethod) {
      this.loadingTarget.closest('form').setAttribute("data-method", data.formMethod);
    }
    e.preventDefault();
  }

  save(e) {
    this.closeModal();
    this.showLoading();
    this.preprocess_submit();
    e.preventDefault();
  }

  preprocess_submit() {
    let form = $(this.loadingTarget.closest('form'));
    if(form.attr("data-method") == "delete") {
      this.deleteTarget.click();
    } else {
      form.submit();
    }
  }

  showLoading() {
    $(this.loadingTarget).modal('show');
  }

  closeModal() {
    $(this.modalTarget).modal('hide');
  }
}
