import '@hotwired/turbo-rails'
import jQuery from 'jquery';

window.jQuery = jQuery // <- "select2" will check this
window.$ = jQuery

// This is a hack to fix 'process is not defined'
// Ref article: https://adambien.blog/roller/abien/entry/uncaught_referenceerror_process_is_not
// Based on this filter dropdown works.
// window.process = { env: { NODE_ENV: "#{Rails.env}" } }
window.process = {
  env: {
    NODE_ENV: 'development'
  }
}


import * as bootstrap from 'bootstrap'
import * as popper from 'popper.js'
import 'trix'

import * as moment from "moment";
import Select2 from "select2"


import { } from "jquery-ujs";

import * as cocoon from 'cocoon'
import * as datepicker from 'pc-bootstrap4-datetimepicker'


import "trix"
import "@rails/actiontext"

Select2()

window.moment = moment
window.datepicker = datepicker
window.bootstrap = bootstrap

$.ajaxSetup({
  headers: {
    'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
  }
});
