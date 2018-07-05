# frozen_string_literal: true

module Decidim
  # A Helper to render scopes, including a global scope, for forms.
  module ScopesHelper
    include DecidimFormHelper
    include TranslatableAttributes

    Option = Struct.new(:id, :name)

    # Checks if the resource should show its scope or not.
    # resource - the resource to analize
    #
    # Returns boolean.
    def has_visible_scopes?(resource)
      resource.participatory_space.scopes_enabled? &&
        resource.scope.present? &&
        resource.participatory_space.scope != resource.scope
    end

    # Retrieves the translated name and type for an scope.
    # scope - a Decidim::Scope
    # global_name - text to use when scope is nil
    #
    # Returns a string
    def scope_name_for_picker(scope, global_name)
      return global_name unless scope

      name = translated_attribute(scope.name)
      name << " (#{translated_attribute(scope.scope_type.name)})" if scope.scope_type
      name
    end

    # Renders a scopes picker field in a form.
    # form - FormBuilder object
    # name - attribute name
    #
    # Returns nothing.
    def scopes_picker_field(form, name, root: false, options: {})
      root = current_participatory_space.scope if root == false
      form.scopes_picker name, options do |scope|
        { url: decidim.scopes_picker_path(root: root, current: scope&.id, field: form.label_for(name)),
          text: scope_name_for_picker(scope, I18n.t("decidim.scopes.global")) }
      end
    end

    # Renders a scopes picker field in a form, not linked to a specific model.
    # name - name for the input
    # value - value for the input
    #
    # Returns nothing.
    def scopes_picker_tag(name, value, options = {})
      root = try(:current_participatory_space)&.scope
      field = options[:field] || name

      scopes_picker_field_tag name, value, id: options[:id] do |scope|
        { url: decidim.scopes_picker_path(root: root, current: scope&.id, field: field),
          text: scope_name_for_picker(scope, I18n.t("decidim.scopes.global")) }
      end
    end

    # Renders a scopes picker field in a filter form.
    # form - FilterFormBuilder object
    # name - attribute name
    #
    # Returns nothing.
    def scopes_picker_filter(form, name)
      form.scopes_picker name, multiple: true, legend_title: I18n.t("decidim.scopes.scopes"), label: false do |scope|
        {
          url: decidim.scopes_picker_path(
            root: try(:current_participatory_space)&.scope,
            current: scope&.id,
            title: I18n.t("decidim.scopes.prompt"),
            global_value: "global"
          ),
          text: scope_name_for_picker(scope, I18n.t("decidim.scopes.prompt"))
        }
      end
    end
  end
end