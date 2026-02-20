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

    # Strip ERB tags since we can't render them without a view context
    content = content.gsub(/<%.*?%>/m, "")

    # Remove HTML comments
    content = content.gsub(/<!--.*?-->/m, "")

    # Clean up excessive blank lines left by stripping
    content = content.gsub(/\n{3,}/, "\n\n")

    content.strip
  end

  def should_skip_item?(item)
    item["path"]&.include?("apis/graphql/schemas/")
  end
end
