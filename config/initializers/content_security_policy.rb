Rails.application.config.content_security_policy do |policy|
  policy.default_src :none
  policy.font_src    :self, :data, :https
  policy.img_src     :self, :data
  policy.object_src  :none
  policy.script_src  :self, :unsafe_inline
  policy.style_src   :self, :https, :unsafe_inline
  policy.report_uri "/csp-violation-report-endpoint"
end