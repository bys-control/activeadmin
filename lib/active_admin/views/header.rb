module ActiveAdmin
  module Views
    class Header < Component

      def build(namespace, menu)
        super(id: "header")

        @namespace = namespace
        @menu = menu
        @utility_menu = @namespace.fetch_menu(:utility_navigation)

        build_site_title
        build_global_navigation
        build_utility_navigation
        content_for_layout
      end

      def content_for_layout
        content_for :global_navigation do
          @global_navigation.content
        end

        content_for :utility_navigation do
          @utility_navigation.content
        end

        content_for :site_title do
          @site_title.content
        end        
      end

      def build_site_title
        @site_title = Arbre::Context.new

        within @site_title do
          insert_tag view_factory.site_title, @namespace
        end

        text_node @site_title
      end

      def build_global_navigation
        @global_navigation = Arbre::Context.new

        within @global_navigation do
          insert_tag view_factory.global_navigation, @menu, class: 'header-item tabs nav'
        end

        text_node @global_navigation
      end

      def build_utility_navigation
        @utility_navigation = Arbre::Context.new

        within @utility_navigation do
          insert_tag view_factory.utility_navigation, @utility_menu, id: "utility_nav", class: 'header-item tabs'
        end

        text_node @utility_navigation
      end

    end
  end
end
