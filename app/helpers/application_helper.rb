module ApplicationHelper
  
  # Public: Add a hidden _destroy field to the document and build a link
  # to remove the child element.
  # 
  # TODO: Finish description of how it works. Require class names etc.
  #
  # name - The name printed on the link.
  # f - The form/form builder.
  #
  # Examples:
  #   <%= remove_child_link "remove", f %>
  #
  # Returns nothing (usable).
  def remove_child_link(name, f, options = {})
    options[:class] = options[:class] || ''
    options[:class] << ' remove_child'

    f.hidden_field(:_destroy) + link_to(name, "javascript:void(0)", class: options[:class])
  end

  # Public: Build a return a link to add a child to the page.
  #
  # name - The name printed on the link.
  # association - The name of the associated model.
  #
  # Examples: 
  #   <%= add_child_link("Add an additional menu", :menu_uploads) %> # where:
  #
  #   class Location < ActiveRecord::Base
  #     has_many :menu_uploads, :class_name => 'Document', :as => :documentable
  #     accepts_nested_attributes_for :menu_uploads, :allow_destroy => true, :reject_if => :all_blank
  #   end
  #
  # Returns a link to add a child element.
  def add_child_link(name, association, options = {})
    options[:class] = options[:class] || ''
    options[:class] << ' add_child'
    options[:name] ||= [options[:prefix], association].reject(&:nil?).join '_'
    options[:options] ||= {}

    options[:options].merge!(class: options[:class], :"data-association" => association)
    options[:options].merge!(:"data-template" => options[:name])
    link_to(name, "javascript:void(0)", options[:options])
  end

  # Public: Build and store a new template for the associated model. Retrieve the template
  # with template_for method, using the same association.
  #
  # form_builder - The form/form builder.
  # association - The name of the associated model.
  # options[:object] - An instance of the associated model. If not specified, an object will
  #                    be instantiated based on the reflected association name.
  # options[:partial] - The partial to use. If not specified, the singular of the association
  #                     will be used.
  # options[:form_builder_local] - TODO document
  # options[:name]
  # options[:prefix]
  # options[:locals]
  #
  # Note to self: This could be combined with the add_child_link. Migt make things
  # less complicated.
  #
  # Example:
  #   <%= new_child_fields_template(f, :menu_uploads, :partial => 'vendors/menu_upload') %>
  #
  # Returns nothing (usable).
  def new_child_fields_template(form_builder, association, options = {})
    options[:object] ||= form_builder.object.class.reflect_on_association(association).klass.new
    options[:partial] ||= association.to_s.singularize
    options[:form_builder_local] ||= :f
    options[:name] ||= [options[:prefix], association].reject(&:nil?).join '_'
    options[:locals] ||= {}

    content_for :"#{options[:name]}_template" do
      content_tag(:div, :id => "#{options[:name]}_fields_template", :style => "display: none") do
        form_builder.fields_for(association, options[:object], :child_index => "new_#{association}") do |f|
          render(:partial => options[:partial], 
                 :locals => {options[:form_builder_local] => f}.merge(options[:locals]))
        end
      end
    end unless content_for?(:"#{options[:name]}_template")
  end

  # Public: Print the template for an association, built by the new_child_fields_template method.
  #
  # association - The name of the associated model.
  #
  # Examples:
  #   <%= template_for :menu_uploads %>
  #
  # Returns a div with the association's template.
  def template_for(association)
    content_for :"#{association}_template"
  end

  # Public: Highlight a text with a yellow background span.
  #
  def yellow_highlight(text, term)
    highlight text, term, highlighter: '<span style="background-color: #ff0">\1</span>'
  end

  # Public: Encapsulates action abilities on menu overlay.
  # 
  # order - The order the overlay is for.
  # method - A symbol of the method to call to build the link
  #          if an action is appropriate.
  #
  # NOTE: The methods are found in the respecive xxxHelper module.
  #
  # Returns an html_safe string.
  def menu_action order, method
    unless method == :location_update_link
      return "LLD Mode" if current_user.present? && current_user.kind_of?(LiveLocationUser)
    end
    if order.location.open?
      if order.delivery_order?
        if order.location.delivering?
          if order.minimum_met?
            send(method, order)
          else
            send(method, order) + 
            "#{number_to_currency order.delivery_minimum / 100.0} min"
          end
        else
          'Delivery Closed'
        end
      else # dine in / take out
        send(method, order)
      end
    else
      'Closed'
    end
  end


end
