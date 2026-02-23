# frozen_string_literal: true

class LLMFullText
  attr_reader :nav

  def initialize(nav)
    @nav = nav
  end

  class << self
    def generate
      new(Rails.application.config.default_nav).generate
    end
  end

  def generate
    content = [
      "# Buildkite Documentation",
      "",
      "> Buildkite is a platform for running fast, secure, and scalable continuous integration pipelines on your own infrastructure.",
      "",
      "---",
      ""
    ]

    nav.data.each do |section|
      next unless section["children"]

      pages = []
      pages << section if section["path"] && !should_skip_item?(section)
      collect_pages(section["children"], pages)

      next if pages.empty?

      content << "## #{section['name']}"
      content << ""

      pages.each do |page|
        page_content = read_page(page["path"])
        next unless page_content

        url = "https://buildkite.com/docs/#{page['path']}"
        content << "### #{page['name']}"
        content << ""
        content << "URL: #{url}"
        content << ""
        content << page_content
        content << ""
        content << "---"
        content << ""
      end
    end

    content.join("\n")
  end

  private

  def collect_pages(children, pages)
    children.each do |child|
      next if child["type"] == "divider"
      next if should_skip_item?(child)

      if child["path"]
        pages << child
      elsif child["children"]
        collect_pages(child["children"], pages)
      end
    end
  end

  def read_page(path)
    basename = path.tr("-", "_")
    filepath = Rails.root.join("pages", "#{basename}.md")

    return nil unless File.exist?(filepath)

    parsed = ::FrontMatterParser::Parser.parse_file(filepath)
    content = parsed.content

    # Resolve ERB helpers that we can handle without a view context
    content = resolve_erb(content)

    # Remove HTML comments
    content = content.gsub(/<!--.*?-->/m, "")

    # Strip Redcarpet inline attribute lists (e.g., {: class="responsive-table"})
    content = content.gsub(/^\{:.*?\}\s*$/, "")

    # Bump headings down by 3 levels so page content sits below the
    # structural headings (# doc title, ## section, ### page title).
    # Caps at H6 (######) since Markdown doesn't support deeper levels.
    content = content.gsub(/^(#+)(\s)/) do
      hashes = $1
      new_level = [hashes.length + 3, 6].min
      "#" * new_level + $2
    end

    # Clean up excessive blank lines left by stripping
    content = content.gsub(/\n{3,}/, "\n\n")

    content.strip
  end

  def resolve_erb(content)
    # Inline render/render_markdown partials with actual file content
    content = content.gsub(/<%= render_markdown partial: '([^']+)' %>/) do
      read_partial($1)
    end
    content = content.gsub(/<%= render '([^']+)' %>/) do
      read_partial($1)
    end

    # Resolve known URL helpers to their actual URLs
    content = content.gsub(/<%= paginated_resource_docs_url %>/, "/docs/apis/rest-api#pagination")
    content = content.gsub(/<%= url_helpers\.user_access_tokens_url %>/, "https://buildkite.com/user/api-access-tokens")
    content = content.gsub(/<%= url_helpers\.user_authorizations_url %>/, "https://buildkite.com/user/connected-apps")
    content = content.gsub(/<%= url_helpers\.signup_path %>/, "https://buildkite.com/signup")
    content = content.gsub(/<%= url_helpers\.docs_path %>/, "/docs")

    # Replace image helpers with descriptive placeholders
    content = content.gsub(/<%= image '([^']+)'[^%]*%>/, '[Image: \1]')
    content = content.gsub(/<%= image_tag [^%]*%>/, '')

    # Strip any remaining ERB tags that we can't resolve
    content = content.gsub(/<%.*?%>/m, "")

    content
  end

  def read_partial(partial_path)
    filepath = Rails.root.join("pages", "#{partial_path.tr('-', '_')}.md")

    # Partials are prefixed with underscore by convention
    unless File.exist?(filepath)
      dir = File.dirname(filepath)
      base = File.basename(filepath)
      filepath = File.join(dir, "_#{base}")
    end

    return "" unless File.exist?(filepath)

    parsed = ::FrontMatterParser::Parser.parse_file(filepath)
    parsed.content.strip
  end

  def should_skip_item?(item)
    item["path"]&.include?("apis/graphql/schemas/")
  end
end
