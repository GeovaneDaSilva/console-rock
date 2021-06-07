import { Controller } from 'stimulus'


export default class extends Controller {
  static targets = ['table']

  addRow() {
    var target = this.tableTarget
    var newIndex = target.rows.length
    var row = target.insertRow(-1)
    var cell0 = row.insertCell(0)
    var cell1 = row.insertCell(1)
    var cell2 = row.insertCell(2)
    var cell3 = row.insertCell(3)
    // var cell4 = row.insertCell(4)
    var button = document.createElement('input')
    button.setAttribute('type', 'button')
    button.setAttribute('id', newIndex)
    button.setAttribute('value', 'Remove')
    button.setAttribute('data-action', 'click->dynamic-table#deleteRow')

    cell0.appendChild(button)
    cell1.innerHTML = '<select class="form-control" name="logic_rule[logic_rules][][operator]" id="logic_rule_logic_rules__operator"><option value="==">==</option><option value="<">&lt;</option><option value=">">&gt;</option><option value="<=">&lt;=</option><option value=">=">&gt;=</option><option value="includes">includes</option><option value="key">key</option><option value="value">value</option></select>'
    cell2.innerHTML = '<input class="form-control" type="text" name="logic_rule[logic_rules][][field]" id="logic_rule_logic_rules__value">'
    cell3.innerHTML = '<input class="form-control" type="text" name="logic_rule[logic_rules][][value]" id="logic_rule_logic_rules__value">'
    // cell4.innerHTML = '<select class="form-control" name="logic_rule[logic_rules][][connector]" id="and_or_operator"><option value="AND">--</option><option value="OR">OR</option></select>'
    // TODO: move these to DOM element creation as with button (?)
  }

  deleteRow(ev){
    var target = this.tableTarget
    target.deleteRow(ev.target.id)
    // ^^^ This doesn't work as the rows are added/removed (i.e. what got id 4 because it was the 4th is index 0 after all the others are removed...)
  }
}
