// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require turbolinks
//= require bootstrap
//= require uploads/s3
//= require uploads/file_picker
//= require uploads/removal
//= require uploads/upload_and_submit
//= require uploads/file_selector
//= require braintree
//= require jquery-jvectormap.min
//= require jquery-jvectormap-world-mill
//= require jquery-ui-autocomplete.min
//= require clipboard.min
//= require reload_on_change
//= require validator.min
//= require nested_form_fields
//= require pdf-link
//= require rails-ujs
//= require qrcode.min
//= require toggle
//= require_self

// Expire the timezone cookie
// Overridden when signup.js is included later on in the page
document.cookie = "timezone=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/users;";
