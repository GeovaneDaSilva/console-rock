// app/javascripts/controllers/config_key_value_controller.js
/*global toastr*/
import { Controller } from 'stimulus'
export default class extends Controller {
  static targets = ['scanTypeData', 'regexData', 'keywordsData', 'reportingThresholdData',
	            'labelData', 'createButton', 'configKey']

  connect() {
    this.labelDataTarget.addEventListener('keyup', () => {
      this.createButtonEnabler();
      if(!this.scanTypeDataTarget.value) {
        this.scanTypeDataTarget.value = this.labelDataTarget.value;
      }
    });

    this.regexDataTarget.addEventListener('keyup', () => {
      this.createButtonEnabler();
    });
  }

  createButtonEnabler() {
    if(this.scanTypeDataTarget.value != "" && this.regexDataTarget.value != "")
      this.createButtonTarget.classList.remove("disabled");
    else
      this.createButtonTarget.classList.add("disabled");
  }

  isDisabled() {
    return this.createButtonTarget.classList.contains("disabled");
  }

  add(event) {
    if(this.isDisabled())
      return;

    const destElement = document.getElementById(event.target.dataset.target_data_id);
    this.addRow(destElement);
  }
  

  addRow(destElement) {
    const row = this.createRow();
    const destScanType = destElement.querySelector("[name*='[" + this.scanTypeDataTarget.value + "]']") || destElement.querySelector("[value='" + this.scanTypeDataTarget.value + "']");

    if(destScanType) {
      const destRow = destScanType.closest("tr");
      destRow.parentNode.insertBefore(row, destRow.nextSibling);
      destRow.parentNode.removeChild(destRow);
    } else {
      destElement.tBodies[0].appendChild(row);
    }
    this.clear();
  }

  createRow() {
    const config_name = this.configKeyTarget.value + "[" + this.scanTypeDataTarget.value+ "]";

    // row
    const result = document.createElement("tr");
    result.setAttribute("data-target", "tbl-row-editor.row");
    result.setAttribute("data-controller", "tbl-row-editor");

    // scan type
    const name = document.createElement("td");
    name.innerHTML = "<input name='" + config_name + "[label]' type='text' value='" + this.labelDataTarget.value + "' readonly data-target='tbl-row-editor.text'/><input type='hidden' name='" + config_name + "[key]' value='" + this.scanTypeDataTarget.value + "' />";
    result.append(name);

    // regex
    const value = document.createElement("td");
    value.innerHTML = "<textarea name='" + config_name + "[" + this.regexDataTarget.name + "]' row='3' readonly data-target='tbl-row-editor.text'>" +this.regexDataTarget.value + "</textarea>";
    result.append(value);

    // switch
    const swtch = document.createElement("td");
    swtch.innerHTML = "<label class='switch switch-rounded'>" + 
      "<input name='" + config_name + "[reporting_threshold]' type='hidden' value='" + this.reportingThresholdDataTarget.value + "'/>" +

      "<input name='" + config_name + "[enabled]' type='checkbox' value='true' checked='checked'/>" +
      "<span class='switch-label' data-on='YES' data-off='NO'></span>" +
      "<span></span>" +
      "</label>" +
      this.appendKeywordsData();
    result.append(swtch);

    const btns = document.createElement("td");
    btns.innerHTML = "<a class='pr-10' href='#' data-toggle='modal' data-target='#config-key-value-edit' data-action='click->tbl-row-editor#edit'><i class='fa fa-edit'></i></a>" +
    "<a data-action='click->tbl-row-editor#del' href='#'><i class='fa fa-trash'></i></a>";
    result.append(btns);

    return result;
  }

  appendKeywordsData() {
    if(this.keywordsDataTarget.value != "") {
      const config_name = this.configKeyTarget.value + "[" + this.scanTypeDataTarget.value+ "]";
      return "<input name='" + config_name + "[keywords]' type='hidden' value='" + this.keywordsDataTarget.value + "'/>";
    }
    return "";
  }

  clear() {
    this.scanTypeDataTarget.value = "";
    this.regexDataTarget.value = "";
    this.keywordsDataTarget.value = "";
    this.reportingThresholdDataTarget.value = "";
    this.createButtonEnabler();
  }
}
