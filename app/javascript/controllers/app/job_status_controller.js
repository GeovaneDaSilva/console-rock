import { Controller } from 'stimulus'

export default class extends Controller {

  connect() {
    this.check_job_re_pull_setup_data();
    this.check_job_pull_board_statuses();
    this.check_job_setup_psa_config();
  }

  check_job_re_pull_setup_data() {
    let job_id = this.params().get("job_re_pull_setup_data");
    let credential_type = this.params().get("credential_type");
    let target = $(`.${credential_type}.jobRePullSetupData`).get(0);

    if(job_id == null || target == null)
      return;
    this.generic_check(job_id, target, "Re-Pull Data Status");
  }

  check_job_pull_board_statuses() {
    let job_id = this.params().get("job_pull_board_statuses");
    let credential_type = this.params().get("credential_type");
    let target = $(`.${credential_type}.jobPullBoardStatuses`).get(0);

    if(job_id == null || target == null)
      return;
    this.generic_check(job_id, target, "Pull Board Statuses Status");
  }

  check_job_setup_psa_config() {
    let job_id = this.params().get("job_setup_psa_config");
    let credential_type = this.params().get("credential_type");
    let target = $(`.${credential_type}.jobSetupPsaConfig`).get(0);

    if(job_id == null || target == null)
      return;
    this.generic_check(job_id, target, "Setup PSA Config Status");
  }

  generic_check(job_id, target, message) {
    if(job_id) {
      // check status of job; update label
      this.check_status(job_id, target, message);
    }
  }

  check_status(job_id, destination_element, message) {
    const accountId = this.scope.element.dataset.accountid;
    this.refreshInterval = setInterval((job_id, destination_element, message, accountId) => {
      $.ajax({
        type: "get",
        url: `/accounts/${accountId}/credentials/job_status`,
        data: { job_id: job_id },
        success: (data) => {
	  if(data.message) {
	    destination_element.innerText = data.message;
	    destination_element.classList.remove("hidden");
	  }
	  if(!["queued", "working", "failed"].includes(data.status)) {
	    clearInterval(this.refreshInterval);
	    setTimeout((d_element) => d_element.classList.add("hidden"), 2000, destination_element);
	  }
        }
      });
    }, 5000, job_id, destination_element, message, accountId);
  }

  params() {
    return new URL(location.href).searchParams;
  }
}
