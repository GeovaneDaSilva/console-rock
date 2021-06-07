module BootstrapForm
  # Override the BootstrapForm stuff which the theme doesn't adhear to
  class FormBuilder
    def radio_button(name, value, *args)
      options = args.extract_options!.symbolize_keys!
      args << options.except(:label, :label_class, :help, :inline)

      disabled_class = " disabled" if options[:disabled]
      label_class    = options[:label_class]

      if options[:inline]
        label_class = " #{label_class}" if label_class
        label(name, html, class: "radio-inline#{disabled_class}#{label_class}", value: value)
      else
        content_tag(:label, class: "radio#{disabled_class}") do
          radio_button_without_bootstrap(name, value, *args) + content_tag(:i) + " " + options[:label]
        end
      end
    end

    def switch(name, options = {}, checked_value = "true", unchecked_value = "false")
      options = options.symbolize_keys!
      check_box_options = options.except(:label, :label_class, :help, :label_name, :on, :off)

      html = check_box_without_bootstrap(name, check_box_options, checked_value, unchecked_value)

      switch_label = content_tag(
        :span, "", class: "switch-label #{options[:label_class]}",
                   data:  { on: options.fetch(:on, "YES"), off: options.fetch(:off, "NO") }
      )

      label_content = content_tag(:span, (options[:label_name] || name.to_s.humanize))
      html.concat(" ").concat(switch_label).concat(label_content)

      disabled_class = "disabled" if options[:disabled]
      label_class    = options[:label_class] || "switch-rounded"

      content_tag(:label, class: "switch #{disabled_class} #{label_class}") do
        [
          html,
          (content_tag(:span, options[:help], class: "help-block") if options[:help].present?)
        ].compact.join("").html_safe
      end
    end
  end
end
