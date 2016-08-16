module ActiveAdmin
  module Views
    module Pages
      class Base < Arbre::HTML::Document

        def build(*args)
          super
          add_classes_to_body
          build_active_admin_head
          build_page
        end

        private

        def add_classes_to_body
          @body.add_class(params[:action])
          @body.add_class(params[:controller].tr('/', '_'))
          @body.add_class("active_admin")
          @body.add_class("logged_in")
          @body.add_class(active_admin_namespace.name.to_s + "_namespace")

          content_for :body_classes do
            @body.class_names
          end
        end

        def build_active_admin_head
          @title = Arbre::Context.new
          @stylesheets = Arbre::Context.new
          @favicon = Arbre::Context.new
          @meta = Arbre::Context.new

          within @title do
            insert_tag Arbre::HTML::Title, [title, render_or_call_method_or_proc_on(self, active_admin_namespace.site_title)].compact.join(" | ")
          end

          within @stylesheets do
            active_admin_application.stylesheets.each do |style, options|
              text_node stylesheet_link_tag(style, options).html_safe
            end
          end

          within @favicon do
            if active_admin_namespace.favicon
              text_node(favicon_link_tag(active_admin_namespace.favicon))
            end
          end

          within @meta do
            active_admin_namespace.meta_tags.each do |name, content|
              text_node(tag(:meta, name: name, content: content))
            end
            text_node csrf_meta_tag
          end

          content_for :title do
            @title.content
          end

          content_for :stylesheets do
            @stylesheets.content
          end

          content_for :favicon do
            @favicon.content
          end

          content_for :meta do
            @meta.content
          end

          within @head do
            text_node @title
            text_node @stylesheets
            text_node @favicon
            text_node @meta
          end

          content_for :head do
            @head.content
          end
        end

        def build_active_admin_scripts
          @scripts = Arbre::Context.new

          within @scripts do
            active_admin_application.javascripts.each do |path|
              text_node(javascript_include_tag(path))
            end
          end

          content_for :javascript do
            @scripts.content
          end

          text_node @scripts
        end

        def build_page
          within @body do
            div id: "wrapper" do
              build_unsupported_browser
              build_header
              build_title_bar
              build_page_content
              build_footer
            end
            build_active_admin_scripts
          end

          content_for :body do
            @body.content
          end
        end

        def build_unsupported_browser
          if active_admin_namespace.unsupported_browser_matcher =~ request.user_agent
            insert_tag view_factory.unsupported_browser
          end
        end

        def build_header
          @header = Arbre::Context.new

          within @header do
            insert_tag view_factory.header, active_admin_namespace, current_menu
          end

          content_for :header do
            @header.content
          end

          text_node @header
        end

        def build_title_bar
          @title_bar = Arbre::Context.new

          within @title_bar do
            insert_tag view_factory.title_bar, title, action_items_for_action
          end

          content_for :title_bar do
            @title_bar.content
          end

          text_node @title_bar.content
        end

        def build_page_content
          @page_content = Arbre::Context.new

          within @page_content do
            build_flash_messages
            div id: "active_admin_content", class: (skip_sidebar? ? "without_sidebar" : "with_sidebar") do
              build_main_content_wrapper
              build_sidebar unless skip_sidebar?
            end
          end

          content_for :page_content do
            @page_content.content
          end

          text_node @page_content
        end

        def build_flash_messages
          @flash_messages = Arbre::Context.new

          within @flash_messages do
            div class: 'flashes' do
              flash_messages.each do |type, message|
                div message, class: "flash flash_#{type}"
              end
            end
          end

          content_for :flash_messages do
            @flash_messages.content
          end

          text_node @flash_messages
        end

        def build_main_content_wrapper
          @main_content = Arbre::Context.new

          within @main_content do
            div id: "main_content_wrapper" do
              div id: "main_content" do
                main_content
              end
            end
          end

          content_for :main_content do
            @main_content.content
          end

          text_node @main_content
        end

        def main_content
          I18n.t('active_admin.main_content', model: title).html_safe
        end

        def title
          self.class.name
        end

        # Set's the page title for the layout to render
        def set_page_title
          set_ivar_on_view "@page_title", title
        end

        # Returns the sidebar sections to render for the current action
        def sidebar_sections_for_action
          if active_admin_config && active_admin_config.sidebar_sections?
            active_admin_config.sidebar_sections_for(params[:action], self)
          else
            []
          end
        end

        def action_items_for_action
          if active_admin_config && active_admin_config.action_items?
            active_admin_config.action_items_for(params[:action], self)
          else
            []
          end
        end

        # Renders the sidebar
        def build_sidebar
          @sidebar = Arbre::Context.new

          within @sidebar do
            div id: "sidebar" do
              sidebar_sections_for_action.collect do |section|
                sidebar_section(section)
              end
            end
          end

          content_for :sidebar do
            @sidebar.content
          end

          text_node @sidebar
        end

        def skip_sidebar?
          sidebar_sections_for_action.empty? || assigns[:skip_sidebar] == true
        end

        # Renders the content for the footer
        def build_footer
          @footer = Arbre::Context.new

          within @footer do
            insert_tag view_factory.footer
          end

          content_for :footer do
            @footer.content
          end

          text_node @footer
        end
      end
    end
  end
end
