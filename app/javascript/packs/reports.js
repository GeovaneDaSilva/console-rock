/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import 'element-closest'
import 'mutation-observer-inner-html-shim'
import Highcharts from 'highcharts'
import highchartsMore from 'highcharts/highcharts-more'
import highcharts3d from 'highcharts/highcharts-3d'
import highchartsCylinder from 'highcharts/modules/cylinder'
import highchartsFunnel3d from 'highcharts/modules/funnel3d'

import { Application } from 'stimulus'
import { definitionsFromContext } from 'stimulus/webpack-helpers'

highchartsMore(Highcharts)
highcharts3d(Highcharts)
highchartsFunnel3d(Highcharts)
highchartsCylinder(Highcharts)

window.Highcharts = Highcharts

const application = Application.start()
const reportingContext = require.context('controllers/reports', true, /.js$/)
application.load(definitionsFromContext(reportingContext))

const sharedContext = require.context('controllers/shared', true, /.js$/)
application.load(definitionsFromContext(sharedContext))
