module ActiveAdmin
  module Views

    # Renders an ActiveAdmin::Menu as a set of unordered list items.
    #
    # This component takes cares of deciding which items should be
    # displayed given the current context and renders them appropriately.
    #
    # The entire component is rendered within one ul element.
    class TabbedNavigation < Component

      attr_reader :menu

      # Build a new tabbed navigation component.
      #
      # @param [ActiveAdmin::Menu] menu the Menu to render
      # @param [Hash] options the options as passed to the underlying ul element.
      #
      def build(menu, options = {})
        @menu = menu
        super(default_options.merge(options))
        build_menu
      end

      # The top-level menu items that should be displayed.
      def menu_items
        menu.items(self)
      end

      def tag_name
        'ul'
      end

      private

      def build_menu
        menu_items.each do |item|
          build_menu_item(item)
        end
      end

      def build_menu_item(item)
        li id: item.id do |li|
          li.add_class "active" if item.current? assigns[:current_tab]

          if url = item.url(self)
            a href: url do
              i item.html_options
              span item.label(self), class: "nav-label"
              span class: "fa arrow"
            end
          else
            span item.label(self), item.html_options
          end

          if children = item.items(self).presence
            ul class: "nav nav-second-level collapse" do |ul|
              children.each{ |child| build_menu_item child }
            end
          end
        end
      end

      def default_options
        { id: "tabs" }
      end
    end
  end
end
